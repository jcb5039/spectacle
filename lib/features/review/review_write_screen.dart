// [B] 03 홈·후기 > 후기 작성 화면, 취업자 전용 항목별 템플릿 (디자인: ReviewWrite)
import 'package:flutter/material.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/app_dialog.dart';
import '../../common/widgets/primary_button.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import 'review_done_screen.dart';
import 'widgets/link_add_sheet.dart';

class ReviewWriteScreen extends StatefulWidget {
  const ReviewWriteScreen({super.key});

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  final _title = TextEditingController();
  final _preparation = TextEditingController();
  final _difficulty = TextEditingController();
  final _trialAndError = TextEditingController();
  final _tip = TextEditingController();
  final _github = TextEditingController();
  final _notion = TextEditingController();

  String? _category;
  final List<_AddedLink> _addedLinks = []; // "＋ 링크 추가"로 늘어난 칸

  @override
  void dispose() {
    for (final c in [
      _title,
      _preparation,
      _difficulty,
      _trialAndError,
      _tip,
      _github,
      _notion,
    ]) {
      c.dispose();
    }
    for (final link in _addedLinks) {
      link.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _openLinkSheet() async {
    final link = await showLinkAddSheet(context);
    if (link == null) return;
    setState(() {
      _addedLinks.add(
        _AddedLink(link.type, TextEditingController(text: link.url)),
      );
    });
  }

  void _submit() {
    final title = _title.text.trim();
    final preparation = _preparation.text.trim();
    if (title.isEmpty) {
      showBlackToast(context, '제목을 입력해주세요', showCheck: false);
      return;
    }
    if (_category == null) {
      showBlackToast(context, '직군을 선택해주세요', showCheck: false);
      return;
    }
    if (preparation.isEmpty) {
      showBlackToast(context, '취업 준비 과정을 입력해주세요', showCheck: false);
      return;
    }

    final links = <ReviewLink>[
      for (final (type, controller) in [
        ('GitHub', _github),
        ('Notion', _notion),
        for (final added in _addedLinks) (added.type, added.controller),
      ])
        if (controller.text.trim().isNotEmpty)
          ReviewLink(
            type: type,
            title: displayUrl(controller.text.trim()),
            url: normalizeUrl(controller.text.trim()),
          ),
    ];

    final review = Review(
      id: 'w${DateTime.now().millisecondsSinceEpoch}',
      category: _category!,
      title: title,
      company: SampleCurrentUser.company,
      job: SampleCurrentUser.job,
      authorId: SampleCurrentUser.id,
      authorName: SampleCurrentUser.name,
      authorSchool: SampleCurrentUser.school,
      authorDepartment: SampleCurrentUser.department,
      authorAdmissionYear: SampleCurrentUser.admissionYear,
      authorGraduationYear: SampleCurrentUser.graduationYear,
      preparation: preparation,
      difficulty: _difficulty.text.trim(),
      trialAndError: _trialAndError.text.trim(),
      tip: _tip.text.trim(),
      links: links,
      createdAt: DateTime.now(),
    );

    ReviewService.addReview(review);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ReviewDoneScreen(review: review)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 디자인대로 ×를 누르면 확인 팝업 없이 바로 닫힌다.
            ComposeHeader(
              title: '후기 작성',
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                children: [
                  ComposeFieldBlock(
                    label: '제목',
                    child: ComposeTitleField(
                      controller: _title,
                      hintText: '후기의 제목을 입력해주세요',
                    ),
                  ),
                  ComposeFieldBlock(
                    label: '직군',
                    child: JobChips(
                      selected: _category,
                      onSelected: (c) => setState(() => _category = c),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _template(
                    '01',
                    '취업 준비 과정',
                    _preparation,
                    '지원 직무를 위해 무엇을 어떻게 준비했나요?',
                  ),
                  _template(
                    '02',
                    '취업 과정의 어려움',
                    _difficulty,
                    '가장 힘들었던 순간과 극복한 방법',
                  ),
                  _template(
                    '03',
                    '신입 시절 시행착오',
                    _trialAndError,
                    '입사 후 겪은 실수나 깨달음',
                  ),
                  _template('04', '후배에게 주는 팁', _tip, '지금 준비하는 후배에게 한마디'),
                  _buildLinks(),
                ],
              ),
            ),
            PrimaryButtonBar(label: '후기 등록', onPressed: _submit),
          ],
        ),
      ),
    );
  }

  // 본문 한 항목 (번호 + 제목 + 입력칸)
  Widget _template(
    String index,
    String heading,
    TextEditingController controller,
    String hintText,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 23, 0, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 11,
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: AppColors.textSub,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            heading,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          ComposeTextArea(
            controller: controller,
            hintText: hintText,
            minHeight: 116,
          ),
        ],
      ),
    );
  }

  // 취업 준비 자료 링크 (선택)
  Widget _buildLinks() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 28, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text.rich(
            TextSpan(
              text: '취업 준비 자료 링크 ',
              children: [
                TextSpan(text: '(선택)', style: TextStyle(fontSize: 11.2)),
              ],
            ),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.5,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 13 - 9),
          _LinkField(
            letter: 'G',
            controller: _github,
            hintText: 'GitHub URL을 입력해주세요',
          ),
          _LinkField(
            letter: 'N',
            controller: _notion,
            hintText: 'Notion URL을 입력해주세요',
          ),
          for (final link in _addedLinks)
            _LinkField(
              letter: link.type[0],
              controller: link.controller,
              hintText: '${link.type} URL을 입력해주세요',
            ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _openLinkSheet,
            child: const Text(
              '＋ 링크 추가',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.5,
                color: AppColors.textBody,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddedLink {
  _AddedLink(this.type, this.controller);

  final String type;
  final TextEditingController controller;
}

// 링크 한 칸 (G/N 아이콘 + 주소 입력)
class _LinkField extends StatefulWidget {
  const _LinkField({
    required this.letter,
    required this.controller,
    required this.hintText,
  });

  final String letter;
  final TextEditingController controller;
  final String hintText;

  @override
  State<_LinkField> createState() => _LinkFieldState();
}

class _LinkFieldState extends State<_LinkField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: Container(
        height: 52,
        margin: const EdgeInsets.only(top: 9),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          border: Border.all(
            color: _focused ? AppColors.text : const Color(0xFFE7E7E7),
          ),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Container(
              width: 27,
              height: 27,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.letter,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: widget.controller,
                keyboardType: TextInputType.url,
                autocorrect: false,
                style: const TextStyle(fontSize: 12, color: AppColors.text),
                decoration: InputDecoration.collapsed(
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textInactive,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 주소창에 보여줄 모양: https:// 와 www. 를 뺀다.
String displayUrl(String url) =>
    url.replaceFirst(RegExp(r'^https?://(www\.)?'), '');

// https:// 없이 적으면 붙여준다.
String normalizeUrl(String url) =>
    RegExp(r'^https?://').hasMatch(url) ? url : 'https://$url';

// ───────── 질문 작성·후기 작성에서 같이 쓰는 입력 부품 ─────────

// 위쪽 제목줄 (× 버튼 + 가운데 제목)
class ComposeHeader extends StatelessWidget {
  const ComposeHeader({super.key, required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 36,
                height: 36,
                child: TextButton(
                  onPressed: onClose,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: AppColors.text,
                  ),
                  child: const Text(
                    '×',
                    semanticsLabel: '닫기',
                    style: TextStyle(
                      fontSize: 31,
                      fontWeight: FontWeight.w300,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headerTitle,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// 굵은 이름표 + 입력 부품 + 아래 구분선
class ComposeFieldBlock extends StatelessWidget {
  const ComposeFieldBlock({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.5,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

// 큰 글씨 한 줄 제목 입력
class ComposeTitleField extends StatelessWidget {
  const ComposeTitleField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.63,
      height: 1.5,
    );
    return TextField(
      controller: controller,
      style: style.copyWith(color: AppColors.text),
      decoration: InputDecoration.collapsed(
        hintText: hintText,
        hintStyle: style.copyWith(color: AppColors.textInactive),
      ),
    );
  }
}

// 직무 고르기 칩 (하나만 고른다)
class JobChips extends StatelessWidget {
  const JobChips({super.key, required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        for (final category in ReviewService.jobCategories)
          GestureDetector(
            onTap: () => onSelected(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: category == selected ? AppColors.text : Colors.white,
                border: Border.all(
                  color: category == selected
                      ? AppColors.text
                      : AppColors.separator,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: category == selected
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: category == selected
                      ? Colors.white
                      : AppColors.textBody,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// 회색 바탕 여러 줄 입력칸. 누르면 테두리가 검정으로 바뀐다.
class ComposeTextArea extends StatefulWidget {
  const ComposeTextArea({
    super.key,
    required this.controller,
    required this.hintText,
    required this.minHeight,
  });

  final TextEditingController controller;
  final String hintText;
  final double minHeight;

  @override
  State<ComposeTextArea> createState() => _ComposeTextAreaState();
}

class _ComposeTextAreaState extends State<ComposeTextArea> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 14, height: 1.65);
    return GestureDetector(
      // 입력칸 빈 곳을 눌러도 글을 쓸 수 있게
      onTap: () => _focusNode.requestFocus(),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: widget.minHeight),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          border: Border.all(
            color: _focusNode.hasFocus
                ? AppColors.text
                : const Color(0xFFE7E7E7),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          style: style.copyWith(color: AppColors.text),
          decoration: InputDecoration.collapsed(
            hintText: widget.hintText,
            hintStyle: style.copyWith(color: AppColors.textInactive),
          ),
        ),
      ),
    );
  }
}
