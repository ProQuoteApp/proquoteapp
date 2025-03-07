#!/bin/bash

# Script to help set up Firebase configuration files

echo "ProQuote Firebase Setup Helper"
echo "=============================="
echo

# Check if firebase_options.dart exists
if [ -f "lib/firebase_options.dart" ]; then
  echo "⚠️  Warning: lib/firebase_options.dart already exists."
  read -p "Do you want to overwrite it? (y/n): " overwrite
  if [ "$overwrite" != "y" ]; then
    echo "Skipping firebase_options.dart setup."
  else
    echo "Creating firebase_options.dart from template..."
    cp lib/firebase_options_template.dart lib/firebase_options.dart
    echo "✅ Created lib/firebase_options.dart from template."
    echo "⚠️  Please edit lib/firebase_options.dart and replace placeholder values with your actual Firebase configuration."
  fi
else
  echo "Creating firebase_options.dart from template..."
  cp lib/firebase_options_template.dart lib/firebase_options.dart
  echo "✅ Created lib/firebase_options.dart from template."
  echo "⚠️  Please edit lib/firebase_options.dart and replace placeholder values with your actual Firebase configuration."
fi

echo
echo "Firebase Configuration Checklist:"
echo "--------------------------------"
echo "1. [ ] Regenerate API keys in Firebase Console"
echo "2. [ ] Update lib/firebase_options.dart with new values"
echo "3. [ ] Download and place GoogleService-Info.plist in ios/Runner/ and macos/Runner/"
echo "4. [ ] Download and place google-services.json in android/app/"
echo
echo "For detailed instructions, please read FIREBASE_SETUP.md"
echo
echo "Remember: NEVER commit these configuration files to version control!" 