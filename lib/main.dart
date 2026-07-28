import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/onboarding_screen.dart';
import 'screens/root_shell.dart';
import 'services/storage_service.dart';
import 'state/app_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await _initStorage();
  final appState = AppState(storage: storage);
  await appState.load();

  runApp(LionApp(appState: appState));
}

/// Uses Firebase (anonymous auth + Firestore) when configured, otherwise
/// falls back to on-device storage so the app works out of the box.
Future<StorageService> _initStorage() async {
  if (DefaultFirebaseOptions.isConfigured) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final uid = await ensureSignedIn();
      return FirestoreStorageService(uid: uid);
    } catch (e) {
      debugPrint('Firebase unavailable, falling back to local storage: $e');
    }
  }
  return LocalStorageService();
}

class LionApp extends StatelessWidget {
  final AppState appState;

  const LionApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        title: 'Lion Fitness',
        debugShowCheckedModeBanner: false,
        theme: LionTheme.dark(),
        home: Consumer<AppState>(
          builder: (context, state, _) {
            if (!state.isLoaded) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return state.hasProfile
                ? const RootShell()
                : const OnboardingScreen();
          },
        ),
      ),
    );
  }
}
