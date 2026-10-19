// [A] 기능: 회원가입·로그인·로그아웃, 회사·학교 이메일 인증 (Firebase Authentication)

// 화면은 AuthService.instance만 사용한다.
// Firebase 연결 전까지는 FakeAuthService(가짜)가 동작하고,
// 연결할 때 AuthService를 구현한 FirebaseAuthService를 만들어 instance만 바꾸면 된다.
abstract class AuthService {
  static AuthService instance = FakeAuthService();

  String? get currentUserId;
  String? get currentEmail;
  bool get isSignedIn;

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  // 회사·학교 이메일로 인증 링크 보내기
  Future<void> sendVerificationEmail(String email);

  // 인증 링크를 눌렀는지 확인
  Future<bool> isEmailVerified();
}

// Firebase 연결 전 화면 확인용. 어떤 값을 넣어도 성공한다.
class FakeAuthService implements AuthService {
  String? _userId;
  String? _email;

  @override
  String? get currentUserId => _userId;

  @override
  String? get currentEmail => _email;

  @override
  bool get isSignedIn => _userId != null;

  @override
  Future<void> signIn({required String email, required String password}) async {
    _userId = 'local-user';
    _email = email;
  }

  @override
  Future<void> signOut() async {
    _userId = null;
    _email = null;
  }

  @override
  Future<void> sendVerificationEmail(String email) async {
    _userId ??= 'local-user';
    _email = email;
  }

  @override
  Future<bool> isEmailVerified() async => true;
}
