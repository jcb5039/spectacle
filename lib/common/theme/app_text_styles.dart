// [공통-B] 디자인 글자 스타일 모음 (글꼴, 글자 크기, 굵기)
import 'package:flutter/material.dart';

import 'app_colors.dart';

// 디자인의 letter-spacing(em)은 글자 크기를 곱해 px로 바꿔 적는다. 예: 22px × -0.04em = -0.88
class AppTextStyles {
  AppTextStyles._();

  // 홈 TODAY / DISCOVER 큰 탭 글자
  static const TextStyle homeTab = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.88,
    height: 1.5,
  );

  // 로고 옆 "스팩타클"
  static const TextStyle logo = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
    height: 1.5,
    color: AppColors.text,
  );

  // 화면 위쪽 가운데 제목 (알림 등)
  static const TextStyle headerTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.5,
    color: AppColors.text,
  );

  // 섹션 제목 ("선배들의 최신 후기")
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    letterSpacing: -0.72,
    height: 1.5,
    color: AppColors.text,
  );
}

// 한글이 단어 중간에서 줄바꿈되지 않게 한다 (디자인의 word-break: keep-all).
// 단어 안 글자 사이에 "여기서 자르지 마" 표시(U+2060)를 넣어 띄어쓰기에서만 줄이 바뀐다.
String keepAll(String text) {
  return text
      .split(' ')
      .map((word) => word.characters.join('\u2060'))
      .join(' ');
}
