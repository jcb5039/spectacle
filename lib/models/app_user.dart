// [A] 데이터 모양: 회원 (회원 유형 취업자·재학생, 학교, 학과, 입학·졸업년도, 회사, 직군, 인증 상태)
import 'user_spec.dart';

enum MemberType { employee, student }

// pending: 증명서 확인 대기, verified: 인증 완료
enum VerificationStatus { pending, verified }

// certificate: 증명서 사진(관리자 확인), schoolEmail: 학교 이메일 링크
enum VerificationMethod { certificate, schoolEmail }

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
    this.jobTitle,
    this.name,
    this.phone,
    this.verificationMethod,
    this.verifiedAt,
    this.showCompany = true,
    this.allowQuestions = true,
    this.spec = const UserSpec(),
  });

  final String id;
  final String email;
  final MemberType memberType;
  final String school;
  final String department;
  final int? admissionYear;
  // 취업자는 졸업년도, 재학생은 졸업 예정년도
  final int? graduationYear;
  // 취업자만 사용: 직군(항공·관광 등), 회사명, 직무(객실승무원 등)
  final String? jobGroup;
  final String? company;
  final String? jobTitle;
  // 회원가입에서 아직 받지 않는 정보 (Firebase 연결 후 받을 예정)
  final String? name;
  final String? phone;
  final VerificationStatus verificationStatus;
  final VerificationMethod? verificationMethod;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  // 공개 및 알림 설정 (취업자만 사용)
  final bool showCompany;
  final bool allowQuestions;
  final UserSpec spec;

  bool get isEmployee => memberType == MemberType.employee;
  bool get isVerified => verificationStatus == VerificationStatus.verified;

  AppUser copyWith({
    String? email,
    String? school,
    String? department,
    int? admissionYear,
    int? graduationYear,
    String? company,
    String? jobTitle,
    String? name,
    String? phone,
    bool? showCompany,
    bool? allowQuestions,
    UserSpec? spec,
  }) {
    return AppUser(
      id: id,
      email: email ?? this.email,
      memberType: memberType,
      school: school ?? this.school,
      department: department ?? this.department,
      admissionYear: admissionYear ?? this.admissionYear,
      graduationYear: graduationYear ?? this.graduationYear,
      verificationStatus: verificationStatus,
      createdAt: createdAt,
      jobGroup: jobGroup,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      verificationMethod: verificationMethod,
      verifiedAt: verifiedAt,
      showCompany: showCompany ?? this.showCompany,
      allowQuestions: allowQuestions ?? this.allowQuestions,
      spec: spec ?? this.spec,
    );
  }

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
      'jobTitle': jobTitle,
      'name': name,
      'phone': phone,
      'verificationStatus': verificationStatus.name,
      'verificationMethod': verificationMethod?.name,
      'verifiedAt': verifiedAt?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'showCompany': showCompany,
      'allowQuestions': allowQuestions,
      'spec': spec.toMap(),
    };
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    final method = map['verificationMethod'] as String?;
    final verifiedAt = map['verifiedAt'] as int?;
    final spec = map['spec'] as Map<String, dynamic>?;
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
      jobTitle: map['jobTitle'] as String?,
      name: map['name'] as String?,
      phone: map['phone'] as String?,
      verificationStatus: VerificationStatus.values.byName(
        map['verificationStatus'] as String,
      ),
      verificationMethod: method == null
          ? null
          : VerificationMethod.values.byName(method),
      verifiedAt: verifiedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(verifiedAt),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      showCompany: map['showCompany'] as bool? ?? true,
      allowQuestions: map['allowQuestions'] as bool? ?? true,
      spec: spec == null ? const UserSpec() : UserSpec.fromMap(spec),
    );
  }
}
