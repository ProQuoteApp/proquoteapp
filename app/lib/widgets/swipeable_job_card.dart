import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proquote/models/job.dart';
import 'package:proquote/widgets/job_card.dart';
import 'package:proquote/providers/job_provider.dart';
import 'package:provider/provider.dart';

/// A widget that wraps a JobCard with swipe actions
class SwipeableJobCard extends StatelessWidget {
  /// The job to display
  final Job job;
  
  /// Callback when the card is tapped
  final VoidCallback onTap;
  
  /// Callback when the job is archived
  final Function(Job)? onArchive;
  
  /// Callback when the job is shared
  final Function(Job)? onShare;
  
  /// Callback when the job is edited
  final Function(Job)? onEdit;
  
  /// Constructor
  const SwipeableJobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onArchive,
    this.onShare,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('job-${job.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Archive action
          HapticFeedback.mediumImpact();
          if (onArchive != null) {
            onArchive!(job);
          }
          return false; // Don't actually dismiss
        } else {
          // Share action
          HapticFeedback.mediumImpact();
          if (onShare != null) {
            onShare!(job);
          }
          return false; // Don't actually dismiss
        }
      },
      background: _buildArchiveBackground(),
      secondaryBackground: _buildShareBackground(),
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showActionSheet(context);
        },
        child: JobCard(
          job: job,
          onTap: onTap,
        ),
      ),
    );
  }
  
  Widget _buildArchiveBackground() {
    return Container(
      color: Colors.orange.shade100,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(
            Icons.archive_outlined,
            color: Colors.orange.shade800,
          ),
          const SizedBox(width: 8),
          Text(
            'Archive',
            style: TextStyle(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildShareBackground() {
    return Container(
      color: Colors.blue.shade100,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Share',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.share_outlined,
            color: Colors.blue.shade800,
          ),
        ],
      ),
    );
  }
  
  void _showActionSheet(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  onTap();
                },
              ),
              if (onEdit != null)
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit Job'),
                  onTap: () {
                    Navigator.pop(context);
                    onEdit!(job);
                  },
                ),
              if (onShare != null)
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('Share Job'),
                  onTap: () {
                    Navigator.pop(context);
                    onShare!(job);
                  },
                ),
              if (onArchive != null)
                ListTile(
                  leading: const Icon(Icons.archive_outlined),
                  title: const Text('Archive Job'),
                  onTap: () {
                    Navigator.pop(context);
                    onArchive!(job);
                  },
                ),
              if (job.status == 'open')
                ListTile(
                  leading: const Icon(Icons.cancel_outlined),
                  title: const Text('Cancel Job'),
                  onTap: () {
                    Navigator.pop(context);
                    _showCancelConfirmation(context);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
  
  void _showCancelConfirmation(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Job'),
          content: const Text('Are you sure you want to cancel this job? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                jobProvider.updateJobStatus(job.id, 'cancelled').then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Job cancelled'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                });
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
} 