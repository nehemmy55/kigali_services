import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


import 'config/local_config.dart';

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

  // Firebase config loaded from local_config.dart

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: LocalConfig.webApiKey,
    appId: LocalConfig.webAppId,
    messagingSenderId: LocalConfig.webMessagingSenderId,
    projectId: LocalConfig.webProjectId,
    authDomain: LocalConfig.webAuthDomain,
    storageBucket: LocalConfig.webStorageBucket,
    measurementId: LocalConfig.webMeasurementId,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: LocalConfig.androidApiKey,
    appId: LocalConfig.androidAppId,
    messagingSenderId: LocalConfig.androidMessagingSenderId,
    projectId: LocalConfig.androidProjectId,
    storageBucket: LocalConfig.androidStorageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: LocalConfig.iosApiKey,
    appId: LocalConfig.iosAppId,
    messagingSenderId: LocalConfig.iosMessagingSenderId,
    projectId: LocalConfig.iosProjectId,
    storageBucket: LocalConfig.iosStorageBucket,
    iosBundleId: LocalConfig.iosBundleId,
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: LocalConfig.macosApiKey,
    appId: LocalConfig.macosAppId,
    messagingSenderId: LocalConfig.macosMessagingSenderId,
    projectId: LocalConfig.macosProjectId,
    storageBucket: LocalConfig.macosStorageBucket,
    iosBundleId: LocalConfig.macosBundleId,
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: LocalConfig.windowsApiKey,
    appId: LocalConfig.windowsAppId,
    messagingSenderId: LocalConfig.windowsMessagingSenderId,
    projectId: LocalConfig.windowsProjectId,
    authDomain: LocalConfig.windowsAuthDomain,
    storageBucket: LocalConfig.windowsStorageBucket,
    measurementId: LocalConfig.windowsMeasurementId,
  );
}
