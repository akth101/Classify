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
    apiKey: 'AIzaSyBuFqK-tFBqfIzIAVVDR1ADB6XAa46u-o4',
    appId: '1:1065933419614:web:07d512686e102b45d130cf',
    messagingSenderId: '1065933419614',
    projectId: 'weathercloset-b7a14',
    authDomain: 'weathercloset-b7a14.firebaseapp.com',
    databaseURL: 'https://weathercloset-b7a14-default-rtdb.firebaseio.com',
    storageBucket: 'weathercloset-b7a14.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAx93q3l1UoFpf4Jsn0QwPIBlhNBwJNJ8U',
    appId: '1:1065933419614:android:6e1e9910de79d113d130cf',
    messagingSenderId: '1065933419614',
    projectId: 'weathercloset-b7a14',
    databaseURL: 'https://weathercloset-b7a14-default-rtdb.firebaseio.com',
    storageBucket: 'weathercloset-b7a14.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_eBOv3OFXAqX0ZKlFEHFQODJFs7wIUJw',
    appId: '1:1065933419614:ios:5402a01cd48e0e55d130cf',
    messagingSenderId: '1065933419614',
    projectId: 'weathercloset-b7a14',
    databaseURL: 'https://weathercloset-b7a14-default-rtdb.firebaseio.com',
    storageBucket: 'weathercloset-b7a14.firebasestorage.app',
    androidClientId: '1065933419614-ibh4uhc0udus26vkd7pomc622gdhl1pj.apps.googleusercontent.com',
    iosClientId: '1065933419614-27haasij3ua19pdnpmcgnvf3dhnqneg0.apps.googleusercontent.com',
    iosBundleId: 'com.example.weathercloset',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB_eBOv3OFXAqX0ZKlFEHFQODJFs7wIUJw',
    appId: '1:1065933419614:ios:5402a01cd48e0e55d130cf',
    messagingSenderId: '1065933419614',
    projectId: 'weathercloset-b7a14',
    databaseURL: 'https://weathercloset-b7a14-default-rtdb.firebaseio.com',
    storageBucket: 'weathercloset-b7a14.firebasestorage.app',
    androidClientId: '1065933419614-ibh4uhc0udus26vkd7pomc622gdhl1pj.apps.googleusercontent.com',
    iosClientId: '1065933419614-27haasij3ua19pdnpmcgnvf3dhnqneg0.apps.googleusercontent.com',
    iosBundleId: 'com.example.weathercloset',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBuFqK-tFBqfIzIAVVDR1ADB6XAa46u-o4',
    appId: '1:1065933419614:web:1161a2cb91a90828d130cf',
    messagingSenderId: '1065933419614',
    projectId: 'weathercloset-b7a14',
    authDomain: 'weathercloset-b7a14.firebaseapp.com',
    databaseURL: 'https://weathercloset-b7a14-default-rtdb.firebaseio.com',
    storageBucket: 'weathercloset-b7a14.firebasestorage.app',
  );

}