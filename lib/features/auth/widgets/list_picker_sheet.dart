// [A] 02 시작·회원가입 > 목록에서 하나를 고르는 선택 창 틀 (검색칸 + 목록 + 선택 버튼). 학교·학과·직군 선택 창이 같이 사용 (디자인: SignUp-2-School, SignUp-2-Department)
import 'package:flutter/material.dart';

import 'auth_widgets.dart';

// 고른 값을 돌려준다. 닫기를 누르면 null
Future<String?> showListPickerSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  String? selected,
  String? searchHint,
}) {
  return showAuthBottomSheet<String>(
    context,
    (context) => _ListPickerSheet(
      title: title,
      options: options,
      initialSelected: selected,
      searchHint: searchHint,
    ),
  );
}

class _ListPickerSheet extends StatefulWidget {
  const _ListPickerSheet({
    required this.title,
    required this.options,
    required this.initialSelected,
    required this.searchHint,
  });

  final String title;
  final List<String> options;
  final String? initialSelected;
  // null이면 검색칸을 보여주지 않는다
  final String? searchHint;

  @override
  State<_ListPickerSheet> createState() => _ListPickerSheetState();
}

class _ListPickerSheetState extends State<_ListPickerSheet> {
  late String? _selected = widget.initialSelected;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final visible = widget.options
        .where((option) => option.contains(_query.trim()))
        .toList();

    return PickerSheetFrame(
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.searchHint != null) _buildSearchBox(widget.searchHint!),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 335),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: visible.length,
                itemBuilder: (context, index) => _buildItem(visible[index]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AuthPrimaryButton(
            label: '선택',
            height: 52,
            onPressed: () => Navigator.pop(context, _selected),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox(String hint) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AuthColors.fillF4,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AuthColors.gray8E),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(color: AuthColors.black, fontSize: 14),
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AuthColors.gray8E,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String option) {
    final isSelected = option == _selected;
    return InkWell(
      onTap: () => setState(() => _selected = option),
      child: Container(
        height: 48,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AuthColors.lineEE)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected ? AuthColors.black : AuthColors.gray66,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, size: 16, color: AuthColors.black),
          ],
        ),
      ),
    );
  }
}
