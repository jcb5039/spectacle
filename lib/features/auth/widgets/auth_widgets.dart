// [A] 02 시작·회원가입 > 시작·회원가입 화면들이 같이 쓰는 부품: 색, 로고, 검정 버튼, 상단 진행 표시, 단계 제목, 입력칸, 하단 버튼 영역, 바텀시트 틀, 완료·대기 화면 틀 (B의 공통 부품이 생기면 바꿀 수 있음)
import 'package:flutter/material.dart';

// 디자인 색상. B가 common/theme/app_colors.dart를 만들면 그쪽으로 바꾼다.
class AuthColors {
  static const black = Color(0xFF111111);
  static const white = Color(0xFFFFFFFF);
  static const gray66 = Color(0xFF666666);
  static const gray77 = Color(0xFF777777);
  static const gray88 = Color(0xFF888888);
  static const gray8E = Color(0xFF8E8E8E);
  static const grayA0 = Color(0xFFA0A0A0);
  static const grayAA = Color(0xFFAAAAAA);
  static const lineD9 = Color(0xFFD9D9D9);
  static const lineDD = Color(0xFFDDDDDD);
  static const lineE5 = Color(0xFFE5E5E5);
  static const lineEE = Color(0xFFEEEEEE);
  static const fillF1 = Color(0xFFF1F1F1);
  static const fillF2 = Color(0xFFF2F2F2);
  static const fillF4 = Color(0xFFF4F4F4);
  static const fillF7 = Color(0xFFF7F7F7);
  static const handle = Color(0xFFD4D4D4);
  static const overlay = Color(0x7A000000);
}

// 스팩타클 로고 (말풍선 두 개 모양)
class BrandLogoMark extends StatelessWidget {
  const BrandLogoMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _BrandLogoPainter());
  }
}

