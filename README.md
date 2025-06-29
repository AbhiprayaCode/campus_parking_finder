# Campus Parking Finder

Campus Parking Finder is a Flutter application that helps users find, reserve, and manage parking spots on campus in real-time. The app leverages Google Maps and Firebase to provide an efficient and modern parking experience.

## Features

- **Search Parking Spots:** Find available parking locations on campus.
- **Reserve Parking:** Book a parking spot directly from the app.
- **Real-Time Availability:** View the status (available, booked, yours) of each parking spot in real-time.
- **Interactive Map:** Google Maps integration for easy navigation.
- **User Authentication:** Secure login and registration.
- **Reservation History:** Track your past and current reservations.

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) (for iOS)
- Firebase account (for backend services)

### Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd campus_parking_finder
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective folders.
4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
  main.dart
  models/
  screens/
  services/
  widgets/
assets/
  icons/
  images/
```

## Built With

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Google Maps](https://pub.dev/packages/google_maps_flutter)

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License.

