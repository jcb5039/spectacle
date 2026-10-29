// [B] 기능: 질문·답변 저장·불러오기, Q&A 키워드 검색(앱 안에서 걸러내기) (Firestore questions)
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/answer.dart';
import '../models/question.dart';
import 'review_service.dart';

class QaService {
  QaService._();

  // 질문·답변이 바뀌면 값이 올라간다. 화면은 이것을 지켜보다가 다시 그린다.
  static final ValueNotifier<int> changes = ValueNotifier(0);

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  // 서버(Firestore)에 있는 질문·답변. 가짜 로그인에서는 새로 쓴 글이 여기에만 들어간다.
  static final List<Question> _serverQuestions = []; // 최신순
  static final List<Answer> _serverAnswers = []; // 오래된 순
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _questionSub;
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _answerSub;

  // Q&A 화면들이 켜질 때 부른다. 여러 번 불러도 한 번만 연결한다.
  static void start() {
    CurrentMember.load();
    Likes.start();
    if (!firebaseReady) return;
    _questionSub ??= _db
        .collection('questions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _serverQuestions
              ..clear()
              ..addAll(
                snapshot.docs.map((d) => Question.fromMap(d.id, d.data())),
              );
            changes.value++;
          },
          onError: (Object error) {
            debugPrint('질문을 불러오지 못했어요: $error');
            _questionSub = null;
          },
        );
    _answerSub ??= _db
        .collection('answers')
        .orderBy('createdAt')
        .snapshots()
        .listen(
          (snapshot) {
            _serverAnswers
              ..clear()
              ..addAll(
                snapshot.docs.map((d) => Answer.fromMap(d.id, d.data())),
              );
            changes.value++;
          },
          onError: (Object error) {
            debugPrint('답변을 불러오지 못했어요: $error');
            _answerSub = null;
          },
        );
  }

  // 알림 등에서 질문 id로 찾기 (없으면 null)
  static Question? findQuestion(String? id) {
    if (id == null) return null;
    for (final q in allQuestions) {
      if (q.id == id) return q;
    }
    return null;
  }

  static String newQuestionId() => firebaseReady
      ? _db.collection('questions').doc().id
      : 'q${DateTime.now().millisecondsSinceEpoch}';

  // 저장에 실패하면 오류를 그대로 넘긴다 (화면에서 안내)
  static Future<void> addQuestion(Question question) async {
    if (!firebaseReady) {
      _serverQuestions.insert(0, question);
      changes.value++;
      return;
    }
    await _db.collection('questions').doc(question.id).set(question.toMap());
  }

  // Q&A 목록: 서버 질문(최신순), 그다음 예시 질문
  static List<Question> get allQuestions => [
    ..._serverQuestions,
    if (showSampleData) ..._sampleQuestions,
  ];

  // Q&A 목록·검색 결과: 직무 탭과 검색어로 앱 안에서 걸러낸다.
  static List<Question> searchQuestions({
    String keyword = '',
    String category = '전체',
  }) {
    final word = keyword.trim().toLowerCase();
    return allQuestions.where((q) {
      if (category != '전체' && q.category != category) return false;
      if (word.isEmpty) return true;
      return [
        q.title,
        q.content,
        q.category,
        q.authorDepartment,
      ].any((text) => text.toLowerCase().contains(word));
    }).toList();
  }

  // ───── 답변 ─────

  static String newAnswerId() => firebaseReady
      ? _db.collection('answers').doc().id
      : 'a${DateTime.now().millisecondsSinceEpoch}';

  // 저장에 실패하면 오류를 그대로 넘긴다 (화면에서 안내)
  static Future<void> addAnswer(Answer answer) async {
    if (!firebaseReady) {
      _serverAnswers.add(answer);
      changes.value++;
      return;
    }
    await _db.collection('answers').doc(answer.id).set(answer.toMap());
  }

  static List<Answer> answersOf(String questionId) => [
    if (showSampleData) ..._sampleAnswers,
    ..._serverAnswers,
  ].where((a) => a.questionId == questionId).toList();

  // 모든 답변 (랭킹의 활동 많은 선배 계산)
  static List<Answer> get allAnswers => [
    if (showSampleData) ..._sampleAnswers,
    ..._serverAnswers,
  ];

  // 선배 프로필의 답변 수: 그 선배가 쓴 답변 (작성자 id가 없으면 0)
  static List<Answer> answersByAuthor(String authorId) => authorId.isEmpty
      ? []
      : [
          if (showSampleData) ..._sampleAnswers,
          ..._serverAnswers,
        ].where((a) => a.authorId == authorId).toList();

  // 답변 수는 실제 답변 개수로 센다.
  static int answerCountOf(String questionId) => answersOf(questionId).length;

  static bool _isSample(Answer answer) =>
      _sampleAnswers.any((a) => a.id == answer.id);

  static bool isLiked(String answerId) => Likes.isLiked(answerId);

  // 서버 답변은 서버의 likeCount에 내 좋아요가 이미 들어 있다.
  static int likeCountOf(Answer answer) =>
      answer.likeCount + (_isSample(answer) && isLiked(answer.id) ? 1 : 0);

  static Future<void> toggleLike(Answer answer) => Likes.toggle(
    collection: 'answers',
    targetId: answer.id,
    isSample: _isSample(answer),
  );

  // ───── 예시 데이터 (Firestore 연결 전까지, 디자인에 적힌 내용) ─────
  // 디자인에 없는 본문·작성자는 비워 둔다.

  static final DateTime _now = DateTime.now();

  static final List<Question> _sampleQuestions = [
    Question(
      id: 'q1',
      category: '항공·관광',
      title: '항공사 면접에서 영어 답변은 어느 정도 준비해야 하나요?',
      content: '영어 면접이 처음이라 어느 수준까지 답변을 준비해야 할지 막막해요. 자주 나오는 질문과 준비 방법이 궁금합니다.',
      authorId: 's1',
      authorName: '이서연',
      authorType: '재학생',
      authorSchool: '대림대',
      authorDepartment: '항공서비스',
      createdAt: _now.subtract(const Duration(hours: 2)),
    ),
    Question(
      id: 'q2',
      category: '조리·제과',
      title: '호텔조리 취업 전에 현장 실습이 꼭 필요할까요?',
      content: '',
      authorId: '',
      authorName: '',
      authorType: '재학생',
      authorSchool: '대림대',
      authorDepartment: '호텔조리',
      createdAt: _now.subtract(const Duration(hours: 5)),
    ),
    Question(
      id: 'q3',
      category: '조리·제과',
      title: '제과제빵 자격증은 몇 개까지 준비하는 게 좋나요?',
      content: '',
      authorId: '',
      authorName: '',
      authorType: '재학생',
      authorSchool: '대림대',
      authorDepartment: '제과제빵',
      createdAt: _now.subtract(const Duration(days: 1)),
    ),
    Question(
      id: 'q4',
      category: '보건·의료',
      title: '신규 간호사 지원 시 학점이 많이 중요한가요?',
      content: '',
      authorId: '',
      authorName: '',
      authorType: '재학생',
      authorSchool: '대림대',
      authorDepartment: '간호학',
      createdAt: _now.subtract(const Duration(days: 2)),
    ),
    Question(
      id: 'q5',
      category: '호텔·외식',
      title: '호텔 프런트 지원에 필요한 어학 성적이 궁금해요',
      content: '국내 호텔 프런트 직무를 준비 중입니다. 토익과 회화 성적을 어느 정도까지 준비해야 할까요?',
      authorId: 's1',
      authorName: '이서연',
      authorType: '재학생',
      authorSchool: '대림대',
      authorDepartment: '호텔관광',
      createdAt: _now.subtract(const Duration(days: 3)),
    ),
  ];

  static final List<Answer> _sampleAnswers = [
    Answer(
      id: 'a1',
      questionId: 'q1',
      content: '긴 문장을 외우기보다 자기소개, 지원 동기, 서비스 경험을 4~5문장으로 자연스럽게 말하는 연습부터 해보세요. 예상 밖 질문에는 결론부터 짧게 답하는 것이 중요해요.',
      authorId: 'u1',
      authorName: '김민지',
      authorSchool: '대림대',
      authorDepartment: '항공서비스',
      authorCompany: '에어웨이브',
      authorJob: '객실승무원',
      likeCount: 12,
      createdAt: _now.subtract(const Duration(hours: 1)),
    ),
    Answer(
      id: 'a2',
      questionId: 'q1',
      content:
          '완벽한 문법보다 표정과 전달력이 더 중요했어요. 휴대폰으로 촬영하면서 말의 속도와 시선 처리를 함께 확인해보세요.',
      authorId: '',
      authorName: '최유진',
      authorSchool: '대림대',
      authorDepartment: '항공서비스',
      authorCompany: '호텔 마레',
      authorJob: '프런트 매니저',
      likeCount: 8,
      createdAt: _now.subtract(const Duration(hours: 1)),
    ),
    Answer(
      id: 'a3',
      questionId: 'q1',
      content: '기내 상황 롤플레이를 영어로 준비하면 도움이 됩니다. 승객 요청을 확인하고 대안을 제시하는 표현을 익혀두세요.',
      authorId: '',
      authorName: '박서진',
      authorSchool: '대림대',
      authorDepartment: '항공서비스',
      authorCompany: '대한항공',
      authorJob: '객실승무원',
      likeCount: 6,
      createdAt: _now.subtract(const Duration(hours: 1)),
    ),
  ];
}

// 작성 시간을 "방금 / N분 전 / N시간 전 / 어제 / N일 전"으로 (디자인: 2시간 전, 어제, 3일 전)
String timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return '방금';
  if (diff.inHours < 1) return '${diff.inMinutes}분 전';
  if (diff.inDays < 1) return '${diff.inHours}시간 전';
  if (diff.inDays == 1) return '어제';
  return '${diff.inDays}일 전';
}

// 질문 목록·상세의 작성자 줄: "재학생 · 항공서비스 · 2시간 전"
String questionInfo(Question question) => [
  question.authorType,
  if (question.showSchool && question.authorDepartment.isNotEmpty)
    question.authorDepartment,
  timeAgo(question.createdAt),
].join(' · ');

// 지금 로그인한 회원으로 답변 만들기
Answer newAnswerFromCurrentUser(String questionId, String content) => Answer(
  id: QaService.newAnswerId(),
  questionId: questionId,
  content: content,
  authorId: CurrentMember.id,
  authorName: CurrentMember.name,
  authorSchool: CurrentMember.school,
  authorDepartment: CurrentMember.department,
  authorCompany: CurrentMember.company,
  authorJob: CurrentMember.job,
  createdAt: DateTime.now(),
);
