// [B] 03 홈·후기 > 선배 프로필 화면 (디자인: SeniorProfile)
import 'package:flutter/material.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/verified_badge.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import '../qa/question_write_screen.dart';
import 'review_detail_screen.dart';

// 후기 작성자(선배)의 공개 프로필. 작성자 정보는 열고 온 후기에서 가져온다.
class SeniorProfileScreen extends StatefulWidget {
  const SeniorProfileScreen({super.key, required this.review});

  final Review review;

  @override
  State<SeniorProfileScreen> createState() => _SeniorProfileScreenState();
}

class _SeniorProfileScreenState extends State<SeniorProfileScreen> {
  bool _showReviews = true; // 후기 / 답변 탭

  Review get review => widget.review;

  @override
  Widget build(BuildContext context) {
    final reviews = ReviewService.reviewsByAuthor(review.authorId);
    final likeTotal = reviews.fold<int>(0, (sum, r) => sum + r.likeCount);

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
                  _buildProfile(),
                  _buildStats(reviews.length, likeTotal),
                  _buildAskButton(),
                  _buildTabs(),
                  if (_showReviews) _buildPosts(reviews),
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
              '선배 프로필',
              textAlign: TextAlign.center,
              style: AppTextStyles.headerTitle,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: Column(
        children: [
          ReviewAuthorAvatar(name: review.authorName, size: 94, fontSize: 25),
          const SizedBox(height: 17),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                review.authorName,
                style: const TextStyle(
                  fontSize: 21,
                  height: 1.5,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(width: 7),
              const VerifiedBadge(style: VerifiedBadgeStyle.plain),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            '${review.authorSchool} ${review.authorDepartment} · '
            '${review.authorAdmissionYear}학번 · '
            '${review.authorGraduationYear}년 졸업\n'
            '${review.companyAndJob}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              height: 1.65,
              color: AppColors.textSub,
            ),
          ),
        ],
      ),
    );
  }

  // 후기 수 / 받은 도움돼요 / 답변 수
  Widget _buildStats(int reviewCount, int likeTotal) {
    Widget stat(String number, String label, {bool leftLine = true}) {
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            border: leftLine
                ? const Border(left: BorderSide(color: AppColors.divider))
                : null,
          ),
          child: Column(
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  height: 1.5,
                  color: AppColors.textSub,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 18),
      padding: const EdgeInsets.symmetric(vertical: 17),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          stat('$reviewCount', '후기', leftLine: false),
          stat('$likeTotal', '받은 도움돼요'),
          // 답변 수는 Q&A 데이터를 만든 뒤 연결한다.
          stat('0', '답변'),
        ],
      ),
    );
  }

  Widget _buildAskButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SizedBox(
        width: double.infinity,
        height: 49,
        child: FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  QuestionWriteScreen(initialCategory: review.category),
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.text,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          child: const Text(
            '선배에게 질문하기',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    Widget tab(String label, bool selected, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: selected
                ? const Border(
                    bottom: BorderSide(color: AppColors.text, width: 2),
                  )
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: selected ? AppColors.text : const Color(0xFF999999),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 8 + 47,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFF7F7F7), width: 8),
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tab('후기', _showReviews, () => setState(() => _showReviews = true)),
          const SizedBox(width: 24),
          // 답변 목록은 디자인에 내용이 없어 비워 둔다.
          tab('답변', !_showReviews, () => setState(() => _showReviews = false)),
        ],
      ),
    );
  }

  Widget _buildPosts(List<Review> reviews) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 35),
      child: Column(
        children: [
          for (final r in reviews)
            InkWell(
              onTap: () => openReviewDetail(context, r),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    const ReviewPhoto(width: 76, height: 76, borderRadius: 8),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            keepAll(r.title),
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '${r.companyAndJob} · ${r.authorDepartment}',
                            style: const TextStyle(
                              fontSize: 9,
                              height: 1.5,
                              color: AppColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.text,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
