import 'package:flutter/material.dart';
import 'package:proquote/models/service.dart';
import 'package:proquote/utils/mock_data.dart';
import 'package:proquote/widgets/service_category_card.dart';
import 'package:proquote/widgets/job_card.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:proquote/providers/user_provider.dart';
import 'package:proquote/providers/auth_provider.dart';
import 'package:proquote/utils/constants.dart';
import 'package:proquote/widgets/user_avatar.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user data from providers
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = userProvider.currentUser;
    final authUser = authProvider.currentUser;
    
    // Get screen width to handle responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;
    
    // Calculate content width based on screen size
    final contentWidth = isLargeScreen 
        ? 900.0 
        : isMediumScreen 
            ? screenWidth * 0.9 
            : screenWidth;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ProQuote'),
        centerTitle: isLargeScreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                context.go('/profile');
              },
              child: UserAvatar(
                user: user,
                authUser: authUser,
                radius: AppConstants.smallAvatarRadius,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Text(
                  'Welcome, ${_getFirstName(user, authUser)}!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppConstants.textSpacing),
                Text(
                  'What service do you need today?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: AppConstants.sectionSpacing),

                // Search bar
                ShadInput(
                  placeholder: const Text('Search for services...'),
                  leading: const Icon(Icons.search),
                  onChanged: (value) {
                    // Handle search
                  },
                ),
                const SizedBox(height: AppConstants.sectionSpacing),

                // Service categories
                Text(
                  'Service Categories',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: MockData.serviceCategories.length,
                    itemBuilder: (context, index) {
                      final category = MockData.serviceCategories[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < MockData.serviceCategories.length - 1 ? 16 : 0,
                        ),
                        child: ServiceCategoryCard(
                          id: category['id'] as String,
                          name: category['name'] as String,
                          icon: category['icon'] as String,
                          color: Color(category['color'] as int),
                          onTap: () {
                            // Navigate to category services
                            final categoryName = category['name'] as String;
                            context.go('/providers?category=$categoryName');
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Your jobs - RESPONSIVE LAYOUT
                ShadCard(
                  title: Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Jobs',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          // Navigate to all jobs
                          context.go('/jobs');
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('View All'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (MockData.jobs.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No jobs yet',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create a new job to get started',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        // Responsive job list
                        isLargeScreen || isMediumScreen
                            ? GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isLargeScreen ? 2 : 1,
                                  childAspectRatio: isLargeScreen ? 2.5 : 1.8,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: MockData.jobs.length > (isLargeScreen ? 4 : 2) 
                                    ? (isLargeScreen ? 4 : 2) 
                                    : MockData.jobs.length,
                                itemBuilder: (context, index) {
                                  final job = MockData.jobs[index];
                                  return JobCard(
                                    job: job,
                                    onTap: () {
                                      // Navigate to job details
                                      context.go('/job/${job.id}');
                                    },
                                  );
                                },
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: MockData.jobs.length > 2 ? 2 : MockData.jobs.length,
                                itemBuilder: (context, index) {
                                  final job = MockData.jobs[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: index < (MockData.jobs.length > 2 ? 1 : MockData.jobs.length - 1) ? 12 : 0,
                                    ),
                                    child: JobCard(
                                      job: job,
                                      onTap: () {
                                        // Navigate to job details
                                        context.go('/job/${job.id}');
                                      },
                                    ),
                                  );
                                },
                              ),
                      if (MockData.jobs.length > (isLargeScreen ? 4 : 2))
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Center(
                            child: ShadButton.outline(
                              onPressed: () {
                                // Navigate to all jobs
                                context.go('/jobs');
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.list, size: 18),
                                  const SizedBox(width: 8),
                                  const Text('View All Jobs'),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Popular services - RESPONSIVE LAYOUT
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Popular Services',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                      ShadButton.link(
                        onPressed: () {
                          // Navigate to all services
                          context.go('/providers');
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
                // Responsive service list
                isLargeScreen || isMediumScreen
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isLargeScreen ? 4 : 3,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: MockData.services.length > (isLargeScreen ? 8 : 6) 
                            ? (isLargeScreen ? 8 : 6) 
                            : MockData.services.length,
                        itemBuilder: (context, index) {
                          final service = MockData.services[index];
                          return ServiceCard(
                            service: service,
                            onTap: () {
                              // Navigate to service providers for this service
                              context.go('/providers?category=${service.category}');
                            },
                          );
                        },
                      )
                    : SizedBox(
                        height: 180, // Increased from 160
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: MockData.services.length > 4 ? 4 : MockData.services.length,
                          itemBuilder: (context, index) {
                            final service = MockData.services[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < (MockData.services.length > 4 ? 3 : MockData.services.length - 1) ? 12 : 0,
                              ),
                              child: ServiceCard(
                                service: service,
                                onTap: () {
                                  // Navigate to service providers for this service
                                  context.go('/providers?category=${service.category}');
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ShadButton(
        onPressed: () {
          // Navigate to create job
          context.go('/create-job');
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 18),
            const SizedBox(width: 8),
            const Text('New Job'),
          ],
        ),
      ),
    );
  }
  
  /// Get the first name of the user
  String _getFirstName(user, authUser) {
    final fullName = user?.name ?? authUser?.displayName ?? 'User';
    return fullName.split(' ')[0];
  }
}

// Compact service card for horizontal scrolling
class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ShadCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service image - make it taller to show more of the image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: service.imageUrl,
                    height: 100, // Increased from 90
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 100,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                  // Add a gradient overlay to make text more readable
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ShadBadge(
                      child: Text(
                        service.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Service details - more compact
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${service.averageRating}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${service.totalRatings})',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 