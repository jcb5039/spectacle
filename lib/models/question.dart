// [B] 데이터 모양: Q&A 질문 (제목, 내용, 분야, 작성자, 답변 수)

class Question {
  const Question({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorType,
    required this.authorSchool,
    required this.authorDepartment,
    this.showSchool = true,
    this.answerCount = 0,
    required this.createdAt,
  });

  final String id;
  final String category; // 물어볼 직무 분야 예: 항공·관광
  final String title;
  final String content;

  // 작성자 정보. 목록에서 바로 보여주려고 질문에 함께 저장한다.
  final String authorId;
  final String authorName;
  final String authorType; // 재학생 / 취업자
  final String authorSchool;
  final String authorDepartment;
  final bool showSchool; // "학교 학과 표시하기"를 켰는지

  final int answerCount;
  final DateTime createdAt;
}
