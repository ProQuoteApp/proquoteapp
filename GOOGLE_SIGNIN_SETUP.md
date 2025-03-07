# Google Sign-In Setup Instructions

To enable Google Sign-In for your ProQuote app, you need to configure OAuth client IDs in the Google Cloud Console.

## Web Platform Setup

1. Go to the [Google Cloud Console](https://console.cloud.google.com/apis/credentials?project=proquote-77221)

2. Select your project (proquote-77221)

3. Navigate to "APIs & Services" > "Credentials"

4. Click on "Create Credentials" > "OAuth client ID"

5. Select "Web application" as the application type

6. Give it a name (e.g., "ProQuote Web Client")

7. Add authorized JavaScript origins:
   - For development: `http://localhost:3000`, `http://localhost:5000`, `http://localhost:8080`
   - For production: Add your production domain

8. Add authorized redirect URIs:
   - For development: `http://localhost:3000`, `http://localhost:5000`, `http://localhost:8080`
   - For production: Add your production domain

9. Click "Create"

10. Copy the generated client ID

11. Open `app/web/index.html` and update the Google Sign-In meta tag:
    ```html
    <meta name="google-signin-client_id" content="YOUR_CLIENT_ID.apps.googleusercontent.com">
    ```

## Android Platform Setup

1. In the Google Cloud Console, go to "APIs & Services" > "Credentials"

2. Click on "Create Credentials" > "OAuth client ID"

3. Select "Android" as the application type

4. Give it a name (e.g., "ProQuote Android Client")

5. Enter your package name (e.g., `com.example.app`)

6. Generate a SHA-1 certificate fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

7. Enter the SHA-1 certificate fingerprint

8. Click "Create"

## iOS Platform Setup

1. In the Google Cloud Console, go to "APIs & Services" > "Credentials"

2. Click on "Create Credentials" > "OAuth client ID"

3. Select "iOS" as the application type

4. Give it a name (e.g., "ProQuote iOS Client")

5. Enter your bundle ID (e.g., `com.example.app`)

6. Click "Create"

## Testing Google Sign-In

After setting up the OAuth client IDs, you should test Google Sign-In on each platform:

```bash
# For web
flutter run -d chrome

# For Android
flutter run -d android

# For iOS
flutter run -d ios
```

## Troubleshooting

If you encounter issues with Google Sign-In:

1. Make sure the client ID in `web/index.html` is correct
2. Verify that the package name/bundle ID matches what you configured in the Google Cloud Console
3. Check that you've added the correct SHA-1 fingerprint for Android
4. Ensure that the authorized JavaScript origins and redirect URIs are correctly set for web 