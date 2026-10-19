// [B] 03 홈·후기 > 홈 배너 (디자인: Banner)
import 'package:flutter/material.dart';

// DISCOVER 위쪽 검정 배너 (디자인: Discover의 advice-banner)
// 배너는 4개지만 디자인에는 첫 번째 내용만 있어서 지금은 그 하나만 보여준다.
// 누르면 배너 모음 화면(BannerScreen)으로 이동한다.
class BannerSlider extends StatelessWidget {
  const BannerSlider({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      child: Material(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: Stack(
              children: [
                const Positioned(
                  left: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SENIOR'S ADVICE",
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.44,
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '첫 취업, 어디서부터?\n학과별 선배의 준비 노트',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.72,
                          height: 1.35,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '1 / 4',
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
