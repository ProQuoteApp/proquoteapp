import 'package:flutter/material.dart';
import 'package:proquote/utils/constants.dart';
import 'package:proquote/widgets/app_header.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

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
        title: 'Messages',
        centerTitle: isLargeScreen,
      ),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: AppConstants.itemSpacing),
                Text(
                  'No messages yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: AppConstants.textSpacing),
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
        ),
      ),
    );
  }
} 