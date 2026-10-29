// [A] 06 랭킹·MY > 내 질문·답변 화면: 작성한 질문, 받은 답변 탭 (디자인: My-Questions, My-Answers)
import 'package:flutter/material.dart';

import '../../common/widgets/verified_badge.dart';
import '../../models/answer.dart';
import '../../models/question.dart';
import '../../services/auth_service.dart';
import '../../services/qa_service.dart' show QaService;
import '../auth/widgets/auth_widgets.dart';
import '../qa/qa_detail_screen.dart' show openQaDetail;
import 'widgets/my_widgets.dart';

// 재학생 MY의 숫자 칸 "작성한 질문"(0), "받은 답변"(1)을 누르면 그 탭으로 열린다
class MyActivityScreen extends StatefulWidget {
  const MyActivityScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<MyActivityScreen> createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen> {
  late int _tabIndex = widget.initialTab;

  String get _userId => AuthService.instance.currentUserId ?? 'local-user';

  @override
  void initState() {
    super.initState();
    // 질문·답변은 서버에서 조금 늦게 도착하므로 바뀔 때마다 다시 그린다
    QaService.start();
    QaService.changes.addListener(_refresh);
  }

  @override
  void dispose() {
    QaService.changes.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // 내가 쓴 질문 (최신순)
  List<Question> get _myQuestions =>
      QaService.allQuestions.where((q) => q.authorId == _userId).toList();

  @override
  Widget build(BuildContext context) {
    final questions = _myQuestions;
    // 내 질문에 달린 답변 (최신순)
    final answers = [
      for (final question in questions)
        for (final answer in QaService.answersOf(question.id))
          (question: question, answer: answer),
    ]..sort((a, b) => b.answer.createdAt.compareTo(a.answer.createdAt));

    return Scaffold(
      backgroundColor: AuthColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ModalHeader(title: '내 질문 · 답변'),
            UnderlineTabs(
              labels: ['작성한 질문 ${questions.length}', '받은 답변 ${answers.length}'],
              selectedIndex: _tabIndex,
              onChanged: (index) => setState(() => _tabIndex = index),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                children: _tabIndex == 0
                    ? [
                        for (final question in questions)
                          _QuestionRow(
                            question: question,
                            answerCount: QaService.answerCountOf(question.id),
                            onTap: () => openQaDetail(context, question),
                          ),
                      ]
                    : [
                        for (final item in answers)
                          _ReceivedAnswerCard(
                            question: item.question,
                            answer: item.answer,
                            onTap: () => openQaDetail(context, item.question),
                          ),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 작성한 질문 한 줄: Q, 답변 완료/대기, 제목, 분야 · 시간, 오른쪽 답변 수
class _QuestionRow extends StatelessWidget {
  const _QuestionRow({
    required this.question,
    required this.answerCount,
    required this.onTap,
  });

  final Question question;
  final int answerCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final answered = answerCount > 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 126),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AuthColors.lineEE)),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: 19,
              left: 0,
              child: Text(
                'Q',
                style: TextStyle(
                  color: AuthColors.black,
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(36, 20, 58, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: answered ? AuthColors.black : null,
                      border: answered
                          ? null
                          : Border.all(color: AuthColors.lineDD),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      answered ? '답변 완료' : '답변 대기',
                      style: TextStyle(
                        color: answered ? AuthColors.white : AuthColors.gray8E,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    question.title,
                    style: const TextStyle(
                      color: AuthColors.black,
                      fontSize: 15,
                      height: 1.45,
                      letterSpacing: -0.525,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '${question.category} · ${timeAgo(question.createdAt)}',
                    style: const TextStyle(
                      color: AuthColors.gray8E,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '답변 $answerCount',
                  style: const TextStyle(
                    color: AuthColors.gray66,
                    fontSize: 10,
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

// 받은 답변 카드: Q. 질문, 답변한 선배, 답변 내용, 도움돼요 · 시간
class _ReceivedAnswerCard extends StatelessWidget {
  const _ReceivedAnswerCard({
    required this.question,
    required this.answer,
    required this.onTap,
  });

  final Question question;
  final Answer answer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final info = [
      '${answer.authorSchool} ${answer.authorDepartment}'.trim(),
      answer.authorCompany,
      answer.authorJob,
    ].where((text) => text.isNotEmpty).join(' · ');
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AuthColors.lineEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Q.',
                    style: TextStyle(
                      color: AuthColors.black,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: ' ${question.title}'),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AuthColors.gray8E, fontSize: 11),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ProfileAvatar(name: answer.authorName, size: 42, fontSize: 14),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              answer.authorName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AuthColors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const VerifiedBadge(style: VerifiedBadgeStyle.plain),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        info,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AuthColors.gray8E,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              answer.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 13,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.favorite_border,
                  size: 13,
                  color: AuthColors.gray8E,
                ),
                const SizedBox(width: 4),
                Text(
                  '도움돼요 ${QaService.likeCountOf(answer)} · '
                  '${timeAgo(answer.createdAt)}',
                  style: const TextStyle(
                    color: AuthColors.gray8E,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
