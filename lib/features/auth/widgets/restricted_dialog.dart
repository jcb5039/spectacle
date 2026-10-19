// [A] 02 시작·회원가입 > 미인증 안내 팝업, B 화면의 글쓰기 버튼에서도 사용 (디자인: Restricted)
import 'package:flutter/material.dart';

import '../verify_wait_screen.dart';
import 'auth_widgets.dart';

// 인증이 안 된 회원이 글쓰기·답변을 누르면 띄운다.
// 사용법: await showRestrictedDialog(context);
Future<void> showRestrictedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: AuthColors.overlay,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: AuthColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 315),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 25, 22, 7),
              child: Text(
                '인증이 끝나면 글을 쓸 수 있어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AuthColors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(
                '인증이 완료된 회원만 글과 답변을 작성할 수 있어요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AuthColors.gray8E,
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
            ),
            Container(
              height: 51,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AuthColors.lineEE)),
              ),
              child: Row(
                children: [
                  _button(
                    label: '닫기',
                    color: AuthColors.gray77,
                    onTap: () => Navigator.pop(dialogContext),
                  ),
                  _button(
                    label: '인증 상태 보기',
                    color: AuthColors.white,
                    background: AuthColors.black,
                    onTap: () {
                      Navigator.pop(dialogContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VerifyWaitScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _button({
  required String label,
  required Color color,
  required VoidCallback onTap,
  Color? background,
}) {
  return Expanded(
    child: Material(
      color: background ?? Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),
  );
}
