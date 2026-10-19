// [B] 05 Q&A > 질문 등록 완료 화면 (디자인: QuestionDone)
import 'package:flutter/material.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/app_dialog.dart';
import '../../common/widgets/verified_badge.dart';
import '../../models/question.dart';

// 방금 등록한 질문 + "질문이 등록됐어요" 알림 띠 (답변은 아직 0개)
class QuestionDoneScreen extends StatefulWidget {
  const QuestionDoneScreen({super.key, required this.question});

  final Question question;

  @override
  State<QuestionDoneScreen> createState() => _QuestionDoneScreenState();
}

class _QuestionDoneScreenState extends State<QuestionDoneScreen> {
  Question get question => widget.question;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showBlackToast(context, '질문이 등록됐어요');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildQuestion(),
                  _buildAnswerHeading(),
                  _buildEmptyAnswers(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: '뒤로가기',
                  // Q&A 목록을 만들기 전까지는 질문을 열었던 화면으로 돌아간다.
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.chevron_left,
                    size: 25,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Q&A',
              textAlign: TextAlign.center,
              style: AppTextStyles.headerTitle,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final isStudent = question.authorType == '재학생';
    final info = [
      question.authorType,
      if (question.showSchool) question.authorDepartment,
      _timeAgo(question.createdAt),
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 27, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Q',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            keepAll(question.title),
            style: const TextStyle(
              fontSize: 22,
              letterSpacing: -1.1,
              height: 1.45,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            keepAll(question.content),
            style: const TextStyle(
              fontSize: 14,
              height: 1.75,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.divider,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  // 성을 뺀 이름 첫 글자 (디자인: 이서연 → 서)
                  question.authorName.length > 1
                      ? question.authorName.substring(1, 2)
                      : question.authorName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBody,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        question.authorName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // 재학생은 회색 "재학생" 표시, 취업자는 "인증 선배" 배지
                      if (isStudent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '재학생',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textLike,
                            ),
                          ),
                        )
                      else
                        const VerifiedBadge(style: VerifiedBadgeStyle.plain),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info,
                    style: const TextStyle(
                      fontSize: 9,
                      height: 1.5,
                      color: AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerHeading() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFF7F7F7), width: 8),
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Text.rich(
        TextSpan(
          text: '선배 답변 ',
          children: [
            TextSpan(
              text: '${question.answerCount}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textSub,
              ),
            ),
          ],
        ),
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildEmptyAnswers() {
    return Container(
      constraints: const BoxConstraints(minHeight: 270),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 55),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55,
            height: 55,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.iconBackground,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'Q',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textInactive,
              ),
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            '아직 답변이 없어요',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            '선배의 답변을 기다려 주세요.',
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: AppColors.textSub,
            ),
          ),
        ],
      ),
    );
  }
}

// 작성 시간을 "방금 / N분 전 / N시간 전 / N일 전"으로
String _timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return '방금';
  if (diff.inHours < 1) return '${diff.inMinutes}분 전';
  if (diff.inDays < 1) return '${diff.inHours}시간 전';
  return '${diff.inDays}일 전';
}
