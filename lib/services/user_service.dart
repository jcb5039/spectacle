// [A] 기능: 회원 정보 저장·불러오기·수정, 인증 상태 확인 (Firestore users)
import '../models/app_user.dart';

// Firebase 연결 전까지는 FakeUserService(앱이 켜져 있는 동안만 기억)가 동작한다.
// 연결할 때 Firestore users 컬렉션을 쓰는 구현을 만들어 instance만 바꾸면 된다.
abstract class UserService {
  static UserService instance = FakeUserService();

  Future<void> saveUser(AppUser user);

  Future<AppUser?> getUser(String userId);
}

class FakeUserService implements UserService {
  final Map<String, AppUser> _users = {};

  @override
  Future<void> saveUser(AppUser user) async {
    _users[user.id] = user;
  }

  @override
  Future<AppUser?> getUser(String userId) async => _users[userId];
}
