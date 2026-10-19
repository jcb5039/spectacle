// [B] 03 홈·후기 > 후기 등록 완료 화면 (디자인: ReviewDone)
import 'package:flutter/material.dart';

import '../../models/review.dart';
import 'review_detail_screen.dart';

// 방금 등록한 후기의 상세 화면 + "후기가 등록됐어요" 알림 띠
class ReviewDoneScreen extends StatelessWidget {
  const ReviewDoneScreen({super.key, required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return ReviewDetailScreen(
      review: review,
      toastMessage: '후기가 등록됐어요',
    );
  }
}
