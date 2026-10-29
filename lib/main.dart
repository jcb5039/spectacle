// [공통-A] 앱 시작점: Firebase를 켜고, 가짜 기능 대신 실제 Firebase 기능을 쓰도록 바꾼 뒤 앱을 띄운다
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/photo_service.dart';
import 'services/ranking_service.dart';
import 'services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  AuthService.instance = FirebaseAuthService();
  UserService.instance = FirestoreUserService();
  PhotoService.instance = FirebasePhotoService();
  // 랭킹·MY 숫자와 목록: 서버 후기·질문·답변·좋아요로 계산
  RankingService.instance = ServerRankingService();

  runApp(const SpectacleApp());
}
