import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:proquote/providers/auth_provider.dart';
import 'package:proquote/providers/job_provider.dart';
import 'package:proquote/widgets/job_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  @override
  void initState() {
    super.initState();
    // Load jobs when the screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobs();
    });
  }

  void _loadJobs() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      jobProvider.loadUserJobs(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),
        actions: [
          ShadIconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go('/create-job');
            },
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, _) {
          if (jobProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (jobProvider.error != null) {
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
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return JobCard(
                job: job,
                onTap: () {
                  context.go('/job/${job.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
} 