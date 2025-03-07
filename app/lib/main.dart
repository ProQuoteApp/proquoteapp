import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proquote/models/job.dart';
import 'package:proquote/screens/create_job_screen.dart';
import 'package:proquote/screens/home_screen.dart';
import 'package:proquote/screens/job_details_screen.dart';
import 'package:proquote/screens/profile_screen.dart';
import 'package:proquote/screens/provider_list_screen.dart';
import 'package:proquote/theme/app_theme.dart';
import 'package:proquote/utils/mock_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ProQuote',
      theme: AppTheme.getTheme(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithBottomNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'job/:jobId',
              builder: (context, state) {
                final jobId = state.pathParameters['jobId']!;
                final job = MockData.jobs.firstWhere((job) => job.id == jobId);
                return JobDetailsScreen(job: job);
              },
            ),
            GoRoute(
              path: 'create-job',
              builder: (context, state) => const CreateJobScreen(),
            ),
            GoRoute(
              path: 'providers',
              builder: (context, state) {
                final uri = Uri.parse(state.uri.toString());
                final categoryFilter = uri.queryParameters['category'];
                return ProviderListScreen(categoryFilter: categoryFilter);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/jobs',
          builder: (context, state) => const JobsScreen(),
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) => const MessagesScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

class ScaffoldWithBottomNavBar extends StatefulWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({
    super.key,
    required this.child,
  });

  @override
  State<ScaffoldWithBottomNavBar> createState() => _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  int _currentIndex = 0;

  static const List<_BottomNavItem> _bottomNavItems = [
    _BottomNavItem(
      icon: Icons.home,
      label: 'Home',
      path: '/',
    ),
    _BottomNavItem(
      icon: Icons.work,
      label: 'Jobs',
      path: '/jobs',
    ),
    _BottomNavItem(
      icon: Icons.message,
      label: 'Messages',
      path: '/messages',
    ),
    _BottomNavItem(
      icon: Icons.person,
      label: 'Profile',
      path: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: _bottomNavItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
        onTap: (index) {
          _currentIndex = index;
          context.go(_bottomNavItems[index].path);
        },
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final String label;
  final String path;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.path,
  });
}

// Placeholder screens for bottom navigation
class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.jobs.length,
        itemBuilder: (context, index) {
          final job = MockData.jobs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(job.title),
              subtitle: Text(job.status),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                context.go('/job/${job.id}');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/create-job');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your conversations with service providers will appear here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
