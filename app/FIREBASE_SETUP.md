# Firebase Configuration Setup

## Security Notice

Firebase configuration files contain API keys and other sensitive information that should not be committed to version control. This project uses a template approach to keep these keys secure.

## Setup Instructions

1. **Regenerate Firebase API Keys**:
   - Go to the [Firebase Console](https://console.firebase.google.com/)
   - Navigate to your project (proquote-77221)
   - Go to Project Settings
   - Under the "General" tab, find the Web API Key and other platform API keys
   - Click on "Regenerate key" for each exposed API key

2. **Update Configuration Files**:
   - Copy `firebase_options_template.dart` to `firebase_options.dart`
   - Replace the placeholder values with your actual Firebase configuration values
   - Make sure not to commit `firebase_options.dart` to version control (it's already in .gitignore)

3. **For iOS and macOS**:
   - Download the updated `GoogleService-Info.plist` from Firebase Console
   - Place it in the appropriate directories:
     - iOS: `ios/Runner/GoogleService-Info.plist`
     - macOS: `macos/Runner/GoogleService-Info.plist`
   - These files are also excluded from version control

4. **For Android**:
   - Download the updated `google-services.json` from Firebase Console
   - Place it in `android/app/google-services.json`
   - This file is also excluded from version control

## For New Team Members

When setting up the project for the first time:

1. Ask a team member for the Firebase configuration files
2. Place them in the appropriate directories as mentioned above
3. Do not commit these files to version control

## Environment Variables (Alternative Approach)

For production builds, consider using environment variables or a secure CI/CD pipeline to inject these values during the build process.

## Security Best Practices

- Never commit API keys or secrets to version control
- Regularly rotate API keys, especially if they may have been exposed
- Use Firebase Security Rules to restrict access to your Firebase resources
- Consider implementing API key restrictions in the Firebase Console 