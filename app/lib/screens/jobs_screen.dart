import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:proquote/providers/auth_provider.dart';
import 'package:proquote/providers/job_provider.dart';
import 'package:proquote/widgets/job_card.dart';
import 'package:proquote/widgets/swipeable_job_card.dart';
import 'package:proquote/widgets/app_header.dart';
import 'package:proquote/utils/constants.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    // Load jobs when the screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobs();
    });
    
    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreJobs();
    }
  }

  void _loadJobs() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      jobProvider.loadUserJobs(authProvider.currentUser!.uid);
    }
  }
  
  void _loadMoreJobs() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
    // Don't load more if we're already loading or there are no more jobs
    if (jobProvider.isLoadingMore || !jobProvider.hasMoreJobs || _isLoadingMore) {
      return;
    }
    
    setState(() {
      _isLoadingMore = true;
    });
    
    if (authProvider.currentUser != null) {
      jobProvider.loadMoreUserJobs(authProvider.currentUser!.uid).then((_) {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }
  
  Future<void> _refreshJobs() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await jobProvider.refreshUserJobs(authProvider.currentUser!.uid);
    }
  }

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
      appBar: AppHeader(
        title: 'My Jobs',
        centerTitle: isLargeScreen,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.add_outlined),
            onPressed: () {
              context.go('/create-job');
            },
            tooltip: 'Create Job',
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: Consumer<JobProvider>(
            builder: (context, jobProvider, _) {
              if (jobProvider.isLoading && (jobProvider.userJobs == null || jobProvider.userJobs!.isEmpty)) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (jobProvider.error != null && (jobProvider.userJobs == null || jobProvider.userJobs!.isEmpty)) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${jobProvider.error}'),
                      const SizedBox(height: 16),
                      ShadButton(
                        child: const Text('Retry'),
                        onPressed: _loadJobs,
                      ),
                    ],
                  ),
                );
              }
              
              final jobs = jobProvider.userJobs;
              
              if (jobs == null || jobs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('You have no jobs yet'),
                      const SizedBox(height: 16),
                      ShadButton(
                        child: const Text('Create a Job'),
                        onPressed: () {
                          context.go('/create-job');
                        },
                      ),
                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: _refreshJobs,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppConstants.screenPadding),
                  itemCount: jobs.length + (jobProvider.hasMoreJobs ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show loading indicator at the bottom
                    if (index == jobs.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    
                    final job = jobs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.itemSpacing),
                      child: SwipeableJobCard(
                        job: job,
                        onTap: () {
                          context.go('/job/${job.id}');
                        },
                        onArchive: (job) {
                          // Archive job
                          jobProvider.updateJobStatus(job.id, 'archived').then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Job archived'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    jobProvider.updateJobStatus(job.id, 'open');
                                  },
                                ),
                              ),
                            );
                          });
                        },
                        onShare: (job) {
                          // Share job
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sharing not implemented yet'),
                            ),
                          );
                        },
                        onEdit: (job) {
                          // Edit job
                          context.go('/edit-job/${job.id}');
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 