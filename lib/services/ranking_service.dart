// [A] 기능: 랭킹 계산(좋아요 많은 글, 활동 많은 선배), MY의 내가 쓴 글·질문 불러오기

// 아래 요약 모양들은 랭킹·MY 화면에 보여줄 것만 담는다.
// B가 models/review.dart, question.dart를 만들면 Firebase 연결 때 그 데이터로 채운다.

class RankedPost {
  const RankedPost({
    required this.reviewId,
    required this.title,
    required this.likeCount,
  });

  final String reviewId;
  final String title;
  final int likeCount;
}

class RankedSenior {
  const RankedSenior({
    required this.userId,
    required this.name,
    required this.company,
    required this.jobTitle,
    required this.answerCount,
  });

  final String userId;
  final String name;
  final String company;
  final String jobTitle;
  final int answerCount;
}

// MY 목록의 후기 한 줄 (내가 쓴 글, 좋아요 누른 후기)
class ReviewSummary {
  const ReviewSummary({
    required this.reviewId,
    required this.title,
    required this.subtitle,
  });

  final String reviewId;
  final String title;
  // 예: 에어웨이브 · 객실승무원 · 항공서비스
  final String subtitle;
}

// MY 목록의 질문 한 줄 (내 질문, 내가 답변한 질문)
class QuestionSummary {
  const QuestionSummary({
    required this.questionId,
    required this.title,
    required this.answerCount,
    required this.createdAt,
  });

  final String questionId;
  final String title;
  final int answerCount;
  final DateTime createdAt;
}

// MY 가운데 숫자 3칸
class MyActivityStats {
  const MyActivityStats({
    required this.reviewCount,
    required this.receivedLikeCount,
    required this.answerCount,
    required this.questionCount,
    required this.receivedAnswerCount,
    required this.givenLikeCount,
  });

  // 취업자: 작성한 후기, 받은 좋아요, 답변
  final int reviewCount;
  final int receivedLikeCount;
  final int answerCount;
  // 재학생: 작성한 질문, 받은 답변, 누른 좋아요
  final int questionCount;
  final int receivedAnswerCount;
  final int givenLikeCount;
}

// Firebase 연결 전까지는 FakeRankingService(디자인 예시 데이터)가 동작한다.
// 연결할 때 Firestore reviews·questions·likes를 읽는 구현을 만들어 instance만 바꾸면 된다.
abstract class RankingService {
  static RankingService instance = FakeRankingService();

  // 좋아요 수가 많은 후기 순서
  Future<List<RankedPost>> topHelpfulPosts({int limit = 10});

  // 답변 수가 많은 인증 선배 순서
  Future<List<RankedSenior>> topActiveSeniors({int limit = 10});

  Future<MyActivityStats> myStats(String userId);

  Future<List<ReviewSummary>> myReviews(String userId);

  Future<List<QuestionSummary>> myAnsweredQuestions(String userId);

  Future<List<QuestionSummary>> myQuestions(String userId);

  Future<List<ReviewSummary>> likedReviews(String userId);
}

class FakeRankingService implements RankingService {
  static const _reviews = [
    ReviewSummary(
      reviewId: 'review-1',
      title: '첫 비행 전까지, 항공서비스학과 선배의 준비 기록',
      subtitle: '에어웨이브 · 객실승무원 · 항공서비스',
    ),
    ReviewSummary(
      reviewId: 'review-2',
      title: '호텔 주방 막내 조리사가 알려주는 취업 준비',
      subtitle: '그랜드리프 · 양식 조리사 · 호텔조리',
    ),
    ReviewSummary(
      reviewId: 'review-3',
      title: '제과제빵 자격증보다 현장에서 중요했던 것',
      subtitle: '메종브레드 · 파티시에 · 제과제빵',
    ),
  ];

  @override
  Future<List<RankedPost>> topHelpfulPosts({int limit = 10}) async {
    return const [
      RankedPost(
        reviewId: 'review-1',
        title: '첫 비행 전까지, 항공서비스학과 선배의 준비 기록',
        likeCount: 128,
      ),
      RankedPost(
        reviewId: 'review-4',
        title: '호텔 주방 신입의 첫 100일, 솔직 후기',
        likeCount: 109,
      ),
      RankedPost(
        reviewId: 'review-3',
        title: '제과제빵 자격증보다 현장에서 중요했던 것',
        likeCount: 96,
      ),
      RankedPost(
        reviewId: 'review-5',
        title: '신규 간호사의 첫 병동 적응기',
        likeCount: 84,
      ),
    ].take(limit).toList();
  }

  @override
  Future<List<RankedSenior>> topActiveSeniors({int limit = 10}) async {
    return const [
      RankedSenior(
        userId: 'senior-1',
        name: '김민지',
        company: '에어웨이브',
        jobTitle: '객실승무원',
        answerCount: 24,
      ),
      RankedSenior(
        userId: 'senior-2',
        name: '박준호',
        company: '그랜드리프',
        jobTitle: '양식 조리사',
        answerCount: 21,
      ),
      RankedSenior(
        userId: 'senior-3',
        name: '최유진',
        company: '호텔 마레',
        jobTitle: '프런트 매니저',
        answerCount: 18,
      ),
      RankedSenior(
        userId: 'senior-4',
        name: '정하늘',
        company: '서림메디컬',
        jobTitle: '간호사',
        answerCount: 15,
      ),
    ].take(limit).toList();
  }

  @override
  Future<MyActivityStats> myStats(String userId) async {
    return const MyActivityStats(
      reviewCount: 5,
      receivedLikeCount: 128,
      answerCount: 24,
      questionCount: 3,
      receivedAnswerCount: 5,
      givenLikeCount: 12,
    );
  }

  @override
  Future<List<ReviewSummary>> myReviews(String userId) async => _reviews;

  @override
  Future<List<QuestionSummary>> myAnsweredQuestions(String userId) async =>
      _questions();

  @override
  Future<List<QuestionSummary>> myQuestions(String userId) async =>
      _questions();

  @override
  Future<List<ReviewSummary>> likedReviews(String userId) async => _reviews;

  List<QuestionSummary> _questions() {
    final now = DateTime.now();
    return [
      QuestionSummary(
        questionId: 'question-1',
        title: '항공사 면접에서 영어 답변은 어느 정도 준비해야 하나요?',
        answerCount: 3,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      QuestionSummary(
        questionId: 'question-2',
        title: '객실승무원 체력 시험은 어떻게 준비하셨나요?',
        answerCount: 2,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      QuestionSummary(
        questionId: 'question-3',
        title: '토익은 몇 점부터 항공사에 지원할 수 있나요?',
        answerCount: 0,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }
}
