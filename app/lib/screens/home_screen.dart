import 'package:flutter/material.dart';
import 'package:proquote/models/service.dart';
import 'package:proquote/models/job.dart';
import 'package:proquote/utils/mock_data.dart';
import 'package:proquote/widgets/service_category_card.dart';
import 'package:proquote/widgets/service_card.dart';
import 'package:proquote/widgets/job_card.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.go('/profile');
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Text(
                  'Welcome, ${MockData.currentUser.name.split(' ')[0]}!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'What service do you need today?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),

                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for services...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.shade100,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                      const SizedBox(height: 16),
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
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Navigate to all jobs
                                context.go('/jobs');
                              },
                              icon: const Icon(Icons.list),
                              label: const Text('View All Jobs'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
                                side: BorderSide(color: Theme.of(context).primaryColor),
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
                      TextButton(
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
                          return ServiceCompactCard(
                            service: service,
                            onTap: () {
                              // Navigate to service providers for this service
                              context.go('/providers?category=${service.category}');
                            },
                          );
                        },
                      )
                    : Container(
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
                              child: ServiceCompactCard(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create job
          context.go('/create-job');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Job'),
      ),
    );
  }
}

// Compact service card for horizontal scrolling
class ServiceCompactCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const ServiceCompactCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        service.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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