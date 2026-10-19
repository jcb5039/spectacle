// [공통-B] 공통 부품: 화면 아래 큰 검정 버튼 (다음, 완료, 등록 등)
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// 큰 검정 버튼
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.text,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

// 화면 맨 아래에 붙는 버튼 칸 (질문 등록, 후기 등록)
class PrimaryButtonBar extends StatelessWidget {
  const PrimaryButtonBar({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: PrimaryButton(label: label, onPressed: onPressed),
      ),
    );
  }
}
