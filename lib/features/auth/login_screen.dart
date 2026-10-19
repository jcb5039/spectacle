// [A] 02 시작·회원가입 > 로그인 화면 (디자인: Login)
import 'package:flutter/material.dart';

import '../../common/main_tab_screen.dart';
import '../../services/auth_service.dart';
import 'signup_type_screen.dart';
import 'widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabScreen()),
        (_) => false,
      );
    } on AuthFailure catch (failure) {
      // 로그인 실패 디자인이 없어서 임시로 아래쪽 안내 문구를 띄운다
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 45, 25, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        BrandLogoMark(size: 40),
                        SizedBox(width: 10),
                        Text(
                          '스팩타클',
                          style: TextStyle(
                            color: AuthColors.black,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 38),
                    const Text(
                      '선배의 경험이\n나의 다음이 되는 곳.',
                      style: TextStyle(
                        color: AuthColors.black,
                        fontSize: 29,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.885,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 11),
                    const Text(
                      '대림대학교 선후배 취업 커뮤니티',
                      style: TextStyle(color: AuthColors.gray8E, fontSize: 12),
                    ),
                    const SizedBox(height: 55),
                    UnderlineTextField(
                      label: '이메일',
                      hint: '이메일을 입력해주세요',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 11),
                    ),
                    const SizedBox(height: 6),
                    UnderlineTextField(
                      label: '비밀번호',
                      hint: '비밀번호를 입력해주세요',
                      controller: _passwordController,
                      obscureText: true,
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 11),
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    AuthPrimaryButton(
                      label: '로그인',
                      height: 52,
                      onPressed: _login,
                    ),
                    const SizedBox(height: 19),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpTypeScreen(),
                          ),
                        ),
                        child: const Text.rich(
                          TextSpan(
                            style: TextStyle(
                              color: AuthColors.gray8E,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(text: '아직 회원이 아니신가요? '),
                              TextSpan(
                                text: '회원가입',
                                style: TextStyle(
                                  color: AuthColors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
