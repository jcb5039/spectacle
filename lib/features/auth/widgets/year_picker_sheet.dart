// [A] 02 시작·회원가입 > 입학·졸업 연도 선택 창 (디자인: SignUp-2-Year)
import 'package:flutter/material.dart';

import 'auth_widgets.dart';

// 고른 연도를 돌려준다. 닫기를 누르면 null
Future<int?> showYearPickerSheet(
  BuildContext context, {
  required String title,
  required List<int> years,
  required int initialYear,
}) {
  return showAuthBottomSheet<int>(
    context,
    (context) =>
        _YearPickerSheet(title: title, years: years, initialYear: initialYear),
  );
}

class _YearPickerSheet extends StatefulWidget {
  const _YearPickerSheet({
    required this.title,
    required this.years,
    required this.initialYear,
  });

  final String title;
  final List<int> years;
  final int initialYear;

  @override
  State<_YearPickerSheet> createState() => _YearPickerSheetState();
}

class _YearPickerSheetState extends State<_YearPickerSheet> {
  static const double _itemHeight = 49;

  late int _index = widget.years.contains(widget.initialYear)
      ? widget.years.indexOf(widget.initialYear)
      : 0;
  late final _controller = FixedExtentScrollController(initialItem: _index);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PickerSheetFrame(
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 245,
            margin: const EdgeInsets.fromLTRB(0, 4, 0, 17),
            child: Stack(
              children: [
                // 가운데 선택 줄 (위아래 선)
                Positioned(
                  top: 98,
                  left: 0,
                  right: 0,
                  height: _itemHeight,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(color: AuthColors.lineDD),
                      ),
                    ),
                  ),
                ),
                ListWheelScrollView.useDelegate(
                  controller: _controller,
                  itemExtent: _itemHeight,
                  diameterRatio: 100,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) =>
                      setState(() => _index = index),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: widget.years.length,
                    builder: (context, index) {
                      final selected = index == _index;
                      return Center(
                        child: Text(
                          '${widget.years[index]}',
                          style: TextStyle(
                            color: selected
                                ? AuthColors.black
                                : AuthColors.grayAA,
                            fontSize: selected ? 22 : 18,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AuthPrimaryButton(
            label: '선택',
            height: 52,
            onPressed: () => Navigator.pop(context, widget.years[_index]),
          ),
        ],
      ),
    );
  }
}
