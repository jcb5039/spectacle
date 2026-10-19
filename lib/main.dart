// [공통-A] 앱 시작점: Firebase를 켜고, 가짜 기능 대신 실제 Firebase 기능을 쓰도록 바꾼 뒤 앱을 띄운다
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/photo_service.dart';
import 'services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 랭킹·내 글(RankingService)은 B의 후기·질문이 서버에 올라간 뒤 바꾼다
  AuthService.instance = FirebaseAuthService();
  UserService.instance = FirestoreUserService();
  PhotoService.instance = FirebasePhotoService();

  runApp(const SpectacleApp());
}
