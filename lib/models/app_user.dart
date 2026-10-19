// [A] 데이터 모양: 회원 (회원 유형 취업자·재학생, 학교, 학과, 입학·졸업년도, 회사, 직군, 인증 상태)

enum MemberType { employee, student }

// pending: 증명서 확인 대기, verified: 인증 완료
enum VerificationStatus { pending, verified }

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.memberType,
    required this.school,
    required this.department,
    required this.admissionYear,
    required this.graduationYear,
    required this.verificationStatus,
    required this.createdAt,
    this.jobGroup,
    this.company,
  });

  final String id;
  final String email;
  final MemberType memberType;
  final String school;
  final String department;
  final int? admissionYear;
  // 취업자는 졸업년도, 재학생은 졸업 예정년도
  final int? graduationYear;
  // 취업자만 사용
  final String? jobGroup;
  final String? company;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;

  bool get isEmployee => memberType == MemberType.employee;
  bool get isVerified => verificationStatus == VerificationStatus.verified;

  // Firestore users 컬렉션에 저장할 모양
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'memberType': memberType.name,
      'school': school,
      'department': department,
      'admissionYear': admissionYear,
      'graduationYear': graduationYear,
      'jobGroup': jobGroup,
      'company': company,
      'verificationStatus': verificationStatus.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      email: map['email'] as String? ?? '',
      memberType: MemberType.values.byName(map['memberType'] as String),
      school: map['school'] as String? ?? '',
      department: map['department'] as String? ?? '',
      admissionYear: map['admissionYear'] as int?,
      graduationYear: map['graduationYear'] as int?,
      jobGroup: map['jobGroup'] as String?,
      company: map['company'] as String?,
      verificationStatus: VerificationStatus.values.byName(
        map['verificationStatus'] as String,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
