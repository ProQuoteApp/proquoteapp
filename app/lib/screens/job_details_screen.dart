import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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
    final theme = ShadTheme.of(context);
    
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
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share job functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: RefreshIndicator(
            onRefresh: () async {
              // Refresh job details
              final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
              await quoteProvider.loadJobQuotes(job.id);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job header section with images carousel
                  _buildJobHeaderSection(context, theme),
                  
                  const SizedBox(height: AppConstants.sectionSpacing),
                  
                  // Job details card
                  _buildJobDetailsCard(context, theme),
                  
                  const SizedBox(height: AppConstants.sectionSpacing),
                  
                  // Job description card
                  _buildJobDescriptionCard(context, theme),
                  
                  const SizedBox(height: AppConstants.sectionSpacing),
                  
                  // Quotes section
                  _buildQuotesSection(context, theme),
                  
                  // Add some bottom padding
                  const SizedBox(height: AppConstants.sectionSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: job.status == 'open' ? FloatingActionButton.extended(
        onPressed: () {
          // Submit quote functionality (for service providers)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submit quote functionality coming soon')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Submit Quote'),
      ) : null,
    );
  }
  
  Widget _buildJobHeaderSection(BuildContext context, ShadThemeData theme) {
    return ShadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job images carousel
          if (job.images.isNotEmpty)
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: job.images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                      child: CachedNetworkImage(
                        imageUrl: job.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: theme.colorScheme.muted,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.muted,
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.muted,
                borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(job.category),
                      size: 48,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(height: AppConstants.textSpacing),
                    Text(
                      'No images available',
                      style: theme.textTheme.p.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          const SizedBox(height: AppConstants.itemSpacing),
          
          // Job title and status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.itemSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: theme.textTheme.h3,
                      ),
                    ),
                    _buildStatusBadge(job.status, theme),
                  ],
                ),
                
                const SizedBox(height: AppConstants.textSpacing),
                
                // Location with icon
                if (job.location.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: AppConstants.smallIconSize,
                        color: theme.colorScheme.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          job.location,
                          style: theme.textTheme.p.copyWith(
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: AppConstants.itemSpacing),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildJobDetailsCard(BuildContext context, ShadThemeData theme) {
    return ShadCard(
      title: Text(
        'Job Details',
        style: theme.textTheme.h4,
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            theme,
            Icons.category,
            'Category',
            job.category,
          ),
          const Divider(),
          _buildDetailRow(
            context,
            theme,
            Icons.calendar_today,
            'Created',
            DateFormat('MMM d, yyyy').format(job.createdAt),
          ),
          const Divider(),
          _buildDetailRow(
            context,
            theme,
            Icons.event,
            'Preferred Date',
            DateFormat('MMM d, yyyy').format(job.preferredDate),
          ),
        ],
      ),
    );
  }
  
  Widget _buildJobDescriptionCard(BuildContext context, ShadThemeData theme) {
    return ShadCard(
      title: Text(
        'Description',
        style: theme.textTheme.h4,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.textSpacing),
        child: Text(
          job.description,
          style: theme.textTheme.p,
        ),
      ),
    );
  }
  
  Widget _buildQuotesSection(BuildContext context, ShadThemeData theme) {
    return ShadCard(
      title: Text(
        'Quotes',
        style: theme.textTheme.h4,
      ),
      child: Consumer<QuoteProvider>(
        builder: (context, quoteProvider, _) {
          if (quoteProvider.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.itemSpacing),
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (quoteProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.itemSpacing),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.destructive,
                      size: 48,
                    ),
                    const SizedBox(height: AppConstants.textSpacing),
                    Text(
                      'Error loading quotes',
                      style: theme.textTheme.h4.copyWith(
                        color: theme.colorScheme.destructive,
                      ),
                    ),
                    const SizedBox(height: AppConstants.textSpacing),
                    Text(
                      quoteProvider.error!,
                      style: theme.textTheme.p.copyWith(
                        color: theme.colorScheme.destructive,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          final quotes = quoteProvider.jobQuotes;
          
          if (quotes == null || quotes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.itemSpacing),
                child: Column(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: theme.colorScheme.mutedForeground,
                      size: 48,
                    ),
                    const SizedBox(height: AppConstants.textSpacing),
                    Text(
                      'No quotes yet for this job',
                      style: theme.textTheme.p.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quotes.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return QuoteCard(
                quote: quotes[index],
                onTap: () {
                  // View quote details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Viewing quote from ${quotes[index].provider.name}'),
                    ),
                  );
                },
                onAccept: job.status == 'open' ? () => _handleQuoteAction(
                  context, 
                  quotes[index], 
                  'accepted',
                ) : null,
                onReject: job.status == 'open' ? () => _handleQuoteAction(
                  context, 
                  quotes[index], 
                  'rejected',
                ) : null,
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildDetailRow(
    BuildContext context,
    ShadThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.textSpacing,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppConstants.iconSize,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppConstants.textSpacing),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.p.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.p,
            ),
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

  Widget _buildStatusBadge(String status, ShadThemeData theme) {
    Color badgeColor;
    
    switch (status) {
      case 'open':
        badgeColor = Colors.blue;
        break;
      case 'in_progress':
        badgeColor = Colors.orange;
        break;
      case 'completed':
        badgeColor = Colors.green;
        break;
      case 'cancelled':
        badgeColor = Colors.red;
        break;
      default:
        badgeColor = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
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
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'painting':
        return Icons.format_paint;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'gardening':
        return Icons.yard;
      case 'carpentry':
        return Icons.handyman;
      case 'roofing':
        return Icons.roofing;
      default:
        return Icons.home_repair_service;
    }
  }
} 