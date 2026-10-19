// [공통-B] 디자인 색상 모음 (#111111 글자, #FFFFFF 배경, #EEEEEE 구분선, 회색 보조 글자 등)
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color text = Color(0xFF111111);
  static const Color background = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEEEEEE);

  // 회색 보조 글자
  static const Color textSub = Color(0xFF8E8E8E); // 소제목·카테고리·회사명
  static const Color textBody = Color(0xFF666666); // 알림 본문
  static const Color textLike = Color(0xFF777777); // 좋아요 수
  static const Color textOff = Color(0xFF9A9A9A); // 선택 안 된 직무 탭·정렬
  static const Color textInactive = Color(0xFFAAAAAA); // 선택 안 된 TODAY/DISCOVER, 알림 시간

  // 바탕·점
  static const Color cardBackground = Color(0xFFF6F6F6); // 후기 카드
  static const Color iconBackground = Color(0xFFF1F1F1); // 알림 아이콘 원
  static const Color dotOff = Color(0xFFD5D5D5); // 넘기기 점(꺼짐)
  static const Color separator = Color(0xFFDDDDDD); // 최신순 | 인기순 사이 막대
}