class _BrandLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 44);
    final black = Paint()..color = AuthColors.black;
    final white = Paint()..color = AuthColors.white;
    const r7 = Radius.circular(7);
    const r4 = Radius.circular(4);

    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, 44, 44, const Radius.circular(11)),
      black,
    );
    final upper = Path()
      ..moveTo(10, 11)
      ..lineTo(24, 11)
      ..arcToPoint(const Offset(31, 18), radius: r7)
      ..lineTo(31, 20)
      ..arcToPoint(const Offset(24, 27), radius: r7)
      ..lineTo(18, 27)
      ..lineTo(12, 31.5)
      ..lineTo(12, 27)
      ..arcToPoint(const Offset(7, 20.3), radius: r7)
      ..lineTo(7, 15)
      ..arcToPoint(const Offset(11, 11), radius: r4)
      ..close();
    final lower = Path()
      ..moveTo(34, 33)
      ..lineTo(20, 33)
      ..arcToPoint(const Offset(13, 26), radius: r7)
      ..lineTo(13, 24)
      ..arcToPoint(const Offset(20, 17), radius: r7)
      ..lineTo(26, 17)
      ..lineTo(32, 12.5)
      ..lineTo(32, 17)
      ..arcToPoint(const Offset(37, 23.7), radius: r7)
      ..lineTo(37, 29)
      ..arcToPoint(const Offset(33, 33), radius: r4)
      ..close();
    final overlap = Path()
      ..moveTo(16, 17)
      ..lineTo(24, 17)
      ..arcToPoint(const Offset(31, 24), radius: r7)
      ..lineTo(31, 27)
      ..lineTo(20, 27)
      ..arcToPoint(const Offset(13, 20), radius: r7)
      ..lineTo(13, 17)
      ..close();
    canvas.drawPath(upper, white);
    canvas.drawPath(lower, white);
    canvas.drawPath(overlap, black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 화면 아래 큰 검정 버튼
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: AuthColors.black,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: AuthColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 회원가입 상단: 뒤로가기 + "1 / 3" 진행 표시
class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: const BoxDecoration(
        color: AuthColors.white,
        border: Border(bottom: BorderSide(color: AuthColors.lineEE)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: '이전',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.chevron_left, size: 30),
                color: AuthColors.black,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      color: AuthColors.grayA0,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text: '$step',
                        style: const TextStyle(color: AuthColors.black),
                      ),
                      const TextSpan(text: ' / 3'),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                SizedBox(
                  width: 92,
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
                            color: i < step
                                ? AuthColors.black
                                : AuthColors.lineDD,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// 회원가입 단계 위쪽 글: 작은 영어 제목 + 큰 제목 + 설명
class SignUpStepIntro extends StatelessWidget {
  const SignUpStepIntro({
    super.key,
    required this.kicker,
    required this.title,
    required this.description,
  });

  final String kicker;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepKicker(kicker),
        const SizedBox(height: 13),
        Text(
          title,
          style: const TextStyle(
            color: AuthColors.black,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.68,
            height: 1.32,
          ),
        ),
        const SizedBox(height: 13),
        Text(
          description,
          style: const TextStyle(
            color: AuthColors.gray8E,
            fontSize: 12,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class StepKicker extends StatelessWidget {
  const StepKicker(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AuthColors.gray8E,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.26,
      ),
    );
  }
}

// 회원가입 단계 화면 틀: 상단 진행 표시 + 스크롤 내용 + 하단 버튼
class SignUpStepScaffold extends StatelessWidget {
  const SignUpStepScaffold({
    super.key,
    required this.step,
    required this.children,
    required this.buttonLabel,
    required this.onButtonPressed,
  });

  final int step;
  final List<Widget> children;
  final String buttonLabel;
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SignUpHeader(step: step),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 35, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
            AuthBottomAction(
              child: AuthPrimaryButton(
                label: buttonLabel,
                onPressed: onButtonPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 화면 맨 아래 버튼 영역 (위쪽 구분선)
class AuthBottomAction extends StatelessWidget {
  const AuthBottomAction({super.key, required this.child, this.topPadding = 9});

  final Widget child;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xF7FFFFFF),
        border: Border(top: BorderSide(color: AuthColors.lineEE)),
      ),
      child: child,
    );
  }
}

// 입력칸 위의 작은 이름표 (이메일, 학과 등)
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AuthColors.gray77,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// 밑줄 입력칸 (글자 입력)
class UnderlineTextField extends StatelessWidget {
  const UnderlineTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.padding = const EdgeInsets.fromLTRB(0, 17, 0, 13),
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  // 고칠 수 없는 칸: 흐린 글자로 보여주기만 한다
  final bool readOnly;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AuthColors.lineD9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label),
          const SizedBox(height: 9),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            readOnly: readOnly,
            autocorrect: false,
            // 입력한 글자는 힌트와 구분되도록 진하고 굵게 (고칠 수 없는 칸은 흐리게)
            style: TextStyle(
              color: readOnly ? AuthColors.gray8E : AuthColors.black,
              fontSize: 15,
              fontWeight: readOnly ? FontWeight.w400 : FontWeight.w700,
            ),
            decoration: InputDecoration.collapsed(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AuthColors.grayAA,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 밑줄 선택칸 (누르면 선택 창이 열림)
class UnderlineSelectField extends StatelessWidget {
  const UnderlineSelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String hint;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(0, 17, 0, 13),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AuthColors.lineD9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldLabel(label),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    // 고른 값은 진하고 굵게, 아직 안 골랐으면 흐린 힌트
                    style: TextStyle(
                      color: value == null
                          ? AuthColors.grayAA
                          : AuthColors.black,
                      fontSize: 15,
                      fontWeight: value == null
                          ? FontWeight.w400
                          : FontWeight.w700,
                    ),
                  ),
                ),
                const Text(
                  '⌄',
                  style: TextStyle(
                    color: AuthColors.gray77,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 아래에서 올라오는 창 열기 (뒤 배경 어둡게)
Future<T?> showAuthBottomSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AuthColors.overlay,
    builder: builder,
  );
}

// 바텀시트 위쪽 손잡이
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AuthColors.handle,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

// 선택 창 틀: 손잡이 + 제목 + 닫기 + 내용
class PickerSheetFrame extends StatelessWidget {
  const PickerSheetFrame({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 620),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        decoration: const BoxDecoration(
          color: AuthColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 7, 0, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AuthColors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      '닫기',
                      style: TextStyle(color: AuthColors.gray8E, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

// 인증 대기·가입 완료처럼 가운데 아이콘 + 글 + 하단 버튼인 화면 틀
class AuthStatusPage extends StatelessWidget {
  const AuthStatusPage({
    super.key,
    required this.icon,
    required this.kicker,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onButtonPressed,
  });

  final Widget icon;
  final String kicker;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -5),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        icon,
                        StepKicker(kicker),
                        const SizedBox(height: 13),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AuthColors.black,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AuthColors.gray8E,
                            fontSize: 12,
                            height: 1.65,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AuthBottomAction(
              child: AuthPrimaryButton(
                label: buttonLabel,
                onPressed: onButtonPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
