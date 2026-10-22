// [A] 02 시작·회원가입 > 회원가입 3/3 인증 화면 부품: 이메일 인증칸, 증명서 사진 올리기 상자, 첨부된 증명서, 학교 이메일·재학 증명서 선택 버튼 (디자인: SignUp-3, SignUp-3-Done, SignUp-3-Student, SignUp-3-Student-Doc)
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import 'auth_widgets.dart';

// 이메일 입력칸 + 오른쪽 "인증 메일 보내기 / 재전송" 버튼
// 메일을 보낸 뒤 앱으로 돌아오면(링크를 누르고 온 경우) 인증 여부를 저절로 확인한다
class EmailVerifyField extends StatefulWidget {
  const EmailVerifyField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.sent,
    required this.helpText,
    required this.sentHelpText,
    required this.onSend,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool sent;
  final String helpText;
  final String sentHelpText;
  final VoidCallback onSend;

  @override
  State<EmailVerifyField> createState() => _EmailVerifyFieldState();
}

class _EmailVerifyFieldState extends State<EmailVerifyField> {
  late final AppLifecycleListener _lifecycle;
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _checkVerified);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _checkVerified() async {
    if (!widget.sent || _verified) return;
    bool verified;
    try {
      verified = await AuthService.instance.isEmailVerified();
    } catch (_) {
      // 인터넷이 끊긴 경우 등은 조용히 넘어가고, "가입하기"를 누를 때 다시 확인한다
      return;
    }
    if (!verified || !mounted) return;
    setState(() => _verified = true);
    // 디자인에 없는 상황이라 다른 안내와 같은 아래쪽 안내 문구를 띄운다
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('이메일 인증이 완료됐어요.')));
  }

  @override
  Widget build(BuildContext context) {
    final sent = widget.sent;
    return Padding(
      padding: const EdgeInsets.only(top: 29),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              UnderlineTextField(
                label: widget.label,
                hint: widget.hint,
                controller: widget.controller,
                keyboardType: TextInputType.emailAddress,
                padding: const EdgeInsets.fromLTRB(0, 17, 118, 13),
              ),
              Positioned(
                top: 28,
                right: 0,
                child: _SendButton(sent: sent, onPressed: widget.onSend),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _verified
                ? '이메일 인증이 완료됐어요.'
                : sent
                ? widget.sentHelpText
                : widget.helpText,
            style: const TextStyle(color: AuthColors.gray8E, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// "인증 메일 보내기 / 재전송"을 눌렀을 때: 처음이면 계정을 만들고 메일을 보내고, 이미 보냈으면 다시 보낸다.
// 보냈으면 true. 닉네임·비밀번호·이메일이 비었거나 맞지 않으면 아래쪽 안내 문구를 띄우고 false
// (닉네임 중복은 여기서 미리 알려주고, 실제 등록은 "가입하기"를 누를 때 한다)
Future<bool> sendSignUpVerification(
  BuildContext context, {
  required String nickname,
  required String email,
  required String password,
  required String confirm,
  required bool alreadySent,
}) async {
  void notice(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  try {
    if (alreadySent) {
      await AuthService.instance.resendVerificationEmail();
      notice('인증 메일을 다시 보냈어요. 메일함을 확인해주세요.');
      return true;
    }
    final nicknameError = await checkNickname(nickname);
    if (nicknameError != null) {
      notice(nicknameError);
      return false;
    }
    if (password.isEmpty) {
      notice('비밀번호를 먼저 설정해주세요.');
      return false;
    }
    final passwordError = PasswordFields.validate(password, confirm);
    if (passwordError != null) {
      notice(passwordError);
      return false;
    }
    if (email.isEmpty) {
      notice('이메일을 입력해주세요.');
      return false;
    }
    try {
      await AuthService.instance.createAccountAndSendVerification(
        email: email,
        password: password,
      );
    } on EmailInUseFailure {
      if (!await resumeUnfinishedSignUp(email: email, password: password)) {
        rethrow;
      }
      // 이미 링크를 눌렀으면 메일을 다시 보내지 않는다
      var verified = false;
      try {
        verified = await AuthService.instance.isEmailVerified();
      } catch (_) {}
      if (verified) {
        notice('이미 인증된 이메일이에요. 가입을 이어서 진행해주세요.');
        return true;
      }
      await AuthService.instance.resendVerificationEmail();
    }
    notice('인증 메일을 보냈어요. 메일함을 확인해주세요.');
    return true;
  } on AuthFailure catch (failure) {
    notice(failure.message);
    return false;
  }
}

// 이미 가입된 이메일일 때: 같은 비밀번호로 로그인해 보고, 회원 정보가 없으면
// 인증 메일만 보내고 가입을 끝내지 못한 본인 계정이라 그 계정으로 이어서 가입한다.
// 이어서 가입할 수 있으면 true. 정상 회원 계정이거나 비밀번호가 다르면 false
Future<bool> resumeUnfinishedSignUp({
  required String email,
  required String password,
}) async {
  try {
    await AuthService.instance.signIn(email: email, password: password);
  } on AuthFailure {
    return false;
  }
  final userId = AuthService.instance.currentUserId;
  try {
    if (userId != null && await UserService.instance.getUser(userId) == null) {
      return true;
    }
  } catch (_) {
    // 회원 정보를 확인하지 못하면 이어서 가입하지 않는다
  }
  await AuthService.instance.signOut();
  return false;
}

// 닉네임 글자 규칙과 중복을 확인한다. 문제가 있으면 안내 문구, 괜찮으면 null
Future<String?> checkNickname(String nickname) async {
  final problem = nicknameProblem(nickname);
  if (problem != null) return problem;
  try {
    if (await UserService.instance.isNicknameTaken(nickname)) {
      return const NicknameTakenException().toString();
    }
  } catch (_) {
    return '닉네임을 확인하지 못했어요. 잠시 후 다시 시도해주세요.';
  }
  return null;
}

// 닉네임 입력칸 (디자인에 없어서 다른 입력칸과 같은 모양으로 추가, 비밀번호 칸 위)
class NicknameField extends StatelessWidget {
  const NicknameField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: UnderlineTextField(
        label: '닉네임',
        hint: '2~10자로 입력해주세요',
        controller: controller,
      ),
    );
  }
}

// 비밀번호 + 비밀번호 확인 입력칸 (디자인에 없어서 다른 입력칸과 같은 모양으로 추가)
class PasswordFields extends StatefulWidget {
  const PasswordFields({
    super.key,
    required this.password,
    required this.confirm,
  });

  final TextEditingController password;
  final TextEditingController confirm;

  // 문제가 있으면 안내 문구, 괜찮으면 null
  static String? validate(String password, String confirm) {
    if (password.length < 8) return '비밀번호는 8자 이상이어야 해요.';
    if (password != confirm) return '비밀번호가 일치하지 않아요.';
    return null;
  }

  @override
  State<PasswordFields> createState() => _PasswordFieldsState();
}

class _PasswordFieldsState extends State<PasswordFields> {
  @override
  void initState() {
    super.initState();
    widget.password.addListener(_refresh);
    widget.confirm.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.password.removeListener(_refresh);
    widget.confirm.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  // 입력하는 동안에는 쓴 칸에 대해서만 알려준다
  String? get _message {
    final password = widget.password.text;
    final confirm = widget.confirm.text;
    if (password.isNotEmpty && password.length < 8) {
      return '비밀번호는 8자 이상이어야 해요.';
    }
    if (confirm.isNotEmpty && password != confirm) {
      return '비밀번호가 일치하지 않아요.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final message = _message;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UnderlineTextField(
            label: '비밀번호',
            hint: '8자 이상 입력해주세요',
            controller: widget.password,
            obscureText: true,
          ),
          UnderlineTextField(
            label: '비밀번호 확인',
            hint: '비밀번호를 한 번 더 입력해주세요',
            controller: widget.confirm,
            obscureText: true,
          ),
          if (message != null) ...[
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                color: AuthColors.black,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.sent, required this.onPressed});

  final bool sent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sent ? AuthColors.fillF2 : Colors.transparent,
          border: Border.all(
            color: sent ? AuthColors.lineDD : AuthColors.black,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          sent ? '재전송' : '인증 메일 보내기',
          style: TextStyle(
            color: sent ? AuthColors.gray77 : AuthColors.black,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// 점선 상자: "증명서 사진 업로드"
class CertificateUploadBox extends StatelessWidget {
  const CertificateUploadBox({
    super.key,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 174),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 47,
                  height: 47,
                  margin: const EdgeInsets.only(bottom: 13),
                  decoration: const BoxDecoration(
                    color: AuthColors.fillF1,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    size: 25,
                    color: AuthColors.black,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: AuthColors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AuthColors.gray8E,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AuthColors.grayAA
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
          const Radius.circular(11),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 4), paint);
        distance += 7;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 첨부된 증명서 미리보기 + 삭제(×) 버튼
class CertificateAttached extends StatelessWidget {
  const CertificateAttached({
    super.key,
    required this.bytes,
    required this.documentName,
    required this.caption,
    required this.onDelete,
  });

  final Uint8List bytes;
  final String documentName;
  final String caption;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 174,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF6F6F6), Color(0xFFE9E9E9)],
                  ),
                  border: Border.all(color: AuthColors.lineDD),
                  borderRadius: BorderRadius.circular(11),
                ),
                // 실제 사진이 있으면 사진, 없으면(가짜 서비스) 디자인의 예시 모양
                child: bytes.isNotEmpty
                    ? Image.memory(bytes, fit: BoxFit.cover)
                    : _SampleDocument(documentName: documentName),
              ),
              Positioned(
                top: 9,
                right: 9,
                child: Semantics(
                  button: true,
                  label: '삭제',
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xB8000000),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '×',
                        style: TextStyle(
                          color: AuthColors.white,
                          fontSize: 19,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: const TextStyle(color: AuthColors.gray77, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _SampleDocument extends StatelessWidget {
  const _SampleDocument({required this.documentName});

  final String documentName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DAELIM UNIVERSITY',
            style: TextStyle(
              color: Color(0xFF999999),
              fontFamily: 'Georgia',
              fontSize: 8,
              letterSpacing: 0.96,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            documentName,
            style: const TextStyle(
              color: AuthColors.black,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 13),
          for (var i = 0; i < 3; i++)
            FractionallySizedBox(
              widthFactor: 0.75,
              child: Container(
                height: 5,
                margin: const EdgeInsets.only(top: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFD3D3D3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 재학생 인증 방법 선택: 학교 이메일 / 재학 증명서
class VerifyMethodSegment extends StatelessWidget {
  const VerifyMethodSegment({
    super.key,
    required this.useEmail,
    required this.onChanged,
  });

  final bool useEmail;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43,
      margin: const EdgeInsets.only(top: 29),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AuthColors.fillF1,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          _segment('학교 이메일', selected: useEmail, onTap: () => onChanged(true)),
          _segment(
            '재학 증명서',
            selected: !useEmail,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _segment(
    String label, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: selected
              ? BoxDecoration(
                  color: AuthColors.white,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x17000000),
                      offset: Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                )
              : null,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AuthColors.black : AuthColors.gray88,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
