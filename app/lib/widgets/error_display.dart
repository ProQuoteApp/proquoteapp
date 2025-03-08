import 'package:flutter/material.dart';

/// A reusable widget for displaying error messages consistently across the app
class ErrorDisplay extends StatelessWidget {
  /// The error message to display
  final String message;
  
  /// The type of error to display
  final ErrorType type;
  
  /// Optional action button
  final Widget? actionButton;
  
  /// Optional callback when the error is dismissed
  final VoidCallback? onDismiss;
  
  /// Whether the error can be dismissed
  final bool isDismissible;

  /// Constructor
  const ErrorDisplay({
    super.key,
    required this.message,
    this.type = ErrorType.error,
    this.actionButton,
    this.onDismiss,
    this.isDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_getIcon(), color: _getIconColor()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(color: _getTextColor()),
                ),
                if (actionButton != null) ...[
                  const SizedBox(height: 8),
                  actionButton!,
                ],
              ],
            ),
          ),
          if (isDismissible)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: _getIconColor(),
            ),
        ],
      ),
    );
  }
  
  /// Get the appropriate icon based on error type
  IconData _getIcon() {
    switch (type) {
      case ErrorType.error:
        return Icons.error_outline;
      case ErrorType.warning:
        return Icons.warning_amber_rounded;
      case ErrorType.info:
        return Icons.info_outline;
      case ErrorType.success:
        return Icons.check_circle_outline;
    }
  }
  
  /// Get the appropriate background color based on error type
  Color _getBackgroundColor() {
    switch (type) {
      case ErrorType.error:
        return Colors.red.shade50;
      case ErrorType.warning:
        return Colors.orange.shade50;
      case ErrorType.info:
        return Colors.blue.shade50;
      case ErrorType.success:
        return Colors.green.shade50;
    }
  }
  
  /// Get the appropriate border color based on error type
  Color _getBorderColor() {
    switch (type) {
      case ErrorType.error:
        return Colors.red.shade200;
      case ErrorType.warning:
        return Colors.orange.shade200;
      case ErrorType.info:
        return Colors.blue.shade200;
      case ErrorType.success:
        return Colors.green.shade200;
    }
  }
  
  /// Get the appropriate icon color based on error type
  Color _getIconColor() {
    switch (type) {
      case ErrorType.error:
        return Colors.red.shade800;
      case ErrorType.warning:
        return Colors.orange.shade800;
      case ErrorType.info:
        return Colors.blue.shade800;
      case ErrorType.success:
        return Colors.green.shade800;
    }
  }
  
  /// Get the appropriate text color based on error type
  Color _getTextColor() {
    switch (type) {
      case ErrorType.error:
        return Colors.red.shade800;
      case ErrorType.warning:
        return Colors.orange.shade800;
      case ErrorType.info:
        return Colors.blue.shade800;
      case ErrorType.success:
        return Colors.green.shade800;
    }
  }
}

/// Types of errors that can be displayed
enum ErrorType {
  /// Critical error
  error,
  
  /// Warning message
  warning,
  
  /// Informational message
  info,
  
  /// Success message
  success,
} 