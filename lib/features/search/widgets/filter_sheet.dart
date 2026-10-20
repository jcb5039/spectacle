// [B] 04 검색 > 학교·학과·직무·기업 필터 창 (디자인: Search-Filter)
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../common/theme/app_colors.dart';
import '../../../common/widgets/primary_button.dart';

// 체크 상자 목록이 있는 필터 창을 띄운다.
// "적용"을 누르면 고른 항목 묶음을, "닫기"나 바깥을 누르면 null을 돌려준다.
// 고른 항목이 없으면 "전체 선택"(필터 없음)이다.
Future<Set<String>?> showFilterSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  required Set<String> selected,
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.white,
    barrierColor: const Color(0x7A000000), // rgba(0,0,0,0.48)
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) =>
        _FilterSheet(title: title, options: options, selected: selected),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<String> options;
  final Set<String> selected;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final Set<String> _picked = {...widget.selected};

  bool get _isAll => _picked.isEmpty;

  void _toggle(String option) {
    setState(() {
      if (!_picked.remove(option)) _picked.add(option);
      // 모두 고르면 "전체 선택"과 같다.
      if (_picked.length == widget.options.length) _picked.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 디자인: height: min(630px, 100% - 150px)
    final height = math.min(630.0, MediaQuery.of(context).size.height - 150);

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4D4D4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 7, 0, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 21,
                      height: 1.5,
                      color: AppColors.text,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      '닫기',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textSub,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _CheckRow(
                      label: '전체 선택',
                      checked: _isAll,
                      onTap: () => setState(_picked.clear),
                    ),
                    for (final option in widget.options)
                      _CheckRow(
                        label: option,
                        checked: _picked.contains(option),
                        onTap: () => _toggle(option),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: '적용',
              height: 52,
              onPressed: () => Navigator.of(context).pop(_picked),
            ),
          ],
        ),
      ),
    );
  }
}

// 체크 상자 + 글자 한 줄
class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 47,
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: checked ? AppColors.text : null,
                border: Border.all(
                  color: checked ? AppColors.text : const Color(0xFFD8D8D8),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: AppColors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
