import 'dart:io';
import 'package:flutter/foundation.dart';

/// Helper class for platform-specific functionality
class PlatformHelper {
  /// Check if the app is running on web
  static bool get isWeb => kIsWeb;
  
  /// Check if the app is running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  
  /// Check if the app is running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  
  /// Check if the app is running on macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  
  /// Check if the app is running on Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  
  /// Check if the app is running on Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  
  /// Check if the app is running on a mobile device
  static bool get isMobile => isAndroid || isIOS;
  
  /// Check if the app is running on a desktop device
  static bool get isDesktop => isMacOS || isWindows || isLinux;
  
  /// Get the current platform name
  static String get platformName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isMacOS) return 'macOS';
    if (isWindows) return 'Windows';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }
  
  /// Get platform-specific configuration
  static Map<String, dynamic> getPlatformConfig() {
    if (isWeb) {
      return {
        'supportsGoogleSignIn': true,
        'supportsAppleSignIn': false,
        'supportsPhoneAuth': true,
        'requiresLocationPermission': false,
        'requiresNotificationPermission': false,
      };
    } else if (isAndroid) {
      return {
        'supportsGoogleSignIn': true,
        'supportsAppleSignIn': false,
        'supportsPhoneAuth': true,
        'requiresLocationPermission': true,
        'requiresNotificationPermission': true,
      };
    } else if (isIOS) {
      return {
        'supportsGoogleSignIn': true,
        'supportsAppleSignIn': true,
        'supportsPhoneAuth': true,
        'requiresLocationPermission': true,
        'requiresNotificationPermission': true,
      };
    } else {
      // Desktop platforms
      return {
        'supportsGoogleSignIn': false,
        'supportsAppleSignIn': false,
        'supportsPhoneAuth': false,
        'requiresLocationPermission': false,
        'requiresNotificationPermission': false,
      };
    }
  }
  
  /// Check if a specific feature is supported on the current platform
  static bool isFeatureSupported(String feature) {
    final config = getPlatformConfig();
    return config.containsKey(feature) ? config[feature] : false;
  }
} 