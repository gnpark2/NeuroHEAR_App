import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '.env';

Future initFirebase() async {
  String apiKey = apiKey;

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: apiKey,
            authDomain: "neurohearauth.firebaseapp.com",
            projectId: "neurohearauth",
            storageBucket: "neurohearauth.appspot.com",
            messagingSenderId: "740204278991",
            appId: "1:740204278991:web:f6e196a25233b051c833ba",
            measurementId: "G-2N8RTNCKYM"));
  } else {
    await Firebase.initializeApp();
  }
}
