import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  //  Firebase config.

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCEuc4V16aqzq2FVNF_9SDTuomdLX_PF04',
    appId: '1:1019314046926:web:46623b8c8e323aed418d9f',
    messagingSenderId: '1019314046926',
    projectId: 'kigali-services-6d7e1',
    authDomain: 'kigali-services-6d7e1.firebaseapp.com',
    storageBucket: 'kigali-services-6d7e1.firebasestorage.app',
    measurementId: 'G-V6YF2F23E5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCx5WbETp5LPDuZb1Si6fOGApulFMHeACM',
    appId: '1:1019314046926:android:26eaf46a886e8bcf418d9f',
    messagingSenderId: '1019314046926',
    projectId: 'kigali-services-6d7e1',
    storageBucket: 'kigali-services-6d7e1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCirzJtnAMqbeuNW_Mk0bV52H-k6qEU8yc',
    appId: '1:1019314046926:ios:1059d8f40e73c37a418d9f',
    messagingSenderId: '1019314046926',
    projectId: 'kigali-services-6d7e1',
    storageBucket: 'kigali-services-6d7e1.firebasestorage.app',
    iosBundleId: 'com.example.kigaliServices',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCirzJtnAMqbeuNW_Mk0bV52H-k6qEU8yc',
    appId: '1:1019314046926:ios:1059d8f40e73c37a418d9f',
    messagingSenderId: '1019314046926',
    projectId: 'kigali-services-6d7e1',
    storageBucket: 'kigali-services-6d7e1.firebasestorage.app',
    iosBundleId: 'com.example.kigaliServices',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCEuc4V16aqzq2FVNF_9SDTuomdLX_PF04',
    appId: '1:1019314046926:web:b164c890b2b91f6c418d9f',
    messagingSenderId: '1019314046926',
    projectId: 'kigali-services-6d7e1',
    authDomain: 'kigali-services-6d7e1.firebaseapp.com',
    storageBucket: 'kigali-services-6d7e1.firebasestorage.app',
    measurementId: 'G-VM536HF6QP',
  );
}
