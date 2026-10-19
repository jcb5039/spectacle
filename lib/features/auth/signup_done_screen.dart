// [A] 02 시작·회원가입 > 가입 완료 화면 (디자인: SignUpDone)
import 'package:flutter/material.dart';

import '../../common/main_tab_screen.dart';
import 'widgets/auth_widgets.dart';

class SignUpDoneScreen extends StatelessWidget {
  const SignUpDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthStatusPage(
      icon: Container(
        width: 86,
        height: 86,
        margin: const EdgeInsets.only(bottom: 27),
        decoration: const BoxDecoration(
          color: AuthColors.black,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 38, color: AuthColors.white),
      ),
      kicker: 'WELCOME TO SPECTACLE',
      title: '인증이 완료됐어요',
      message: '우리 학교 선배들의 이야기를 만나보세요.',
      buttonLabel: '시작하기',
      onButtonPressed: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabScreen()),
        (_) => false,
      ),
    );
  }
}
