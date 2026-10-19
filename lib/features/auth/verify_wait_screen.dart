// [A] 02 시작·회원가입 > 인증 대기 화면 (디자인: VerifyWait)
import 'package:flutter/material.dart';

import '../../common/main_tab_screen.dart';
import 'widgets/auth_widgets.dart';

class VerifyWaitScreen extends StatelessWidget {
  // afterSignUp: 가입 직후에 온 경우 true, 미인증 팝업의 "인증 상태 보기"로 온 경우 false
  const VerifyWaitScreen({super.key, this.afterSignUp = false});

  final bool afterSignUp;

  void _browse(BuildContext context) {
    if (afterSignUp) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabScreen()),
        (_) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthStatusPage(
      icon: Container(
        width: 88,
        height: 88,
        margin: const EdgeInsets.only(bottom: 28),
        decoration: BoxDecoration(
          border: Border.all(color: AuthColors.lineDD),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CustomPaint(painter: _DashedCirclePainter()),
              ),
            ),
            const Icon(Icons.check, size: 30, color: AuthColors.black),
          ],
        ),
      ),
      kicker: 'VERIFICATION IN PROGRESS',
      title: '인증을 확인하고 있어요',
      message: '승인되면 글을 쓸 수 있어요.\n보통 1~2일 안에 알려드릴게요.',
      buttonLabel: '먼저 둘러보기',
      onButtonPressed: () => _browse(context),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AuthColors.grayAA
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addOval(Offset.zero & size);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 4), paint);
        distance += 7;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
