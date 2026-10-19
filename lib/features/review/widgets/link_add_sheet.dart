// [B] 03 홈·후기 > 포트폴리오 링크 추가 창, GitHub·Notion (디자인: ReviewWrite-Link)
import 'package:flutter/material.dart';

import '../../../common/theme/app_colors.dart';
import '../../../common/widgets/app_bottom_sheet.dart';
import '../../../common/widgets/primary_button.dart';

class AddedLinkResult {
  const AddedLinkResult(this.type, this.url);

  final String type; // GitHub / Notion
  final String url;
}

// 링크 추가 창을 띄우고, "추가"를 누르면 고른 종류와 주소를 돌려준다.
Future<AddedLinkResult?> showLinkAddSheet(BuildContext context) {
  return showAppBottomSheet<AddedLinkResult>(
    context,
    title: '취업 준비 자료 링크 추가',
    child: const _LinkAddForm(),
  );
}

class _LinkAddForm extends StatefulWidget {
  const _LinkAddForm();

  @override
  State<_LinkAddForm> createState() => _LinkAddFormState();
}

class _LinkAddFormState extends State<_LinkAddForm> {
  final _url = TextEditingController();
  String _type = 'GitHub';

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSegment(),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 24, 0, 20),
          padding: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'URL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  color: AppColors.textLike,
                ),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: _url,
                autofocus: true,
                keyboardType: TextInputType.url,
                autocorrect: false,
                style: const TextStyle(fontSize: 14, color: AppColors.text),
                decoration: InputDecoration.collapsed(
                  hintText: _type == 'GitHub'
                      ? 'https://github.com/...'
                      : 'https://notion.site/...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textInactive,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: '추가',
          height: 52,
          onPressed: () {
            final url = _url.text.trim();
            // 주소가 비어 있으면 아무것도 하지 않는다.
            if (url.isEmpty) return;
            Navigator.of(context).pop(AddedLinkResult(_type, url));
          },
        ),
      ],
    );
  }

  // GitHub / Notion 고르기
  Widget _buildSegment() {
    Widget option(String type) {
      final selected = _type == type;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _type = type),
          child: Container(
            alignment: Alignment.center,
            decoration: selected
                ? BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x17000000), // rgba(0,0,0,0.09)
                        offset: Offset(0, 1),
                        blurRadius: 4,
                      ),
                    ],
                  )
                : null,
            child: Text(
              type,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.text : const Color(0xFF888888),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(children: [option('GitHub'), option('Notion')]),
    );
  }
}
