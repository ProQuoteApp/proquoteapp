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
import 'package:firebase_core/firebase_core.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return ShadApp.custom(
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
              final job = MockData.jobs.firstWhere((job) => job.id == jobId);
              return MainScreen(child: JobDetailsScreen(job: job));
            },
          ),
          GoRoute(
            path: 'create-job',
            builder: (context, state) => const MainScreen(child: CreateJobScreen()),
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
    return Scaffold(
      body: child,
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  static const List<(IconData, String, String)> _items = [
    (Icons.home, 'Home', '/'),
    (Icons.work, 'Jobs', '/jobs'),
    (Icons.message, 'Messages', '/messages'),
    (Icons.person, 'Profile', '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // Get the current route to determine which tab should be active
    final location = GoRouterState.of(context).matchedLocation;
    
    // Find the index of the current route in the bottom nav items
    int currentIndex = 0;
    for (int i = 0; i < _items.length; i++) {
      final path = _items[i].$3;
      if (location == path || location.startsWith('$path/')) {
        currentIndex = i;
        break;
      }
    }
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      items: _items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.$1),
              label: item.$2,
            ),
          )
          .toList(),
      onTap: (index) {
        if (currentIndex != index) {
          context.go(_items[index].$3);
        }
      },
    );
  }
}
