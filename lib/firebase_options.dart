// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBKn12xWErQpx0I-Y670-KxcGhGSDykCfw',
    appId: '1:393151339240:web:823bc9a4e796cb3941475d',
    messagingSenderId: '393151339240',
    projectId: 'marketconnect-d2dc2',
    authDomain: 'marketconnect-d2dc2.firebaseapp.com',
    storageBucket: 'marketconnect-d2dc2.firebasestorage.app',
    measurementId: 'G-1GV3FZ5CWM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAi1SSCjiXMImWUbz5os7arg4EUcQwUOJQ',
    appId: '1:393151339240:android:56f12b1f2064b4e541475d',
    messagingSenderId: '393151339240',
    projectId: 'marketconnect-d2dc2',
    storageBucket: 'marketconnect-d2dc2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCr7F3cGamunH_LIQ6BFVk6BNY5dV9t6F4',
    appId: '1:393151339240:ios:bc76bb68a184a67141475d',
    messagingSenderId: '393151339240',
    projectId: 'marketconnect-d2dc2',
    storageBucket: 'marketconnect-d2dc2.firebasestorage.app',
    iosBundleId: 'com.example.mcDashboard',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCr7F3cGamunH_LIQ6BFVk6BNY5dV9t6F4',
    appId: '1:393151339240:ios:bc76bb68a184a67141475d',
    messagingSenderId: '393151339240',
    projectId: 'marketconnect-d2dc2',
    storageBucket: 'marketconnect-d2dc2.firebasestorage.app',
    iosBundleId: 'com.example.mcDashboard',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBKn12xWErQpx0I-Y670-KxcGhGSDykCfw',
    appId: '1:393151339240:web:03bc4548f24cc67c41475d',
    messagingSenderId: '393151339240',
    projectId: 'marketconnect-d2dc2',
    authDomain: 'marketconnect-d2dc2.firebaseapp.com',
    storageBucket: 'marketconnect-d2dc2.firebasestorage.app',
    measurementId: 'G-4N6GPCDRGY',
  );
}
