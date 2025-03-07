#!/bin/bash

echo "Firebase Configuration Extractor"
echo "==============================="
echo

# Check for Android config
if [ -f "app/android/app/google-services.json" ]; then
  echo "Android Configuration:"
  echo "---------------------"
  echo "API Key: $(grep -o '"api_key":\[{"current_key":"[^"]*' app/android/app/google-services.json | sed 's/"api_key":\[{"current_key":"//')"
  echo "App ID: $(grep -o '"mobilesdk_app_id": "[^"]*' app/android/app/google-services.json | sed 's/"mobilesdk_app_id": "//')"
  echo "Project ID: $(grep -o '"project_id": "[^"]*' app/android/app/google-services.json | sed 's/"project_id": "//')"
  echo "Storage Bucket: $(grep -o '"storage_bucket": "[^"]*' app/android/app/google-services.json | sed 's/"storage_bucket": "//')"
  echo "Messaging Sender ID: $(grep -o '"project_number": "[^"]*' app/android/app/google-services.json | sed 's/"project_number": "//')"
  echo
else
  echo "Android configuration file not found at app/android/app/google-services.json"
  echo
fi

# Check for iOS config
if [ -f "app/ios/Runner/GoogleService-Info.plist" ]; then
  echo "iOS Configuration:"
  echo "-----------------"
  echo "API Key: $(grep -A1 "<key>API_KEY</key>" app/ios/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')"
  echo "App ID: $(grep -A1 "<key>BUNDLE_ID</key>" app/ios/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')"
  echo "Project ID: $(grep -A1 "<key>PROJECT_ID</key>" app/ios/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')"
  echo "Storage Bucket: $(grep -A1 "<key>STORAGE_BUCKET</key>" app/ios/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')"
  echo "Messaging Sender ID: $(grep -A1 "<key>GCM_SENDER_ID</key>" app/ios/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')"
  echo "iOS Bundle ID: $(grep -A1 "<key>BUNDLE_ID</key>" app/ios/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')"
  echo
else
  echo "iOS configuration file not found at app/ios/Runner/GoogleService-Info.plist"
  echo
fi

# Check for macOS config
if [ -f "app/macos/Runner/GoogleService-Info.plist" ]; then
  echo "macOS Configuration:"
  echo "-------------------"
  echo "API Key: $(grep -A1 "<key>API_KEY</key>" app/macos/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')"
  echo "App ID: $(grep -A1 "<key>BUNDLE_ID</key>" app/macos/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')"
  echo "Project ID: $(grep -A1 "<key>PROJECT_ID</key>" app/macos/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')"
  echo "Storage Bucket: $(grep -A1 "<key>STORAGE_BUCKET</key>" app/macos/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')"
  echo "Messaging Sender ID: $(grep -A1 "<key>GCM_SENDER_ID</key>" app/macos/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')"
  echo "macOS Bundle ID: $(grep -A1 "<key>BUNDLE_ID</key>" app/macos/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')"
  echo
else
  echo "macOS configuration file not found at app/macos/Runner/GoogleService-Info.plist"
  echo
fi

echo "Web Configuration (from firebase_options.dart):"
echo "---------------------------------------------"
grep -A7 "static const FirebaseOptions web" app/lib/firebase_options.dart 