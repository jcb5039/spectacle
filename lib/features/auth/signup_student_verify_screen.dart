// [A] 02 시작·회원가입 > 회원가입 3/3 재학생 인증: 학교 이메일 또는 재학 증명서 (디자인: SignUp-3-Student, SignUp-3-Student-Doc)
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/photo_service.dart';
import '../../services/user_service.dart';
import 'signup_data.dart';
import 'signup_done_screen.dart';
import 'verify_wait_screen.dart';
import 'widgets/auth_widgets.dart';
import 'widgets/photo_picker_sheet.dart';
import 'widgets/verify_widgets.dart';

class SignUpStudentVerifyScreen extends StatefulWidget {
  const SignUpStudentVerifyScreen({super.key, required this.data});

  final SignUpData data;

  @override
  State<SignUpStudentVerifyScreen> createState() =>
      _SignUpStudentVerifyScreenState();
}

class _SignUpStudentVerifyScreenState extends State<SignUpStudentVerifyScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  // 재학 증명서 방식에서 로그인에 쓸 개인 이메일
  final _personalEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _useEmail = true;
  bool _emailSent = false;
  Uint8List? _certificate;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _personalEmailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // 학교 이메일은 대학 메일 주소(.ac.kr로 끝남)만 받는다
  static bool _isSchoolEmail(String email) =>
      email.trim().toLowerCase().endsWith('.ac.kr');

  static const _schoolEmailOnly = '학교 이메일(ac.kr)로만 인증할 수 있어요.';

  Future<void> _sendEmail() async {
    // 개인 메일이면 계정을 만들거나 메일을 보내지 않는다
    if (!_emailSent && !_isSchoolEmail(_emailController.text)) {
      _notice(_schoolEmailOnly);
      return;
    }
    final sent = await sendSignUpVerification(
      context,
      nickname: _nicknameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirm: _confirmController.text,
      alreadySent: _emailSent,
    );
    if (sent && mounted) setState(() => _emailSent = true);
  }

  Future<void> _pickCertificate() async {
    final source = await showPhotoPickerSheet(context);
    if (source == null) return;
    final bytes = await PhotoService.instance.pickPhoto(source);
    if (bytes != null && mounted) setState(() => _certificate = bytes);
  }

  // 학교 이메일: 인증 링크를 눌렀으면 바로 인증 완료
  // 재학 증명서: 개인 이메일로 계정을 만들고, 관리자 확인 전이라 인증 대기
  Future<void> _submit() async {
    final data = widget.data;
    final nickname = _nicknameController.text.trim();
    data.nickname = nickname;

    if (_useEmail) {
      // 인증 메일을 보낼 때 계정이 만들어지므로, 보내기 전에는 가입할 수 없다
      if (!_emailSent) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('인증 메일을 먼저 보내주세요.')));
        return;
      }
      final nicknameError = nicknameProblem(nickname);
      if (nicknameError != null) {
        _notice(nicknameError);
        return;
      }
      // 메일을 보낸 뒤 입력칸을 개인 메일로 바꾼 경우도 막는다
      if (!_isSchoolEmail(_emailController.text)) {
        _notice(_schoolEmailOnly);
        return;
      }
      data.email = _emailController.text.trim();
      final userId = AuthService.instance.currentUserId ?? 'local-user';
      final verified = await AuthService.instance.isEmailVerified();
      if (!verified) {
        if (!mounted) return;
        // 디자인에 없는 상황이라 임시로 아래쪽 안내 문구를 띄운다
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('메일의 인증 링크를 먼저 눌러주세요.')));
        return;
      }
      try {
        await UserService.instance.createUser(
          data.toAppUser(
            id: userId,
            status: VerificationStatus.verified,
            method: VerificationMethod.schoolEmail,
          ),
        );
      } on NicknameTakenException catch (error) {
        _notice(error.toString());
        return;
      } catch (_) {
        _showSaveFailed();
        return;
      }
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignUpDoneScreen()),
        (_) => false,
      );
      return;
    }

    final email = _personalEmailController.text.trim();
    final certificate = _certificate;
    // 계정을 만들기 전에 닉네임부터 확인한다 (중복이면 계정을 만들지 않는다)
    final nicknameError = await checkNickname(nickname);
    if (!mounted) return;
    // 디자인에 없는 상황이라 임시로 아래쪽 안내 문구를 띄운다
    final problem =
        nicknameError ??
        PasswordFields.validate(
          _passwordController.text,
          _confirmController.text,
        ) ??
        (email.isEmpty ? '로그인에 사용할 이메일을 입력해주세요.' : null) ??
        (certificate == null ? '재학 증명서 사진을 올려주세요.' : null);
    if (problem != null) {
      _notice(problem);
      return;
    }
    // 앞서 계정은 만들었는데 저장이 실패해 다시 누른 경우에는 계정을 또 만들지 않는다
    if (AuthService.instance.currentEmail != email) {
      try {
        await AuthService.instance.createAccount(
          email: email,
          password: _passwordController.text,
        );
      } on EmailInUseFailure catch (failure) {
        // 가입을 끝내지 못한 본인 계정이면 그 계정으로 이어서 가입한다
        final resumed = await resumeUnfinishedSignUp(
          email: email,
          password: _passwordController.text,
        );
        if (!resumed) {
          _notice(failure.message);
          return;
        }
      } on AuthFailure catch (failure) {
        _notice(failure.message);
        return;
      }
    }
    data.email = email;
    final userId = AuthService.instance.currentUserId ?? 'local-user';
    try {
      await UserService.instance.createUser(
        data.toAppUser(
          id: userId,
          status: VerificationStatus.pending,
          method: VerificationMethod.certificate,
        ),
      );
      await PhotoService.instance.uploadCertificate(
        userId: userId,
        memberType: data.memberType,
        bytes: certificate!,
      );
    } on NicknameTakenException catch (error) {
      _notice(error.toString());
      return;
    } catch (_) {
      _showSaveFailed();
      return;
    }
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const VerifyWaitScreen(afterSignUp: true),
      ),
      (_) => false,
    );
  }

  // 회원 정보·증명서 저장이 실패했을 때 (디자인에 없는 상황이라 임시로 아래쪽 안내 문구)
  void _showSaveFailed() => _notice('가입하지 못했어요. 잠시 후 다시 시도해주세요.');

  void _notice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final certificate = _certificate;
    return SignUpStepScaffold(
      step: 3,
      buttonLabel: '가입하기',
      onButtonPressed: _submit,
      children: [
        const SignUpStepIntro(
          kicker: 'VERIFICATION',
          title: '재학생 인증을\n진행해주세요.',
          description: '안전하고 신뢰할 수 있는 커뮤니티를 위한 마지막 단계예요.',
        ),
        VerifyMethodSegment(
          useEmail: _useEmail,
          onChanged: (useEmail) => setState(() => _useEmail = useEmail),
        ),
        NicknameField(controller: _nicknameController),
        // 학교 이메일·재학 증명서 두 방식 모두 비밀번호를 정한다.
        // 인증 메일을 보낼 때 계정이 만들어지므로 이메일보다 먼저 받는다
        PasswordFields(
          password: _passwordController,
          confirm: _confirmController,
        ),
        if (_useEmail)
          EmailVerifyField(
            label: '학교 이메일',
            hint: 'student@daelim.ac.kr',
            controller: _emailController,
            sent: _emailSent,
            helpText: '학교 이메일로 전송된 인증 링크를 눌러주세요.',
            sentHelpText: '학교 이메일로 전송된 인증 링크를 눌러주세요.',
            onSend: _sendEmail,
          ),
        if (!_useEmail)
          Padding(
            padding: const EdgeInsets.only(top: 29),
            child: UnderlineTextField(
              label: '이메일',
              hint: '로그인에 사용할 이메일을 입력해주세요',
              controller: _personalEmailController,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        if (!_useEmail && certificate == null)
          CertificateUploadBox(
            title: '재학 증명서 사진 업로드',
            hint: '학교명과 재학 상태가 보이도록 촬영해주세요.',
            onTap: _pickCertificate,
          ),
        if (!_useEmail && certificate != null)
          CertificateAttached(
            bytes: certificate,
            documentName: '재학 증명서',
            caption: '재학 증명서가 첨부됐어요.',
            onDelete: () => setState(() => _certificate = null),
          ),
      ],
    );
  }
}
