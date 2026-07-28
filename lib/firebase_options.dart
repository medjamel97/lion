// Placeholder Firebase configuration.
//
// To connect the app to YOUR Firebase project, run:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// which regenerates this file with your real project keys. Until then the
// app detects the placeholder and automatically runs in on-device storage
// mode, so you can use every feature immediately.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  /// True once `flutterfire configure` has replaced this file.
  static const bool isConfigured = false;

  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'firebase_options.dart is a placeholder. Run `flutterfire configure` '
      'to generate real options for your Firebase project.',
    );
  }
}
