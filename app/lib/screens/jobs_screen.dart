import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proquote/utils/constants.dart';
import 'package:proquote/utils/mock_data.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

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
        title: const Text('My Jobs'),
        centerTitle: isLargeScreen,
      ),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.screenPadding),
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
        ),
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