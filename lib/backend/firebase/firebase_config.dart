import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future<void> initFirebase() async {
  if (kIsWeb) {
    // Pass one project's complete web config with --dart-define-from-file.
    // These are client identifiers, not Admin SDK credentials.
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
    const messagingSenderId = String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
    );
    const appId = String.fromEnvironment('FIREBASE_APP_ID');
    const measurementId = String.fromEnvironment('FIREBASE_MEASUREMENT_ID');
    if ([
      apiKey,
      authDomain,
      projectId,
      messagingSenderId,
      appId,
    ].any((value) => value.isEmpty)) {
      throw StateError(
        'Firebase web configuration is missing. '
        'Use --dart-define-from-file=firebase.web.local.json.',
      );
    }
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: apiKey,
        authDomain: authDomain,
        projectId: projectId,
        storageBucket: storageBucket.isEmpty ? null : storageBucket,
        messagingSenderId: messagingSenderId,
        appId: appId,
        measurementId: measurementId.isEmpty ? null : measurementId,
      ),
    );
  } else {
    // Android/iOS use their native Firebase config files, which are not in
    // this lib-only repository. Replace those files when migrating projects.
    await Firebase.initializeApp();
  }
}
