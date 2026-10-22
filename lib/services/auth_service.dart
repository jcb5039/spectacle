// [A] 기능: 회원가입·로그인·로그아웃, 회사·학교 이메일 인증 (Firebase Authentication)
import 'package:firebase_auth/firebase_auth.dart';

// 화면은 AuthService.instance만 사용한다.
// 기본값은 FakeAuthService(가짜, 테스트용)이고, 앱을 켤 때 main.dart에서 FirebaseAuthService로 바꾼다.
abstract class AuthService {
  static AuthService instance = FakeAuthService();

  String? get currentUserId;
  String? get currentEmail;
  bool get isSignedIn;

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  // 회원가입: 회사·학교 이메일과 비밀번호로 계정을 만들고 인증 링크를 보낸다
  // (Firebase는 계정이 있어야 인증 메일을 보낼 수 있다)
  Future<void> createAccountAndSendVerification({
    required String email,
    required String password,
  });

  // 인증 링크 다시 보내기
  Future<void> resendVerificationEmail();

  // 재학 증명서로 가입: 개인 이메일과 비밀번호로 계정만 만든다 (본인 확인은 관리자가 증명서로)
  Future<void> createAccount({required String email, required String password});

  // 인증 링크를 눌렀는지 확인
  Future<bool> isEmailVerified();

  // 앱을 켤 때: 폰에 로그인 기록이 있어도 서버에서 계정이 지워졌거나 정지됐으면 로그아웃하고 false
  Future<bool> checkSignedIn();
}

// 로그인·가입 실패. message는 화면에 그대로 보여줄 수 있는 문구
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

// 이미 그 이메일로 만든 계정이 있을 때. 가입을 끝내지 못한 본인 계정이면 화면에서 이어서 가입한다
class EmailInUseFailure extends AuthFailure {
  const EmailInUseFailure() : super('이미 가입된 이메일이에요.');
}

// 실제 Firebase Authentication을 쓰는 기능
class FirebaseAuthService implements AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  String? get currentEmail => _auth.currentUser?.email;

  @override
  bool get isSignedIn => _auth.currentUser != null;

  @override
  Future<void> signIn({required String email, required String password}) =>
      _run(
        () =>
            _auth.signInWithEmailAndPassword(email: email, password: password),
      );

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> createAccountAndSendVerification({
    required String email,
    required String password,
  }) => _run(() async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // 인증 메일을 한국어로 보낸다
    await _auth.setLanguageCode('ko');
    await credential.user?.sendEmailVerification();
  });

  @override
  Future<void> resendVerificationEmail() => _run(() async {
    await _auth.setLanguageCode('ko');
    await _auth.currentUser?.sendEmailVerification();
  });

  @override
  Future<void> createAccount({
    required String email,
    required String password,
  }) => _run(
    () =>
        _auth.createUserWithEmailAndPassword(email: email, password: password),
  );

  @override
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    // 메일의 링크를 누른 결과는 다시 불러와야 반영된다
    await user.reload();
    final verified = _auth.currentUser?.emailVerified ?? false;
    // 서버(Firestore)는 로그인 출입증(ID 토큰)에 적힌 인증 여부를 본다.
    // 출입증은 1시간마다 바뀌므로, 인증됐으면 바로 새로 받아야 "인증 완료"로 저장할 수 있다
    if (verified) await _auth.currentUser?.getIdToken(true);
    return verified;
  }

  @override
  Future<bool> checkSignedIn() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      await user.reload();
      return true;
    } on FirebaseAuthException catch (error) {
      const gone = {'user-not-found', 'user-disabled', 'user-token-expired'};
      if (!gone.contains(error.code)) {
        // 인터넷이 끊긴 경우 등은 계정 문제가 아니므로 로그인 상태를 유지한다
        return true;
      }
      await _auth.signOut();
      return false;
    }
  }

  // Firebase 오류를 화면에 보여줄 한국어 문구로 바꾼다
  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') throw const EmailInUseFailure();
      throw AuthFailure(switch (error.code) {
        'invalid-email' => '이메일 형식을 확인해주세요.',
        'weak-password' => '비밀번호를 더 길게 만들어주세요.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' => '이메일 또는 비밀번호를 확인해주세요.',
        'too-many-requests' => '잠시 후 다시 시도해주세요.',
        'network-request-failed' => '인터넷 연결을 확인해주세요.',
        _ => '문제가 생겼어요. 잠시 후 다시 시도해주세요.',
      });
    }
  }
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
  Future<void> createAccountAndSendVerification({
    required String email,
    required String password,
  }) async {
    _userId ??= 'local-user';
    _email = email;
  }

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    _userId ??= 'local-user';
    _email = email;
  }

  @override
  Future<bool> isEmailVerified() async => true;

  @override
  Future<bool> checkSignedIn() async => isSignedIn;
}
