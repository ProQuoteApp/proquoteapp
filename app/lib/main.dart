import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:proquote/screens/create_job_screen.dart';
import 'package:proquote/screens/home_screen.dart';
import 'package:proquote/screens/job_details_screen.dart';
import 'package:proquote/screens/profile_screen.dart';
import 'package:proquote/screens/provider_list_screen.dart';
import 'package:proquote/screens/login_screen.dart';
import 'package:proquote/screens/jobs_screen.dart';
import 'package:proquote/screens/messages_screen.dart';
import 'package:proquote/screens/forgot_password_screen.dart';
import 'package:proquote/theme/app_theme.dart';
import 'package:proquote/theme/shadcn_theme.dart';
import 'package:proquote/utils/mock_data.dart';
import 'package:proquote/providers/auth_provider.dart';
import 'package:proquote/providers/user_provider.dart';
import 'package:proquote/providers/job_provider.dart';
import 'package:proquote/providers/quote_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:proquote/widgets/user_avatar.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enable Firestore persistence for offline caching
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  // Clear image cache on app start to prevent encoding issues
  await CachedNetworkImage.evictFromCache('');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, authProvider, previousUserProvider) {
            final userProvider = previousUserProvider ?? UserProvider();
            
            // Only load user data when auth state changes and user is authenticated
            if (authProvider.currentUser != null && 
                (previousUserProvider?.currentUser?.id != authProvider.currentUser?.uid)) {
              // Load user data in the background
              Future.microtask(() => userProvider.loadUser(authProvider.currentUser!));
            } else if (authProvider.currentUser == null) {
              userProvider.clearUser();
            }
            
            return userProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, JobProvider>(
          create: (_) => JobProvider(),
          update: (_, authProvider, previousJobProvider) {
            final jobProvider = previousJobProvider ?? JobProvider();
            
            // Clear jobs when user logs out
            if (authProvider.currentUser == null && previousJobProvider != null) {
              jobProvider.clearCache();
            }
            
            return jobProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return ShadApp.custom(
            theme: ShadThemeData(
              brightness: Brightness.light,
              colorScheme: const ShadBlueColorScheme.light(),
            ),
            darkTheme: ShadThemeData(
              brightness: Brightness.dark,
              colorScheme: const ShadBlueColorScheme.dark(),
            ),
            themeMode: ThemeMode.light, // Default to light theme
            appBuilder: (context, theme) => MaterialApp.router(
              title: 'ProQuote',
              theme: theme,
              routerConfig: _buildRouter(authProvider),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter _buildRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // If the user is not authenticated and not on the login screen, redirect to login
      final isLoggedIn = authProvider.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      // If the user is authenticated and going to login, redirect to home
      if (isLoggedIn && isGoingToLogin) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(child: HomeScreen()),
        routes: [
          GoRoute(
            path: 'job/:jobId',
            builder: (context, state) {
              final jobId = state.pathParameters['jobId']!;
              // Load the job from the provider instead of mock data
              return MainScreen(
                child: Consumer<JobProvider>(
                  builder: (context, jobProvider, _) {
                    // Load the job if not already loaded
                    if (jobProvider.currentJob?.id != jobId) {
                      Future.microtask(() => jobProvider.loadJob(jobId));
                    }
                    
                    // Also load quotes for this job
                    if (jobProvider.currentJob != null) {
                      final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
                      Future.microtask(() => quoteProvider.loadJobQuotes(jobId));
                    }
                    
                    // Show loading indicator while job is loading
                    if (jobProvider.isLoading || jobProvider.currentJob == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    // Show error if job not found
                    if (jobProvider.error != null) {
                      return Center(child: Text('Error: ${jobProvider.error}'));
                    }
                    
                    return JobDetailsScreen(job: jobProvider.currentJob!);
                  },
                ),
              );
            },
          ),
          GoRoute(
            path: 'create-job',
            builder: (context, state) => const MainScreen(child: CreateJobScreen()),
          ),
          GoRoute(
            path: 'edit-job/:jobId',
            builder: (context, state) {
              final jobId = state.pathParameters['jobId']!;
              return MainScreen(
                child: Consumer<JobProvider>(
                  builder: (context, jobProvider, _) {
                    // Load the job if not already loaded
                    if (jobProvider.currentJob?.id != jobId) {
                      Future.microtask(() => jobProvider.loadJob(jobId));
                    }
                    
                    // Show loading indicator while job is loading
                    if (jobProvider.isLoading || jobProvider.currentJob == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    // Show error if job not found
                    if (jobProvider.error != null) {
                      return Center(child: Text('Error: ${jobProvider.error}'));
                    }
                    
                    // Pass the job to the create job screen for editing
                    return CreateJobScreen(jobToEdit: jobProvider.currentJob);
                  },
                ),
              );
            },
          ),
          GoRoute(
            path: 'providers',
            builder: (context, state) {
              final uri = Uri.parse(state.uri.toString());
              final categoryFilter = uri.queryParameters['category'];
              return MainScreen(child: ProviderListScreen(categoryFilter: categoryFilter));
            },
          ),
        ],
      ),
      GoRoute(
        path: '/jobs',
        builder: (context, state) => const MainScreen(child: JobsScreen()),
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MainScreen(child: MessagesScreen()),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MainScreen(child: ProfileScreen()),
      ),
    ],
  );
}

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: child,
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  static const List<(IconData, String, String)> _items = [
    (Icons.home_outlined, 'Home', '/'),
    (Icons.work_outline_outlined, 'Jobs', '/jobs'),
    (Icons.message_outlined, 'Messages', '/messages'),
    (Icons.person_outline_outlined, 'Profile', '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // Get the current route to determine which tab should be active
    final location = GoRouterState.of(context).matchedLocation;
    final theme = ShadTheme.of(context);
    
    // Find the index of the current route in the bottom nav items
    int currentIndex = 0;
    for (int i = 0; i < _items.length; i++) {
      final path = _items[i].$3;
      if (location == path || location.startsWith('$path/')) {
        currentIndex = i;
        break;
      }
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          height: 1,
          thickness: 1,
          color: theme.colorScheme.border.withOpacity(0.2),
        ),
        BottomAppBar(
          elevation: 0,
          height: kBottomNavigationBarHeight,
          padding: EdgeInsets.zero,
          color: theme.colorScheme.background,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // First two items
              for (int i = 0; i < 2; i++)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (currentIndex != i) {
                        context.go(_items[i].$3);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _items[i].$1,
                          size: 22,
                          color: currentIndex == i
                              ? theme.colorScheme.primary
                              : theme.colorScheme.mutedForeground,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _items[i].$2,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: currentIndex == i ? FontWeight.w600 : FontWeight.normal,
                            color: currentIndex == i
                                ? theme.colorScheme.primary
                                : theme.colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Middle create job button
              Expanded(
                child: InkWell(
                  onTap: () {
                    context.go('/create-job');
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 22,
                          color: theme.colorScheme.primaryForeground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Last two items
              for (int i = 2; i < 4; i++)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (currentIndex != i) {
                        context.go(_items[i].$3);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _items[i].$1,
                          size: 22,
                          color: currentIndex == i
                              ? theme.colorScheme.primary
                              : theme.colorScheme.mutedForeground,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _items[i].$2,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: currentIndex == i ? FontWeight.w600 : FontWeight.normal,
                            color: currentIndex == i
                                ? theme.colorScheme.primary
                                : theme.colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
