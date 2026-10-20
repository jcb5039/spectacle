// [B] 05 Q&A > 질문 등록 완료 화면 (디자인: QuestionDone)
import 'package:flutter/material.dart';

import '../../models/question.dart';
import 'qa_detail_screen.dart';

// 방금 등록한 질문의 상세 화면 + "질문이 등록됐어요" 알림 띠 (답변은 아직 0개)
// 디자인 QuestionDone에는 아래쪽 답변 입력칸이 없다.
class QuestionDoneScreen extends StatelessWidget {
  const QuestionDoneScreen({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    return QaDetailScreen(
      question: question,
      toastMessage: '질문이 등록됐어요',
      showAnswerInput: false,
    );
  }
}
