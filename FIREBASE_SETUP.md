# Firebase Setup Instructions

This document provides instructions on how to properly set up Firebase for the ProQuote app.

## Security Notice

Firebase configuration files contain API keys and other sensitive information. These files should **never** be committed to version control. We've added them to `.gitignore` to prevent accidental commits.

## Setup Steps

### 1. Download Configuration Files

1. Go to the [Firebase Console](https://console.firebase.google.com/project/proquote-77221/overview)
2. Navigate to Project Settings (gear icon in the top left)

#### For Android:
- Click on the Android app
- Click "Download google-services.json"
- Save this file to `app/android/app/google-services.json`

#### For iOS:
- Click on the iOS app
- Click "Download GoogleService-Info.plist"
- Save this file to `app/ios/Runner/GoogleService-Info.plist`

#### For macOS (if needed):
- Register a macOS app if you haven't already
- Download the GoogleService-Info.plist
- Save it to `app/macos/Runner/GoogleService-Info.plist`

### 2. Update Firebase Options

1. Run the extraction script to see the values from your configuration files:
   ```
   ./extract_firebase_config.sh
   ```

2. Open `app/lib/firebase_options.dart`

3. Update the values for each platform with the values from your configuration files

### 3. Test Your Configuration

Run the app on each platform to ensure Firebase is properly configured:

```
flutter run -d chrome      # For web
flutter run -d android     # For Android
flutter run -d ios         # For iOS
flutter run -d macos       # For macOS
```

## Regenerating API Keys

If you need to regenerate your Firebase API keys (e.g., if they were accidentally exposed):

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to "APIs & Services" > "Credentials"
3. Find your API keys and regenerate them
4. Download new configuration files and update your Firebase options

## Additional Security Measures

- Consider adding API key restrictions in the Firebase Console
- Implement proper Firebase Security Rules
- For production, consider using environment variables or a more robust secrets management solution 