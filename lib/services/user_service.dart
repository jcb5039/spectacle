// [A] 기능: 회원 정보 저장·불러오기·수정, 인증 상태 확인 (Firestore users)
import '../models/app_user.dart';
import '../models/user_spec.dart';

// Firebase 연결 전까지는 FakeUserService(앱이 켜져 있는 동안만 기억)가 동작한다.
// 연결할 때 Firestore users 컬렉션을 쓰는 구현을 만들어 instance만 바꾸면 된다.
abstract class UserService {
  static UserService instance = FakeUserService();

  // 새로 저장하거나, 같은 id가 있으면 덮어쓴다 (개인정보·스펙 수정도 이걸 사용)
  Future<void> saveUser(AppUser user);

  Future<AppUser?> getUser(String userId);
}

class FakeUserService implements UserService {
  // 화면 확인용 예시 회원 (디자인 MY 화면의 김민지)
  final Map<String, AppUser> _users = {
    'local-user': AppUser(
      id: 'local-user',
      email: 'minji@email.com',
      memberType: MemberType.employee,
      school: '대림대학교',
      department: '항공서비스',
      admissionYear: 2020,
      graduationYear: 2023,
      jobGroup: '항공·관광',
      company: '에어웨이브',
      jobTitle: '객실승무원',
      name: '김민지',
      phone: '010-1234-5678',
      verificationStatus: VerificationStatus.verified,
      verificationMethod: VerificationMethod.certificate,
      verifiedAt: DateTime(2024, 3, 12),
      createdAt: DateTime(2024, 3, 10),
      spec: const UserSpec(
        languageScores: [
          LanguageScore(testName: 'TOEIC', score: '845'),
          LanguageScore(testName: 'OPIc', score: 'IM2'),
        ],
        certificates: [
          Certificate(name: 'CRS 자격', acquiredDate: ''),
          Certificate(name: 'SMAT', acquiredDate: ''),
        ],
        activities: [
          Activity(name: '항공사 현장실습', description: '안전 교육 및 기내 서비스 실습 · 4주'),
        ],
      ),
    ),
  };

  @override
  Future<void> saveUser(AppUser user) async {
    _users[user.id] = user;
  }

  @override
  Future<AppUser?> getUser(String userId) async => _users[userId];
}
