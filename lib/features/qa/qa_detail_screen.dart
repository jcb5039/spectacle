// [B] 05 Q&A > Q&A 상세·답변 작성 화면 (디자인: QADetail, QADetail-Typing)
import 'package:flutter/material.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/app_dialog.dart';
import '../../common/widgets/verified_badge.dart';
import '../../models/answer.dart';
import '../../models/question.dart';
import '../../services/qa_service.dart';
import '../../services/review_service.dart';
import '../review/senior_profile_screen.dart';

// 어느 화면에서든 Q&A 상세를 여는 함수
void openQaDetail(BuildContext context, Question question) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => QaDetailScreen(question: question)));
}

class QaDetailScreen extends StatefulWidget {
  const QaDetailScreen({
    super.key,
    required this.question,
    this.toastMessage,
    this.showAnswerInput = true,
  });

  final Question question;

  // 화면이 열리자마자 띄울 검정 알림 띠 (질문 등록 완료 화면에서 사용)
  final String? toastMessage;

  // 아래쪽 답변 입력칸 (디자인 QuestionDone에는 없다)
  final bool showAnswerInput;

  @override
  State<QaDetailScreen> createState() => _QaDetailScreenState();
}

class _QaDetailScreenState extends State<QaDetailScreen> {
  final _answerController = TextEditingController();
  final _answerFocus = FocusNode();

  Question get question => widget.question;
  bool _saving = false; // 답변 저장 중에 "등록"을 또 누르지 않게

