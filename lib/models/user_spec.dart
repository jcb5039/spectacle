// [A] 데이터 모양: 내 스펙 (학점, 어학 성적, 자격증, 경험·활동, 스펙 공개 여부). MY·스펙 수정 화면에서 사용 (디자인: My, SpecEdit)

class LanguageScore {
  const LanguageScore({required this.testName, required this.score});

  final String testName;
  final String score;

  Map<String, dynamic> toMap() => {'testName': testName, 'score': score};

  factory LanguageScore.fromMap(Map<String, dynamic> map) => LanguageScore(
    testName: map['testName'] as String? ?? '',
    score: map['score'] as String? ?? '',
  );
}

class Certificate {
  const Certificate({required this.name, required this.acquiredDate});

  final String name;
  final String acquiredDate;

  Map<String, dynamic> toMap() => {'name': name, 'acquiredDate': acquiredDate};

  factory Certificate.fromMap(Map<String, dynamic> map) => Certificate(
    name: map['name'] as String? ?? '',
    acquiredDate: map['acquiredDate'] as String? ?? '',
  );
}

class Activity {
  const Activity({required this.name, required this.description});

  final String name;
  final String description;

  Map<String, dynamic> toMap() => {'name': name, 'description': description};

  factory Activity.fromMap(Map<String, dynamic> map) => Activity(
    name: map['name'] as String? ?? '',
    description: map['description'] as String? ?? '',
  );
}

class UserSpec {
  const UserSpec({
    this.isPublic = true,
    this.gpa = '',
    this.gpaScale = '',
    this.languageScores = const [],
    this.certificates = const [],
    this.activities = const [],
  });

  final bool isPublic;
  final String gpa;
  final String gpaScale;
  final List<LanguageScore> languageScores;
  final List<Certificate> certificates;
  final List<Activity> activities;

  // MY 화면의 스펙 칩 문구 (예: TOEIC 845, SMAT, 항공사 현장실습)
  List<String> get chips => [
    for (final score in languageScores)
      '${score.testName} ${score.score}'.trim(),
    for (final certificate in certificates) certificate.name,
    for (final activity in activities) activity.name,
  ].where((chip) => chip.isNotEmpty).toList();

  Map<String, dynamic> toMap() => {
    'isPublic': isPublic,
    'gpa': gpa,
    'gpaScale': gpaScale,
    'languageScores': [for (final score in languageScores) score.toMap()],
    'certificates': [
      for (final certificate in certificates) certificate.toMap(),
    ],
    'activities': [for (final activity in activities) activity.toMap()],
  };

  factory UserSpec.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> listOf(String key) =>
        (map[key] as List? ?? []).cast<Map<String, dynamic>>();
    return UserSpec(
      isPublic: map['isPublic'] as bool? ?? true,
      gpa: map['gpa'] as String? ?? '',
      gpaScale: map['gpaScale'] as String? ?? '',
      languageScores: listOf('languageScores')
          .map(LanguageScore.fromMap)
          .toList(),
      certificates: listOf('certificates').map(Certificate.fromMap).toList(),
      activities: listOf('activities').map(Activity.fromMap).toList(),
    );
  }
}
