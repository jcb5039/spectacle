// [B] 데이터 모양: Q&A 답변 (내용, 작성자(인증 선배), 작성 시간)

class Answer {
  const Answer({
    required this.id,
    required this.questionId,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorSchool,
    required this.authorDepartment,
    required this.authorCompany,
    required this.authorJob,
    this.likeCount = 0,
    required this.createdAt,
  });

  final String id;
  final String questionId; // 어느 질문의 답변인지
  final String content;

  // 작성자(인증 선배) 정보. 답변 목록에서 바로 보여주려고 함께 저장한다.
  final String authorId;
  final String authorName;
  final String authorSchool; // 예: 대림대
  final String authorDepartment; // 예: 항공서비스
  final String authorCompany; // 예: 에어웨이브
  final String authorJob; // 예: 객실승무원

  final int likeCount; // 좋아요(디자인: 도움돼요) 수
  final DateTime createdAt;

  // Firestore answers 컬렉션에 저장할 모양 (문서 이름 = id)
  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorSchool': authorSchool,
      'authorDepartment': authorDepartment,
      'authorCompany': authorCompany,
      'authorJob': authorJob,
      'likeCount': likeCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Answer.fromMap(String id, Map<String, dynamic> map) {
    return Answer(
      id: id,
      questionId: map['questionId'] as String? ?? '',
      content: map['content'] as String? ?? '',
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      authorSchool: map['authorSchool'] as String? ?? '',
      authorDepartment: map['authorDepartment'] as String? ?? '',
      authorCompany: map['authorCompany'] as String? ?? '',
      authorJob: map['authorJob'] as String? ?? '',
      likeCount: (map['likeCount'] as num? ?? 0).toInt(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num? ?? 0).toInt(),
      ),
    );
  }

  // 디자인: "대림대 항공서비스 · 에어웨이브 · 객실승무원"
  String get authorInfo => [
    '$authorSchool $authorDepartment'.trim(),
    authorCompany,
    authorJob,
  ].where((t) => t.isNotEmpty).join(' · ');
}
