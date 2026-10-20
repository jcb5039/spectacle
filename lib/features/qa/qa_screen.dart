// [B] 05 Q&A > Q&A 목록·검색 결과 화면 (디자인: QA, QA-Result)
import 'package:flutter/material.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_text_styles.dart';
import '../../models/question.dart';
import '../../services/qa_service.dart';
import '../../services/review_service.dart';
import 'qa_detail_screen.dart';
import 'question_write_screen.dart';

class QaScreen extends StatefulWidget {
  const QaScreen({super.key});

  @override
  State<QaScreen> createState() => _QaScreenState();
}

class _QaScreenState extends State<QaScreen> {
  final _controller = TextEditingController();
  String _category = '전체';

  @override
  void initState() {
    super.initState();
    QaService.changes.addListener(_onChanged);
  }

  @override
  void dispose() {
    QaService.changes.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  // 키보드를 내리고 검색창 선택도 푼다.
  // (FocusScope.unfocus는 검색창을 기억해 두었다가, 다른 화면에서 돌아오면 다시 선택한다)
  void _hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  void _openWrite() {
    _hideKeyboard();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuestionWriteScreen(
          initialCategory: _category == '전체' ? null : _category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searching = _controller.text.trim().isNotEmpty;
    final questions = QaService.searchQuestions(
      keyword: _controller.text,
      category: _category,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            GestureDetector(
              // 빈 곳을 누르면 키보드를 내린다.
              onTap: _hideKeyboard,
              behavior: HitTestBehavior.translucent,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 80),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [_buildTitle(), _buildSearchField()],
                    ),
                  ),
                  // 직무 탭 밑줄은 화면 끝까지 이어진다.
                  _buildCategoryTabs(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (searching)
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 2),
                            child: Text(
                              '검색 결과 ${questions.length}개',
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: AppColors.textSub,
                              ),
                            ),
                          ),
                        for (final q in questions)
                          _QuestionRow(
                            question: q,
                            onTap: () {
                              _hideKeyboard();
                              openQaDetail(context, q);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(right: 18, bottom: 14, child: _buildWriteButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.only(top: 19, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q&A',
            style: TextStyle(
              fontSize: 28,
              letterSpacing: -1.54, // -0.055em
              height: 1.5,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '학교 선배에게 직접 물어보세요.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSub,
            ),
          ),
        ],
      ),
    );
  }

  // ───── 검색창 ─────
  Widget _buildSearchField() {
    final hasText = _controller.text.isNotEmpty;

    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 18,
            color: hasText ? AppColors.textSub : AppColors.textOff,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '궁금한 질문을 검색해보세요',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textOff,
                ),
              ),
            ),
          ),
          if (hasText) ...[
            const SizedBox(width: 8),
            Semantics(
              label: '검색어 지우기',
              button: true,
              child: GestureDetector(
                onTap: () => setState(_controller.clear),
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC4C4C4),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '×',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ───── 직무 탭 (전체 + 직무 분야) ─────
  Widget _buildCategoryTabs() {
    final tabs = ['전체', ...ReviewService.jobCategories];

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 13),
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 20),
              GestureDetector(
                onTap: () => setState(() => _category = tabs[i]),
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: _category == tabs[i]
                        ? FontWeight.w800
                        : FontWeight.w400,
                    color: _category == tabs[i]
                        ? AppColors.text
                        : AppColors.textOff,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ───── 질문하기 떠 있는 버튼 ─────
  Widget _buildWriteButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000), // rgba(0,0,0,0.2)
            offset: Offset(0, 8),
            blurRadius: 25,
          ),
        ],
      ),
      child: Material(
        color: AppColors.text,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: _openWrite,
          child: const SizedBox(
            height: 48,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 17),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                  SizedBox(width: 7),
                  Text(
                    '질문하기',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 질문 한 줄: Q 글자, 답변 완료 표시, 제목, 작성자 줄, 오른쪽 답변 수
class _QuestionRow extends StatelessWidget {
  const _QuestionRow({required this.question, required this.onTap});

  final Question question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final answerCount = QaService.answerCountOf(question.id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 126),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: 19,
              left: 0,
              child: Text(
                'Q',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(36, 20, 58, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (answerCount > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.text,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '답변 완료',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Text(
                      keepAll(question.title),
                      style: const TextStyle(
                        fontSize: 15,
                        letterSpacing: -0.525, // -0.035em
                        height: 1.45,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Text(
                    questionInfo(question),
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Center(
                child: Text(
                  '답변 $answerCount',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textBody,
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
