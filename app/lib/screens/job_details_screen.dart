import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:proquote/models/job.dart';
import 'package:proquote/models/quote.dart';
import 'package:proquote/providers/quote_provider.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job title
            Text(
              job.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            
            // Job status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(job.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusText(job.status),
                style: TextStyle(
                  color: _getStatusColor(job.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Job details
            _buildInfoRow(context, 'Category', job.category),
            _buildInfoRow(context, 'Location', job.location),
            _buildInfoRow(
              context, 
              'Created', 
              DateFormat('MMM d, yyyy').format(job.createdAt),
            ),
            _buildInfoRow(
              context, 
              'Preferred Date', 
              DateFormat('MMM d, yyyy').format(job.preferredDate),
            ),
            const SizedBox(height: 16),
            
            // Job description
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(job.description),
            const SizedBox(height: 24),
            
            // Job images
            if (job.images.isNotEmpty) ...[
              Text(
                'Images',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: job.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < job.images.length - 1 ? 8 : 0,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          job.images[index],
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Quotes section
            Text(
              'Quotes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Quotes list
            Consumer<QuoteProvider>(
              builder: (context, quoteProvider, _) {
                if (quoteProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (quoteProvider.error != null) {
                  return Center(
                    child: Text('Error: ${quoteProvider.error}'),
                  );
                }
                
                final quotes = quoteProvider.jobQuotes;
                
                if (quotes == null || quotes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No quotes yet for this job'),
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < quotes.length - 1 ? 16 : 0,
                      ),
                      child: QuoteCard(
                        quote: quotes[index],
                        onTap: () {
                          // View quote details
                          // For now, just show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Viewing quote from ${quotes[index].provider.name}'),
                            ),
                          );
                        },
                        onAccept: () => _handleQuoteAction(
                          context, 
                          quotes[index], 
                          'accepted',
                        ),
                        onReject: () => _handleQuoteAction(
                          context, 
                          quotes[index], 
                          'rejected',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleQuoteAction(
    BuildContext context, 
    Quote quote, 
    String status,
  ) async {
    final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
    
    try {
      final success = await quoteProvider.updateQuoteStatus(quote.id, status);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'accepted' 
                  ? 'Quote accepted successfully' 
                  : 'Quote rejected successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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