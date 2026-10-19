// [A] 02 시작·회원가입 > 회원가입 1~3단계에서 입력한 내용을 모아 다음 단계로 넘기는 데이터
import '../../models/app_user.dart';

class SignUpData {
  SignUpData({required this.memberType});

  final MemberType memberType;
  String? school;
  String? department;
  int? admissionYear;
  int? graduationYear;
  String? jobGroup;
  String? company;
  String? email;

  bool get isEmployee => memberType == MemberType.employee;

  AppUser toAppUser({
    required String id,
    required VerificationStatus status,
    required VerificationMethod method,
  }) {
    final now = DateTime.now();
    return AppUser(
      id: id,
      email: email ?? '',
      memberType: memberType,
      school: school ?? '',
      department: department ?? '',
      admissionYear: admissionYear,
      graduationYear: graduationYear,
      jobGroup: isEmployee ? jobGroup : null,
      company: isEmployee ? company : null,
      verificationStatus: status,
      verificationMethod: method,
      verifiedAt: status == VerificationStatus.verified ? now : null,
      createdAt: now,
    );
  }
}
