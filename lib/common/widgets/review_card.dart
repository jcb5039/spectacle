// [공통-B] 공통 부품: 후기 목록 한 칸 (홈·검색·랭킹·선배 프로필에서 사용)
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// 회색 바탕 후기 카드 (디자인: Discover의 feed-card)
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.likeCount,
    this.onTap,
  });

  final String category; // 직무 분야 예: 항공·관광
  final String title;
  final String subtitle; // 회사 · 직무
  final int likeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  color: AppColors.textSub,
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                height: 61,
                child: Text(
                  keepAll(title),
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontSize: 14,
                    letterSpacing: -0.49,
                    height: 1.45,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.5,
                  color: AppColors.textSub,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 12,
                    color: AppColors.textLike,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    ' $likeCount',
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: AppColors.textLike,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
