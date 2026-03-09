#  Kigali Services

A comprehensive Flutter application to discover essential services and places in Kigali city. Find everything from healthcare facilities, educational institutions, to restaurants and entertainment venues with ratings, reviews, and real-time location tracking.

##  Features

-  **User Authentication** - Secure Firebase email/password authentication with email verification
-  **Location & Maps** - Google Maps integration with real-time location tracking
-  **Service Directory** - Browse and search various service categories in Kigali
-  **Ratings & Reviews** - Rate and review services and places
-  **Advanced Search** - Find services by category, location, and ratings
-  **Responsive Design** - Works seamlessly on iOS, Android, and Web
-  **Real-time Data** - Cloud-based data synchronization using Firestore
-  **URL Launcher** - Quick access to phone numbers and websites

##  Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) - Cross-platform mobile development
- **Backend**: [Firebase](https://firebase.google.com/)
  - Authentication (Firebase Auth)
  - Database (Cloud Firestore)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Maps & Location**:
  - [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
  - [Flutter Map](https://pub.dev/packages/flutter_map)
  - [Geolocator](https://pub.dev/packages/geolocator)
  - [LatLong2](https://pub.dev/packages/latlong2)
- **Other Libraries**:
  - URL Launcher for external links
  - Flutter Rating Bar for ratings
  - Permission Handler for device permissions
  - Intl for internationalization
  - UUID for unique identifiers

##  Prerequisites

Before running this project, make sure you have installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.6.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- An IDE: [Android Studio](https://developer.android.com/studio), [VS Code](https://code.visualstudio.com/), or [Xcode](https://developer.apple.com/xcode/)
- [Firebase Account](https://console.firebase.google.com/) for backend services
- A device or emulator for testing

##  Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd kigali_services
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an Android app to your Firebase project
3. Download `google-services.json` and place it in `android/app/`
4. Add an iOS app (optional) and download `GoogleService-Info.plist`
5. Place `GoogleService-Info.plist` in `ios/Runner/Runner/`

### 4. Run the App

```bash
# Development
flutter run

# Release mode
flutter run --release

# Specific platform
flutter run -d chrome    # Web
flutter run -d android   # Android emulator/device
flutter run -d ios       # iOS simulator
```

##  Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
├── providers/                # State management (Provider)
│   ├── auth_provider.dart
│   ├── listing_provider.dart
│   └── interaction_provider.dart
├── repositories/             # Data repositories
├── screens/                  # UI Screens
│   ├── auth/                # Authentication screens
│   │   ├── login_screen.dart
│   │   └── verify_email_screen.dart
│   ├── home_shell.dart
│   └── ...
├── services/                 # Business logic & API services
│   ├── mock_data_service.dart
│   └── ...
└── widgets/                  # Reusable UI components
```

##  Getting Started

### Authentication Flow
1. User signs up with email and password
2. Email verification link is sent
3. After verification, user can log in
4. Access to main app features

### Browsing Services
1. Select a service category
2. View nearby services on map
3. Check details, ratings, and reviews
4. Contact directly via phone or website

### Leaving Reviews
1. Select a service
2. Rate on 1-5 star scale
3. Write optional review text
4. Submit rating

##  Configuration

### Firebase Rules (Optional)
Edit `firestore.rules` and `firebase.json` to customize your Firestore security rules.

### Google Maps API
Ensure your Google Maps API key is properly configured:
- Android: `android/app/build.gradle` or `AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`
- Web: `web/index.html`

### Permissions
The app requests the following permissions:
- **Location**: For map and location-based services
- **Camera**: (If profile photos are enabled)

## Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Package Guide](https://pub.dev/packages/provider)
- [Google Maps Flutter Docs](https://pub.dev/packages/google_maps_flutter)

##  Troubleshooting

### Build Issues
```bash
# Clean build
flutter clean
flutter pub get
flutter run

# Update packages
flutter pub upgrade
```

### Firebase Connection Issues
- Verify `google-services.json` is in correct location
- Check Firebase project settings and app registration
- Ensure internet connectivity

### Map Display Issues
- Confirm Google Maps API key is valid
- Verify API key has Maps SDK for Android/iOS enabled
- Check device location permissions are granted

## License

This project is licensed under the MIT License - see the LICENSE file for details.

##  AUTHOR : NEHEMIE ISHIMWE


## Support

For issues, questions, or suggestions, please open an issue in the repository.