  @override
  void initState() {
    super.initState();
    QaService.start();
    QaService.changes.addListener(_onChanged);
    _answerFocus.addListener(_onChanged);
    final toast = widget.toastMessage;
    if (toast != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showBlackToast(context, toast);
      });
    }
  }

  @override
  void dispose() {
    QaService.changes.removeListener(_onChanged);
    _answerFocus.removeListener(_onChanged);
    _answerFocus.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  // 도움순: 도움돼요가 많은 답변부터
  List<Answer> get _answers {
    final list = QaService.answersOf(question.id);
    list.sort(
      (a, b) => QaService.likeCountOf(b).compareTo(QaService.likeCountOf(a)),
    );
    return list;
  }

  Future<void> _submitAnswer() async {
    final content = _answerController.text.trim();
    if (content.isEmpty || _saving) return;
    // 답변은 인증된 선배(취업자)만 쓸 수 있다.
    // 디자인에 없는 상황이라 임시로 알림 띠를 띄운다 (A의 미인증 안내 팝업 연결은 나중에)
    if (!CurrentMember.canWriteSeniorPost) {
      showBlackToast(context, '인증된 선배만 답변할 수 있어요', showCheck: false);
      return;
    }
    setState(() => _saving = true);
    try {
      await QaService.addAnswer(newAnswerFromCurrentUser(question.id, content));
      _answerController.clear();
      _answerFocus.unfocus();
    } catch (error) {
      debugPrint('답변 저장 실패: $error');
      if (mounted) {
        showBlackToast(context, '답변을 저장하지 못했어요', showCheck: false);
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final answers = _answers;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: GestureDetector(
                // 빈 곳을 누르면 키보드를 내린다.
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                behavior: HitTestBehavior.translucent,
                child: ListView(
                  padding: EdgeInsets.zero,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    _buildQuestion(),
                    _buildAnswerHeading(answers.length),
                    if (answers.isEmpty)
                      _buildEmptyAnswers()
                    else
                      for (var i = 0; i < answers.length; i++)
                        _AnswerCard(answer: answers[i], isFirst: i == 0),
                  ],
                ),
              ),
            ),
            if (widget.showAnswerInput) _buildAnswerInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: '뒤로가기',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.chevron_left,
                    size: 25,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Q&A',
              textAlign: TextAlign.center,
              style: AppTextStyles.headerTitle,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final isStudent = question.authorType == '재학생';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 27, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Q',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            keepAll(question.title),
            style: const TextStyle(
              fontSize: 22,
              letterSpacing: -1.1,
              height: 1.45,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 17),
          if (question.content.isNotEmpty) ...[
            Text(
              keepAll(question.content),
              style: const TextStyle(
                fontSize: 14,
                height: 1.75,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 22),
          ],
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.divider,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _avatarLetter(question.authorName),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBody,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (question.authorName.isNotEmpty) ...[
                        Text(
                          question.authorName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      // 재학생은 회색 "재학생" 표시, 취업자는 "인증 선배" 배지
                      if (isStudent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '재학생',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textLike,
                            ),
                          ),
                        )
                      else
                        const VerifiedBadge(style: VerifiedBadgeStyle.plain),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    questionInfo(question),
                    style: const TextStyle(
                      fontSize: 9,
                      height: 1.5,
                      color: AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerHeading(int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFF7F7F7), width: 8),
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              text: '선배 답변 ',
              children: [
                TextSpan(
                  text: '$count',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSub,
                  ),
                ),
              ],
            ),
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.text,
            ),
          ),
          if (count > 0)
            const Text(
              '도움순',
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: AppColors.textSub,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyAnswers() {
    return Container(
      constraints: const BoxConstraints(minHeight: 270),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 55),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55,
            height: 55,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.iconBackground,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'Q',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textInactive,
              ),
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            '아직 답변이 없어요',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            '선배의 답변을 기다려 주세요.',
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: AppColors.textSub,
            ),
          ),
        ],
      ),
    );
  }

  // ───── 아래쪽 답변 입력칸 ─────
  // 평소: 둥근 한 줄 칸 (디자인: QADetail)
  // 입력 중: 키보드 위로 올라오고 칸이 커진다 (디자인: QADetail-Typing)
  Widget _buildAnswerInput() {
    final typing = _answerFocus.hasFocus;
    final hasText = _answerController.text.trim().isNotEmpty;

    return Container(
      padding: typing
          ? const EdgeInsets.all(10).copyWith(left: 15, right: 15)
          : const EdgeInsets.fromLTRB(15, 9, 15, 25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              height: typing ? 82 : 46,
              child: TextField(
                controller: _answerController,
                focusNode: _answerFocus,
                onChanged: (_) => setState(() {}),
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                cursorColor: AppColors.text,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.text,
                ),
                decoration: InputDecoration(
                  hintText: '선배님의 답변을 남겨주세요',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.textInactive,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  enabledBorder: _inputBorder(typing),
                  focusedBorder: _inputBorder(typing),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 46,
            child: TextButton(
              onPressed: hasText ? _submitAnswer : null,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: Size.zero,
                foregroundColor: AppColors.text,
                disabledForegroundColor: AppColors.textInactive,
              ),
              child: const Text(
                '등록',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder(bool typing) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(typing ? 10 : 23),
    borderSide: const BorderSide(color: AppColors.separator),
  );
}

// 성을 뺀 이름 첫 글자 (디자인: 이서연 → 서, 김민지 → 민)
String _avatarLetter(String name) =>
    name.length > 1 ? name.substring(1, 2) : name;

// 선배 답변 한 칸: 작성자, 내용, 도움돼요
class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.answer, required this.isFirst});

  final Answer answer;
  final bool isFirst; // 맨 위 답변은 검정 동그라미, 나머지는 회색

  @override
  Widget build(BuildContext context) {
    final liked = QaService.isLiked(answer.id);
    // 그 선배가 쓴 후기가 있을 때만 선배 프로필로 간다 (선배 프로필은 후기 기준 화면)
    final authorReviews = answer.authorId.isEmpty
        ? const []
        : ReviewService.reviewsByAuthor(answer.authorId);

    final author = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFirst ? AppColors.text : const Color(0xFF555555),
              shape: BoxShape.circle,
            ),
            child: Text(
              _avatarLetter(answer.authorName),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      answer.authorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.5,
                        color: AppColors.textBody, // 디자인: .author color #666666
                      ),
                    ),
                    const SizedBox(width: 8),
                    const VerifiedBadge(style: VerifiedBadgeStyle.muted),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  answer.authorInfo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.5,
                    color: AppColors.textSub,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (authorReviews.isEmpty)
            author
          else
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      SeniorProfileScreen(review: authorReviews.first),
                ),
              ),
              child: author,
            ),
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 16),
            child: Text(
              keepAll(answer.content),
              style: const TextStyle(
                fontSize: 14,
                height: 1.75,
                color: Color(0xFF333333),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => QaService.toggleLike(answer).catchError((error) {
              debugPrint('도움돼요 저장 실패: $error');
              if (context.mounted) {
                showBlackToast(context, '도움돼요를 저장하지 못했어요', showCheck: false);
              }
            }),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: liked ? AppColors.text : AppColors.textBody,
                ),
                const SizedBox(width: 6),
                Text(
                  '도움돼요 ${QaService.likeCountOf(answer)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: AppColors.textBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
