// [공통-A] Firebase 연결 설정 (프로젝트 spectacle-22290의 안드로이드·아이폰 앱 정보). flutterfire configure 결과로 만든 파일이라 직접 고치지 않는다
// 여기 있는 apiKey는 비밀번호가 아니라 어느 Firebase 프로젝트인지 알려주는 이름표다. 데이터는 Firestore 보안 규칙으로 지킨다.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('웹은 Firebase 연결을 설정하지 않았습니다.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('이 기기는 Firebase 연결을 설정하지 않았습니다.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAWg4qJLz7e_HDXi-ftqWAuVB4u2b8MDLo',
    appId: '1:350680094323:android:cc6b876c5d6f025b7f3c06',
    messagingSenderId: '350680094323',
    projectId: 'spectacle-22290',
    storageBucket: 'spectacle-22290.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBglUh9DyDd9M1rZQ_nu_IrF9H-gGZFNbo',
    appId: '1:350680094323:ios:d286aca1feaa1dc97f3c06',
    messagingSenderId: '350680094323',
    projectId: 'spectacle-22290',
    storageBucket: 'spectacle-22290.firebasestorage.app',
    iosBundleId: 'com.example.spectacle',
  );
}
