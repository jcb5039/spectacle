// [공통-B] 공통 부품: "인증 선배" 배지
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum VerifiedBadgeStyle {
  onDark, // 검정 카드 위 (TODAY): 흰 테두리 + 옅은 검정 바탕
  onPhoto, // 사진 위 (후기 상세 표지): 흰 테두리만
  plain, // 흰 바탕 위 (작성자 줄·선배 프로필): 검정 체크 + 검정 글자
}

// "인증 선배" 배지
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.style = VerifiedBadgeStyle.onDark});

  final VerifiedBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final isPlain = style == VerifiedBadgeStyle.plain;
    final textColor = isPlain ? AppColors.text : Colors.white;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: isPlain ? AppColors.text : Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 9,
            color: isPlain ? Colors.white : AppColors.text,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '인증 선배',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.5,
            color: textColor,
          ),
        ),
      ],
    );

    if (isPlain) return content;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: style == VerifiedBadgeStyle.onDark
            ? Colors.black.withValues(alpha: 0.18)
            : null,
        border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: content,
    );
  }
}
