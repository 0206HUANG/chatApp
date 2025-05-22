import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  // Firebase configuration for Web platform
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDjyLbU5AWAEGqjOxK1f9AojrAS9U-zCDc',
    appId: '1:86982231047:web:76b638a314d6311a7ed6a2',
    messagingSenderId: '86982231047',
    projectId: 'chatapp-a2992',
    authDomain: 'chatapp-a2992.firebaseapp.com',
    storageBucket: 'chatapp-a2992.firebasestorage.app',
    measurementId: 'G-5C7J7LBB31',
  );

  // Firebase configuration for Android platform
  // Note: Since the user only provided Web configuration, the same values are used here
  // In a real project, values from google-services.json should be used
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDjyLbU5AWAEGqjOxK1f9AojrAS9U-zCDc',
    appId: '1:86982231047:web:76b638a314d6311a7ed6a2',
    messagingSenderId: '86982231047',
    projectId: 'chatapp-a2992',
    storageBucket: 'chatapp-a2992.firebasestorage.app',
  );

  // Firebase configuration for iOS platform
  // Note: Since the user only provided Web configuration, the same values are used here
  // In a real project, values from GoogleService-Info.plist should be used
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDjyLbU5AWAEGqjOxK1f9AojrAS9U-zCDc',
    appId: '1:86982231047:web:76b638a314d6311a7ed6a2',
    messagingSenderId: '86982231047',
    projectId: 'chatapp-a2992',
    storageBucket: 'chatapp-a2992.firebasestorage.app',
    iosClientId:
        '86982231047-iosapp.apps.googleusercontent.com', // Should be retrieved from GoogleService-Info.plist
    iosBundleId: 'com.example.chat',
  );

  // Firebase configuration for macOS platform
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDjyLbU5AWAEGqjOxK1f9AojrAS9U-zCDc',
    appId: '1:86982231047:web:76b638a314d6311a7ed6a2',
    messagingSenderId: '86982231047',
    projectId: 'chatapp-a2992',
    storageBucket: 'chatapp-a2992.firebasestorage.app',
    iosClientId:
        '86982231047-macosapp.apps.googleusercontent.com', // Should be retrieved from GoogleService-Info.plist
    iosBundleId: 'com.example.chat',
  );
}
