// [A] 기능: 회원 정보 저장·불러오기·수정, 인증 상태 확인 (Firestore users)
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/user_spec.dart';

// 기본값은 FakeUserService(가짜, 테스트용)이고, 앱을 켤 때 main.dart에서 FirestoreUserService로 바꾼다.
abstract class UserService {
  static UserService instance = FakeUserService();

  // 새로 저장하거나, 같은 id가 있으면 덮어쓴다 (개인정보·스펙 수정도 이걸 사용)
  Future<void> saveUser(AppUser user);

  Future<AppUser?> getUser(String userId);
}

// 실제 Firestore users 컬렉션 (문서 이름 = 로그인 계정 id)
class FirestoreUserService implements UserService {
  CollectionReference<Map<String, dynamic>> get _users =>
      FirebaseFirestore.instance.collection('users');

  @override
  Future<void> saveUser(AppUser user) => _users.doc(user.id).set(user.toMap());

  @override
  Future<AppUser?> getUser(String userId) async {
    final snapshot = await _users.doc(userId).get();
    final data = snapshot.data();
    return data == null ? null : AppUser.fromMap(snapshot.id, data);
  }
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
