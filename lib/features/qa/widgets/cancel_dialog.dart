// [B] 03 홈·후기 > 질문 작성 취소 팝업 (디자인: QuestionWrite-Cancel)
import 'package:flutter/material.dart';

import '../../../common/widgets/app_dialog.dart';

// "나가기"를 누르면 true, "계속 쓰기"를 누르면 false
Future<bool> showQuestionCancelDialog(BuildContext context) {
  return showAppDialog(
    context,
    title: '작성을 그만둘까요?',
    message: '입력한 내용은 저장되지 않아요.',
    cancelLabel: '계속 쓰기',
    confirmLabel: '나가기',
  );
}
