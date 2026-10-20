// [B] 03 홈·후기 > 질문 작성 화면 (디자인: QuestionWrite)
import 'package:flutter/material.dart';

import '../../common/theme/app_colors.dart';
import '../../common/widgets/app_dialog.dart';
import '../../common/widgets/primary_button.dart';
import '../../models/question.dart';
import '../../services/qa_service.dart';
import '../../services/review_service.dart';
import '../review/review_write_screen.dart';
import 'question_done_screen.dart';
import 'widgets/cancel_dialog.dart';

class QuestionWriteScreen extends StatefulWidget {
  const QuestionWriteScreen({super.key, this.initialCategory});

  // 후기 상세·선배 프로필에서 열면 그 후기의 분야를 미리 골라 둔다.
  final String? initialCategory;

  @override
  State<QuestionWriteScreen> createState() => _QuestionWriteScreenState();
}

class _QuestionWriteScreenState extends State<QuestionWriteScreen> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  String? _category;
  bool _showSchool = true;
  bool _saving = false; // 저장 중에 "질문 등록"을 또 누르지 않게

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _confirmClose() async {
    final leave = await showQuestionCancelDialog(context);
    if (leave && mounted) Navigator.of(context).pop();
  }

  Future<void> _submit() async {
    if (_saving) return;
    final title = _title.text.trim();
    final content = _content.text.trim();
    if (_category == null) {
      showBlackToast(context, '직무를 선택해주세요', showCheck: false);
      return;
    }
    if (title.isEmpty) {
      showBlackToast(context, '제목을 입력해주세요', showCheck: false);
      return;
    }
    if (content.isEmpty) {
      showBlackToast(context, '내용을 입력해주세요', showCheck: false);
      return;
    }

    final question = Question(
      id: QaService.newQuestionId(),
      category: _category!,
      title: title,
      content: content,
      authorId: CurrentMember.id,
      authorName: CurrentMember.name,
      authorType: CurrentMember.type,
      authorSchool: CurrentMember.school,
      authorDepartment: CurrentMember.department,
      showSchool: _showSchool,
      createdAt: DateTime.now(),
    );

    setState(() => _saving = true);
    try {
      await QaService.addQuestion(question);
    } catch (error) {
      debugPrint('질문 저장 실패: $error');
      if (!mounted) return;
      setState(() => _saving = false);
      // 디자인에 없는 상황이라 임시로 알림 띠를 띄운다
      showBlackToast(context, '질문을 저장하지 못했어요', showCheck: false);
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => QuestionDoneScreen(question: question)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // 뒤로 밀기로 나가려 해도 취소 팝업을 띄운다.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmClose();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ComposeHeader(title: '질문 작성', onClose: _confirmClose),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                  children: [
                    ComposeFieldBlock(
                      label: '어떤 직무의 선배에게 물어볼까요?',
                      child: JobChips(
                        selected: _category,
                        onSelected: (c) => setState(() => _category = c),
                      ),
                    ),
                    ComposeFieldBlock(
                      label: '제목',
                      child: ComposeTitleField(
                        controller: _title,
                        hintText: '궁금한 내용을 한 문장으로 적어주세요',
                      ),
                    ),
                    ComposeFieldBlock(
                      label: '내용',
                      child: ComposeTextArea(
                        controller: _content,
                        hintText: '상황을 자세히 적을수록 선배가 더 정확하게 답변할 수 있어요.',
                        minHeight: 230,
                      ),
                    ),
                    _buildSchoolToggle(),
                    _buildGuide(),
                  ],
                ),
              ),
              PrimaryButtonBar(label: '질문 등록', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolToggle() {
    // 회원 정보가 비어 있으면 "학교 · 학과"로 보여준다.
    final schoolAndDepartment = [
      CurrentMember.school,
      CurrentMember.department,
    ].where((t) => t.isNotEmpty).join(' · ');
    final label = schoolAndDepartment.isEmpty ? '학교 · 학과' : schoolAndDepartment;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _showSchool = !_showSchool),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 55),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '학교 학과 표시하기',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '질문에 $label${_subjectParticle(label)} 함께 표시돼요.',
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.5,
                        color: AppColors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
              _Toggle(on: _showSchool),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuide() {
    return Container(
      margin: const EdgeInsets.only(top: 22),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '질문 전 확인해주세요',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 7),
          Text(
            '개인정보나 특정 기업의 비공개 정보는 작성하지 마세요. 서로를 존중하는 표현을 사용해주세요.',
            style: TextStyle(
              fontSize: 11,
              height: 1.6,
              color: AppColors.textLike,
            ),
          ),
        ],
      ),
    );
  }
}

// 받침이 있으면 "이", 없으면 "가" (예: 항공서비스가, 호텔관광이)
String _subjectParticle(String word) {
  if (word.isEmpty) return '가';
  final code = word.codeUnitAt(word.length - 1);
  if (code < 0xAC00 || code > 0xD7A3) return '가';
  return (code - 0xAC00) % 28 == 0 ? '가' : '이';
}

// 켜기·끄기 스위치 (디자인: 45×27, 켜짐 검정 / 꺼짐 회색)
class _Toggle extends StatelessWidget {
  const _Toggle({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 160);
    return AnimatedContainer(
      duration: duration,
      width: 45,
      height: 27,
      decoration: BoxDecoration(
        color: on ? AppColors.text : AppColors.separator,
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedAlign(
        duration: duration,
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 21,
          height: 21,
          margin: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x29000000), // rgba(0,0,0,0.16)
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
