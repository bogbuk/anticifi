import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isIOS) {
      return ios;
    } else if (Platform.isAndroid) {
      return android;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANMmtbwnTPeJXCjOR0k4WlZ6KHwM_yScY',
    appId: '1:294067863294:android:5e14ccfc7a2ac92f256faf',
    messagingSenderId: '294067863294',
    projectId: 'anticifi',
    storageBucket: 'anticifi.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZUn0XWZuXRbZo_k8rl3wQsTIwsMDphJ8',
    appId: '1:294067863294:ios:36fbef34ad723df8256faf',
    messagingSenderId: '294067863294',
    projectId: 'anticifi',
    storageBucket: 'anticifi.firebasestorage.app',
    iosBundleId: 'com.anticifi.app',
  );
}
