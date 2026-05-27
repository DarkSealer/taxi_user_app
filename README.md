# Taxi Driver App

Taxi driver mobile app built with Flutter, Firebase, Google Maps, and geolocation.

## Prerequisites

- Flutter (latest stable)
- Dart SDK (3.4+)
- Android Studio / Xcode toolchains configured
- Firebase project configured for Android/iOS

## Environment Variables

The project uses environment values for API keys.  
Create a local `/.env` file (already ignored by git) with:

```env
GOOGLE_MAPS_API_KEY=REPLACE_WITH_GOOGLE_MAPS_API_KEY
FIREBASE_WEB_API_KEY=REPLACE_WITH_FIREBASE_WEB_API_KEY
```

Important:
- Never commit real keys.
- Rotate keys if they were previously committed.

## Project Setup

1. Install dependencies:
   - `flutter pub get`
2. Configure platform keys:
   - Android: set your Maps key in `android/app/src/main/AndroidManifest.xml`
   - iOS: set your Maps key in `ios/Runner/AppDelegate.swift`
   - Firebase: ensure `android/app/google-services.json` and iOS Firebase config are valid for your project
3. Run the app:
   - `flutter run`

## Quality Checks

- Analyze: `flutter analyze`
- Test: `flutter test`

## Architecture Direction

The codebase is being migrated incrementally to Clean Architecture:
- `lib/core/` for shared primitives
- `lib/features/<feature>/domain|data|presentation` for feature modules
- Legacy code remains during migration and is replaced feature-by-feature
