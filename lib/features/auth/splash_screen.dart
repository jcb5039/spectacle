// [A] 02 시작·회원가입 > 스플래시 화면 (디자인: Splash)
import 'dart:async';

import 'package:flutter/material.dart';

import '../../common/main_tab_screen.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
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
  // (서버에서 지워진 계정이면 로그아웃되어 로그인 화면으로 간다)
  // (회원 정보가 없는, 가입을 끝내지 못한 계정도 로그아웃되어 로그인 화면으로 간다)
  Future<void> _goNext() async {
    if (_moved || !mounted) return;
    _moved = true;
    var signedIn = await AuthService.instance.checkSignedIn();
    if (signedIn && !await _hasProfile()) {
      await AuthService.instance.signOut();
      signedIn = false;
    }
    if (!mounted) return;
    final next = signedIn ? const MainTabScreen() : const LoginScreen();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => next,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  // 회원 정보가 있는지. 인터넷이 끊겨 확인하지 못하면 정상 회원이 쫓겨나지 않게 있다고 본다
  Future<bool> _hasProfile() async {
    final userId = AuthService.instance.currentUserId;
    if (userId == null) return false;
    try {
      return await UserService.instance.getUser(userId) != null;
    } catch (_) {
      return true;
    }
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
