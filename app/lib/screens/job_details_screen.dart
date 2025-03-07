import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:proquote/models/job.dart';
import 'package:proquote/models/quote.dart';
import 'package:proquote/utils/mock_data.dart';
import 'package:proquote/widgets/quote_card.dart';
import 'package:proquote/utils/constants.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    // Get quotes for this job
    final List<Quote> jobQuotes = MockData.quotes
        .where((quote) => quote.jobId == job.id)
        .toList();
        
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
        title: const Text('Job Details'),
        centerTitle: isLargeScreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit job
            },
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
                // Job images
                if (job.images.isNotEmpty)
                  SizedBox(
                    height: 250,
                    child: PageView.builder(
                      itemCount: job.images.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: job.images[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        );
                      },
                    ),
                  ),

                // Job details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(job.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusText(job.status),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getStatusColor(job.status),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              job.category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        job.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        Icons.location_on,
                        'Location',
                        job.location,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        Icons.calendar_today,
                        'Preferred Date',
                        DateFormat('MMMM dd, yyyy').format(job.preferredDate),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        Icons.access_time,
                        'Posted',
                        DateFormat('MMMM dd, yyyy').format(job.createdAt),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      
                      // Quotes section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quotes (${jobQuotes.length})',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (job.status == 'open')
                            TextButton.icon(
                              onPressed: () {
                                // Navigate to find providers
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Request More Quotes'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (jobQuotes.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No quotes yet',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Request quotes from service providers',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Navigate to find providers
                                  },
                                  icon: const Icon(Icons.search),
                                  label: const Text('Find Service Providers'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: jobQuotes.length,
                          itemBuilder: (context, index) {
                            final quote = jobQuotes[index];
                            return QuoteCard(
                              quote: quote,
                              onTap: () {
                                // Navigate to quote details
                              },
                              onAccept: quote.status == 'pending'
                                  ? () {
                                      // Accept quote
                                    }
                                  : null,
                              onReject: quote.status == 'pending'
                                  ? () {
                                      // Reject quote
                                    }
                                  : null,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
} 