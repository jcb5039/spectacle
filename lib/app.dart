// [공통-A] 앱 전체 설정: 테마 적용, 로그인 여부에 따라 첫 화면(스플래시/로그인/홈) 결정
import 'package:flutter/material.dart';

import 'common/main_tab_screen.dart';

class SpectacleApp extends StatelessWidget {
  const SpectacleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '스팩타클',
      debugShowCheckedModeBanner: false,
      // B가 common/theme/app_theme.dart를 만들면 그 테마로 바꾼다.
      theme: ThemeData(
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainTabScreen(),
    );
  }
}
