// [B] 03 홈·후기 > 배너 모음 화면: 배너를 누르면 열리는 후기 묶음 (디자인: Banner)
import 'package:flutter/material.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_text_styles.dart';
import '../../services/review_service.dart';
import '../review/review_detail_screen.dart';

class BannerScreen extends StatelessWidget {
  const BannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = ReviewService.bannerReviews;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHero(),
                  _buildIntro(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Column(
                      children: [
                        for (var i = 0; i < reviews.length; i++)
                          _CollectionItem(
                            index: (i + 1).toString().padLeft(2, '0'),
                            title: reviews[i].title,
                            subtitle: reviews[i].companyAndJob,
                            onTap: () => openReviewDetail(context, reviews[i]),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              '학과별 선배 노트',
              textAlign: TextAlign.center,
              style: AppTextStyles.headerTitle,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: 310,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ReviewPhoto(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xE0000000), // rgba(0,0,0,0.88)
                  Color(0x0A000000), // rgba(0,0,0,0.04)
                ],
                stops: [0, 0.7],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CAREER COLLECTION 01',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.26,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  keepAll('첫 취업, 어디서부터?\n학과별 선배의 준비 노트'),
                  style: const TextStyle(
                    fontSize: 25,
                    letterSpacing: -1.375,
                    height: 1.32,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '다양한 전공의 선배들은 첫 취업을 어떻게 준비했을까요?',
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: AppColors.textSub,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            keepAll('수업과 실습을 현장 경험으로\n연결한 진짜 취업 이야기'),
            style: const TextStyle(
              fontSize: 19,
              letterSpacing: -0.855,
              height: 1.45,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

// 묶음 목록 한 줄 (번호 + 사진 + 제목)
class _CollectionItem extends StatelessWidget {
  const _CollectionItem({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String index;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 25,
              child: Text(
                index,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textInactive,
                ),
              ),
            ),
            const SizedBox(width: 11),
            const ReviewPhoto(width: 88, height: 88, borderRadius: 8),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    keepAll(title),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 9,
                      height: 1.5,
                      color: AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
