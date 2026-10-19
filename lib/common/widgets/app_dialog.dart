// [공통-B] 공통 부품: 화면 가운데 뜨는 팝업(다이얼로그) 틀
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// 제목·설명·버튼 2개 팝업. 오른쪽(검정) 버튼을 누르면 true를 돌려준다.
Future<bool> showAppDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x7A000000), // rgba(0,0,0,0.48)
    builder: (context) => _AppDialog(
      title: title,
      message: message,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
    ),
  );
  return result ?? false;
}

class _AppDialog extends StatelessWidget {
  const _AppDialog({
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    Widget button(String label, bool confirm) {
      return Expanded(
        child: Material(
          color: confirm ? AppColors.text : Colors.white,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(confirm),
            child: Container(
              height: 51,
              alignment: Alignment.center,
              decoration: confirm
                  ? const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: AppColors.divider),
                      ),
                    )
                  : null,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: confirm ? Colors.white : AppColors.textLike,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 315),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 25, 22, 7),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  letterSpacing: -0.595,
                  height: 1.5,
                  color: AppColors.text,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.55,
                  color: AppColors.textSub,
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  button(cancelLabel, false),
                  button(confirmLabel, true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 화면 아래쪽에 잠깐 뜨는 검정 알림 띠(토스트). 2초 뒤 사라진다.
// 디자인: 후기 등록 완료, 질문 등록 완료의 black-toast
void showBlackToast(
  BuildContext context,
  String message, {
  bool showCheck = true,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 18,
      right: 18,
      bottom: 101,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.text,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3D000000), // rgba(0,0,0,0.24)
                  offset: Offset(0, 12),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Row(
              children: [
                if (showCheck) ...[
                  const Icon(Icons.check, size: 16, color: Colors.white),
                  const SizedBox(width: 9),
                ],
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 2), () {
    if (entry.mounted) entry.remove();
  });
}
