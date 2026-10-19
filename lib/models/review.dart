// [B] 데이터 모양: 취업 후기 (항목별 내용, 직군, 기업, 포트폴리오 링크, 작성자, 좋아요 수)

// 후기에 붙이는 취업 준비 자료 링크 (Notion, Drive, GitHub 등)
class ReviewLink {
  const ReviewLink({
    required this.type,
    required this.title,
    required this.url,
  });

  final String type; // 예: Notion, Drive, GitHub
  final String title;
  final String url;
}

class Review {
  const Review({
    required this.id,
    required this.category,
    required this.title,
    required this.company,
    required this.job,
    required this.authorId,
    required this.authorName,
    required this.authorSchool,
    required this.authorDepartment,
    required this.authorAdmissionYear,
    required this.authorGraduationYear,
    this.preparation = '',
    this.difficulty = '',
    this.trialAndError = '',
    this.tip = '',
    this.quote = '',
    this.links = const [],
    this.hashtags = const [],
    this.photos = const [],
    this.photoCaption = '',
    this.likeCount = 0,
    required this.createdAt,
  });

  final String id;
  final String category; // 직무 분야 예: 항공·관광
  final String title;
  final String company; // 회사 이름
  final String job; // 직무 예: 객실승무원

  // 작성자(인증 선배) 정보. 목록에서 바로 보여주려고 후기에 함께 저장한다.
  final String authorId;
  final String authorName;
  final String authorSchool; // 예: 대림대
  final String authorDepartment; // 예: 항공서비스
  final String authorAdmissionYear; // 학번 두 자리 예: 20
  final String authorGraduationYear; // 졸업연도 두 자리 예: 23

  // 본문 4항목 (디자인: 01~04)
  final String preparation; // 01 취업 준비 과정
  final String difficulty; // 02 취업 과정의 어려움
  final String trialAndError; // 03 신입 시절 시행착오
  final String tip; // 04 후배에게 주는 팁
  final String quote; // 인용문 (03 아래)

  final List<ReviewLink> links; // 취업 준비 자료
  final List<String> hashtags; // # 없이 저장 예: 객실승무원
  final List<String> photos; // 1MB 이하로 줄인 사진 (Firestore 저장 방식은 연결할 때 정한다)
  final String photoCaption;

  final int likeCount; // 좋아요(디자인: 도움돼요) 수
  final DateTime createdAt;

  String get companyAndJob => '$company · $job';
}
