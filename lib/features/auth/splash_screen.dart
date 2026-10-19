// [A] 02 시작·회원가입 > 스플래시 화면 (디자인: Splash)
import 'dart:async';

import 'package:flutter/material.dart';

import '../../common/main_tab_screen.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import 'widgets/auth_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _moved = false;

  @override
  void initState() {
    super.initState();
    // 잠깐 보여준 뒤 자동으로 넘어간다. 화면을 누르면 바로 넘어간다.
    _timer = Timer(const Duration(milliseconds: 1500), _goNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 로그인되어 있으면 홈(하단 탭), 아니면 로그인 화면
  void _goNext() {
    if (_moved || !mounted) return;
    _moved = true;
    final next = AuthService.instance.isSignedIn
        ? const MainTabScreen()
        : const LoginScreen();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => next,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goNext,
        child: SafeArea(
          child: Center(
            child: Transform.translate(
              offset: const Offset(0, -8),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrandLogoMark(size: 76),
                  SizedBox(height: 14),
                  Text(
                    '스팩타클',
                    style: TextStyle(
                      color: AuthColors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.96,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '우리 학교 선배의 진짜 취업 이야기',
                    style: TextStyle(
                      color: AuthColors.gray8E,
                      fontSize: 11,
                      letterSpacing: -0.22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
