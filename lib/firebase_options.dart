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
    apiKey: 'AIzaSyDbq0XLbtU68bvG1wxuHEkQ4A0q0xNJrdA',
    appId: '1:281655354801:web:b3aa447a526ec2f4f44990',
    messagingSenderId: '281655354801',
    projectId: 'salon-groom-app',
    authDomain: 'salon-groom-app.firebaseapp.com',
    storageBucket: 'salon-groom-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDc_pFuWkXZiZDCW69r2UoFX-8tW-nbCNo',
    appId: '1:281655354801:android:ecdebd4137d44621f44990',
    messagingSenderId: '281655354801',
    projectId: 'salon-groom-app',
    storageBucket: 'salon-groom-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBmGT32nviq1pXi33yYWStJU7yj_wVg3w4',
    appId: '1:281655354801:ios:235f962debb15ed7f44990',
    messagingSenderId: '281655354801',
    projectId: 'salon-groom-app',
    storageBucket: 'salon-groom-app.appspot.com',
    iosBundleId: 'com.example.walletApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBmGT32nviq1pXi33yYWStJU7yj_wVg3w4',
    appId: '1:281655354801:ios:235f962debb15ed7f44990',
    messagingSenderId: '281655354801',
    projectId: 'salon-groom-app',
    storageBucket: 'salon-groom-app.appspot.com',
    iosBundleId: 'com.example.walletApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDaeFrLGFinP2z4-Q5CpqO91nS0M05w5ro',
    appId: '1:281655354801:web:79b2d4679e34de71f44990',
    messagingSenderId: '281655354801',
    projectId: 'salon-groom-app',
    authDomain: 'salon-groom-app.firebaseapp.com',
    storageBucket: 'salon-groom-app.appspot.com',
    measurementId: 'G-BS56934MD4',
  );

}