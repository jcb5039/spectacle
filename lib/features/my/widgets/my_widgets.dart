// [A] 06 랭킹·MY > 랭킹·MY·개인정보 수정·스펙 수정 화면이 같이 쓰는 부품: 페이지 제목, 밑줄 탭, 프로필 동그라미, 인증 선배 표시, 목록 한 줄, 설정 칸·스위치, 작은 입력칸 (B의 공통 부품이 생기면 바꿀 수 있음)
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../auth/widgets/auth_widgets.dart';

const _georgia = 'Georgia';

// 큰 페이지 제목 (랭킹, MY)
class PageTitle extends StatelessWidget {
  const PageTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 19, 20, 15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AuthColors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.54,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AuthColors.gray8E,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// 글자 아래에 검정 밑줄이 생기는 탭 (도움된 글 / 활동 많은 선배 등)
class UnderlineTabs extends StatelessWidget {
  const UnderlineTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AuthColors.lineEE)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 22),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: i == selectedIndex
                          ? AuthColors.black
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: i == selectedIndex
                        ? AuthColors.black
                        : const Color(0xFF999999),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 검정 동그라미 프로필 (사진이 없으면 이름 첫 글자)
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    required this.size,
    required this.fontSize,
    this.photo,
  });

  final String name;
  final double size;
  final double fontSize;
  final Uint8List? photo;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AuthColors.black,
        shape: BoxShape.circle,
      ),
      child: photo != null && photo.isNotEmpty
          ? Image.memory(photo, width: size, height: size, fit: BoxFit.cover)
          : Text(
              name.isEmpty ? '' : name.characters.first,
              style: TextStyle(
                color: AuthColors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

// 검정 동그라미 체크
class CheckDot extends StatelessWidget {
  const CheckDot({super.key, this.iconSize = 9});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: const BoxDecoration(
        color: AuthColors.black,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check, size: iconSize, color: AuthColors.white),
    );
  }
}

// "인증 선배" 표시. B가 common/widgets/verified_badge.dart를 만들면 바꾼다.
class VerifiedSeniorBadge extends StatelessWidget {
  const VerifiedSeniorBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckDot(),
        SizedBox(width: 4),
        Text(
          '인증 선배',
          style: TextStyle(
            color: AuthColors.black,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// 테두리만 있는 둥근 작은 버튼·표시 (개인정보 수정, 수정, 답변 24)
class OutlinePill extends StatelessWidget {
  const OutlinePill({
    super.key,
    required this.label,
    this.onTap,
    this.color = AuthColors.gray66,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.fontWeight = FontWeight.w400,
    this.height,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final EdgeInsets padding;
  final FontWeight fontWeight;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final pill = GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AuthColors.lineDD),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: fontWeight),
        ),
      ),
    );
    // 누를 수 있으면 화면 낭독 기능에서도 버튼으로 따로 읽히게 한다
    return onTap == null ? pill : Semantics(button: true, child: pill);
  }
}

// 순위 숫자 (1~3위는 검정, 나머지는 회색, 기울어진 Georgia 글꼴)
class RankNumber extends StatelessWidget {
  const RankNumber({
    super.key,
    required this.rank,
    required this.fontSize,
    this.twoDigits = false,
  });

  final int rank;
  final double fontSize;
  final bool twoDigits;

  @override
  Widget build(BuildContext context) {
    return Text(
      twoDigits ? rank.toString().padLeft(2, '0') : '$rank',
      style: TextStyle(
        color: rank <= 3 ? AuthColors.black : AuthColors.grayAA,
        fontFamily: _georgia,
        fontSize: fontSize,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// MY 목록 한 줄: 왼쪽(사진 또는 Q) + 제목 + 작은 설명 + 오른쪽 화살표
class MyListItem extends StatelessWidget {
  const MyListItem({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.verticalPadding,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final double verticalPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AuthColors.lineEE)),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AuthColors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AuthColors.gray8E,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 11),
            const Icon(Icons.chevron_right, size: 18, color: AuthColors.black),
          ],
        ),
      ),
    );
  }
}

// 후기 사진 자리 (B의 후기 데이터가 생기면 실제 사진으로 바꾼다)
class ReviewThumbnail extends StatelessWidget {
  const ReviewThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: AuthColors.fillF2,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class QuestionMark extends StatelessWidget {
  const QuestionMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      child: Text(
        'Q',
        style: TextStyle(
          color: AuthColors.black,
          fontFamily: _georgia,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// 개인정보·스펙 수정 화면 위쪽: 뒤로가기 + 가운데 제목
class ModalHeader extends StatelessWidget {
  const ModalHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AuthColors.white,
        border: Border(bottom: BorderSide(color: AuthColors.lineEE)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: '뒤로가기',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.chevron_left, size: 30),
                color: AuthColors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AuthColors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// 위에 회색 굵은 구분선이 있는 설정 묶음 (기본 정보, 학점 등)
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.onAdd,
  });

  final String title;
  final List<Widget> children;
  // 있으면 제목 오른쪽에 "＋ 추가" 버튼
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 23, 20, 23),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AuthColors.fillF7, width: 8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AuthColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onAdd != null)
                GestureDetector(
                  onTap: onAdd,
                  child: const Text(
                    '＋ 추가',
                    style: TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// 설명이 있는 켜기/끄기 줄 (회사·직무 공개 등)
class SettingToggleRow extends StatelessWidget {
  const SettingToggleRow({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 55),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AuthColors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AuthColors.gray8E,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            _BlackSwitch(value: value),
          ],
        ),
      ),
    );
  }
}

class _BlackSwitch extends StatelessWidget {
  const _BlackSwitch({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 45,
      height: 27,
      padding: const EdgeInsets.all(3),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: value ? AuthColors.black : AuthColors.lineDD,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        width: 21,
        height: 21,
        decoration: const BoxDecoration(
          color: AuthColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x29000000),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}

// 작은 이름표 + 굵은 글자 입력칸 (입학년도, 평점 등)
class SmallUnderlineField extends StatelessWidget {
  const SmallUnderlineField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AuthColors.gray8E, fontSize: 10),
          ),
          const SizedBox(height: 7),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: AuthColors.black,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration.collapsed(hintText: ''),
          ),
        ],
      ),
    );
  }
}

// 글자 입력칸 (테두리 없음). 스펙 수정의 시험명·점수 등에 사용
class PlainTextField extends StatelessWidget {
  const PlainTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.fontSize,
    this.fontWeight = FontWeight.w400,
  });

  final TextEditingController controller;
  final String hint;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: AuthColors.black,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      decoration: InputDecoration.collapsed(
        hintText: hint,
        hintStyle: TextStyle(
          color: AuthColors.grayAA,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

// 행 오른쪽 × 삭제 버튼
class RemoveButton extends StatelessWidget {
  const RemoveButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '삭제',
      child: GestureDetector(
        onTap: onTap,
        child: const SizedBox(
          width: 28,
          child: Text(
            '×',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF999999), fontSize: 19),
          ),
        ),
      ),
    );
  }
}

// "2시간 전", "3일 전", "1주 전"
String timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return '방금 전';
  if (diff.inHours < 1) return '${diff.inMinutes}분 전';
  if (diff.inDays < 1) return '${diff.inHours}시간 전';
  if (diff.inDays < 7) return '${diff.inDays}일 전';
  if (diff.inDays < 30) return '${diff.inDays ~/ 7}주 전';
  return '${diff.inDays ~/ 30}달 전';
}

// "2024. 03. 12"
String dotDate(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${date.year}. ${two(date.month)}. ${two(date.day)}';
}
