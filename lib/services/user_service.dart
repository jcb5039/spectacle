// [A] 기능: 회원 정보 저장·불러오기·수정, 인증 상태 확인 (Firestore users)
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/user_spec.dart';

// 기본값은 FakeUserService(가짜, 테스트용)이고, 앱을 켤 때 main.dart에서 FirestoreUserService로 바꾼다.
abstract class UserService {
  static UserService instance = FakeUserService();

  // 새로 저장하거나, 같은 id가 있으면 덮어쓴다 (닉네임을 바꾸지 않는 스펙 수정 등에서 사용)
  Future<void> saveUser(AppUser user);

  Future<AppUser?> getUser(String userId);

  // 다른 회원이 이미 쓰는 닉네임이면 true (가입 중 로그인 전에도 확인할 수 있다)
  Future<bool> isNicknameTaken(String nickname);

  // 가입: 닉네임 명단 등록과 회원 정보 저장을 한 번에 한다.
  // 그 사이 다른 사람이 같은 닉네임을 가져갔으면 NicknameTakenException
  Future<void> createUser(AppUser user);

  // 개인정보 수정: 닉네임이 바뀌었으면 옛 닉네임을 명단에서 지우고 새 닉네임을 등록하며 저장한다.
  // 새 닉네임을 다른 사람이 쓰고 있으면 NicknameTakenException
  Future<void> updateUser(AppUser user, {required String? oldNickname});
}

// 이미 다른 회원이 쓰는 닉네임
class NicknameTakenException implements Exception {
  const NicknameTakenException();

  @override
  String toString() => '이미 사용 중인 닉네임이에요.';
}

// 닉네임 글자 규칙: 앞뒤 공백을 뺀 2~10자, 명단 문서 이름으로 쓸 수 없는 "/"는 빼기.
// 문제가 있으면 안내 문구, 괜찮으면 null
String? nicknameProblem(String nickname) {
  if (nickname.isEmpty) return '닉네임을 입력해주세요.';
  if (nickname.length < 2 || nickname.length > 10) {
    return '닉네임은 2~10자로 입력해주세요.';
  }
  if (nickname.contains('/')) return '닉네임에 "/"는 쓸 수 없어요.';
  return null;
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

  // 닉네임 명단: 문서 이름 = 닉네임, 안에는 주인 계정 id(uid)만
  CollectionReference<Map<String, dynamic>> get _nicknames =>
      FirebaseFirestore.instance.collection('nicknames');

  @override
  Future<bool> isNicknameTaken(String nickname) async {
    final snapshot = await _nicknames.doc(nickname).get();
    return snapshot.exists;
  }

  @override
  Future<void> createUser(AppUser user) => _saveWithNickname(user, null);

  @override
  Future<void> updateUser(AppUser user, {required String? oldNickname}) =>
      _saveWithNickname(user, oldNickname);

  // 한 번에 처리(트랜잭션)해서, 두 사람이 동시에 같은 닉네임을 골라도 한 명만 성공한다
  Future<void> _saveWithNickname(AppUser user, String? oldNickname) {
    final nickname = user.nickname;
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      if (nickname != null && nickname != oldNickname) {
        final reserved = await transaction.get(_nicknames.doc(nickname));
        final owner = reserved.data()?['uid'];
        if (reserved.exists && owner != user.id) {
          throw const NicknameTakenException();
        }
        if (!reserved.exists) {
          transaction.set(_nicknames.doc(nickname), {'uid': user.id});
        }
        if (oldNickname != null && oldNickname.isNotEmpty) {
          transaction.delete(_nicknames.doc(oldNickname));
        }
      }
      transaction.set(_users.doc(user.id), user.toMap());
    });
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
      nickname: '김민지',
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

  @override
  Future<bool> isNicknameTaken(String nickname) async =>
      _users.values.any((user) => user.nickname == nickname);

  @override
  Future<void> createUser(AppUser user) => updateUser(user, oldNickname: null);

  @override
  Future<void> updateUser(AppUser user, {required String? oldNickname}) async {
    final taken = _users.values.any(
      (other) => other.id != user.id && other.nickname == user.nickname,
    );
    if (taken) throw const NicknameTakenException();
    _users[user.id] = user;
  }
}
