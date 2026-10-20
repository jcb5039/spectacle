// [B] 기능: 질문·답변 저장·불러오기, Q&A 키워드 검색(앱 안에서 걸러내기) (Firestore questions)
import 'package:flutter/foundation.dart';

import '../models/answer.dart';
import '../models/question.dart';
import 'review_service.dart';

class QaService {
  QaService._();

  // 질문·답변이 바뀌면 값이 올라간다. 화면은 이것을 지켜보다가 다시 그린다.
  static final ValueNotifier<int> changes = ValueNotifier(0);

  // 이 앱에서 새로 쓴 질문 (앱을 끄면 사라진다. Firestore 연결 전까지)
  static final List<Question> questions = [];

  static void addQuestion(Question question) {
    questions.insert(0, question);
    changes.value++;
  }

  // Q&A 목록: 새로 쓴 질문이 맨 앞, 그다음 예시 질문
  static List<Question> get allQuestions => [...questions, ..._sampleQuestions];

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

  // 이 앱에서 새로 쓴 답변 (앱을 끄면 사라진다. Firestore 연결 전까지)
  static final List<Answer> _writtenAnswers = [];

  // 내가 도움돼요(좋아요)를 누른 답변 id
  static final Set<String> _likedAnswerIds = {};

  static void addAnswer(Answer answer) {
    _writtenAnswers.add(answer);
    changes.value++;
  }

  static List<Answer> answersOf(String questionId) => [
    ..._sampleAnswers,
    ..._writtenAnswers,
  ].where((a) => a.questionId == questionId).toList();

  // 답변 수는 실제 답변 개수로 센다.
  static int answerCountOf(String questionId) => answersOf(questionId).length;

  static bool isLiked(String answerId) => _likedAnswerIds.contains(answerId);

  // 내가 누른 도움돼요까지 더한 수
  static int likeCountOf(Answer answer) =>
      answer.likeCount + (isLiked(answer.id) ? 1 : 0);

  static void toggleLike(String answerId) {
    if (!_likedAnswerIds.remove(answerId)) _likedAnswerIds.add(answerId);
    changes.value++;
  }

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

// 지금 사용자로 답변 만들기 (로그인 기능(A 담당)이 생기기 전까지 예시 사용자)
Answer newAnswerFromCurrentUser(String questionId, String content) => Answer(
  id: 'a${DateTime.now().millisecondsSinceEpoch}',
  questionId: questionId,
  content: content,
  authorId: SampleCurrentUser.id,
  authorName: SampleCurrentUser.name,
  authorSchool: SampleCurrentUser.school,
  authorDepartment: SampleCurrentUser.department,
  authorCompany: SampleCurrentUser.company,
  authorJob: SampleCurrentUser.job,
  createdAt: DateTime.now(),
);
