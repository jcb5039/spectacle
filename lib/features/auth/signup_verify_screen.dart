// [A] 02 시작·회원가입 > 회원가입 3/3 취업자 인증: 졸업 증명서 사진 + 회사 이메일 (디자인: SignUp-3, SignUp-3-Done)
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/photo_service.dart';
import '../../services/user_service.dart';
import 'signup_data.dart';
import 'verify_wait_screen.dart';
import 'widgets/auth_widgets.dart';
import 'widgets/photo_picker_sheet.dart';
import 'widgets/verify_widgets.dart';

class SignUpVerifyScreen extends StatefulWidget {
  const SignUpVerifyScreen({super.key, required this.data});

  final SignUpData data;

  @override
  State<SignUpVerifyScreen> createState() => _SignUpVerifyScreenState();
}

class _SignUpVerifyScreenState extends State<SignUpVerifyScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _emailSent = false;
  Uint8List? _certificate;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
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

  // 회원 정보 저장 + 증명서 올리기 → 관리자 확인 전이라 인증 대기
  Future<void> _submit() async {
    // 인증 메일을 보낼 때 계정이 만들어지므로, 보내기 전에는 가입할 수 없다
    if (!_emailSent) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('인증 메일을 먼저 보내주세요.')));
      return;
    }
    final nickname = _nicknameController.text.trim();
    final nicknameError = nicknameProblem(nickname);
    if (nicknameError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(nicknameError)));
      return;
    }
    final data = widget.data
      ..email = _emailController.text.trim()
      ..nickname = nickname;
    final userId = AuthService.instance.currentUserId ?? 'local-user';
    final certificate = _certificate;
    try {
      await UserService.instance.createUser(
        data.toAppUser(
          id: userId,
          status: VerificationStatus.pending,
          method: VerificationMethod.certificate,
        ),
      );
      if (certificate != null) {
        await PhotoService.instance.uploadCertificate(
          userId: userId,
          memberType: data.memberType,
          bytes: certificate,
        );
      }
    } on NicknameTakenException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    } catch (_) {
      // 디자인에 없는 상황이라 임시로 아래쪽 안내 문구를 띄운다
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가입하지 못했어요. 잠시 후 다시 시도해주세요.')),
      );
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
          title: '취업 정보를\n인증해주세요.',
          description: '안전하고 신뢰할 수 있는 커뮤니티를 위한 마지막 단계예요.',
        ),
        NicknameField(controller: _nicknameController),
        // 인증 메일을 보낼 때 계정이 만들어지므로 비밀번호를 먼저 받는다
        PasswordFields(
          password: _passwordController,
          confirm: _confirmController,
        ),
        EmailVerifyField(
          label: '회사 이메일',
          hint: 'name@company.com',
          controller: _emailController,
          sent: _emailSent,
          helpText: '메일의 인증 링크를 누르면 완료돼요.',
          sentHelpText: '메일의 링크를 눌러 인증을 완료해 주세요.',
          onSend: _sendEmail,
        ),
        if (certificate == null)
          CertificateUploadBox(
            title: '졸업 증명서 사진 업로드',
            hint: '학교명과 졸업 여부가 보이도록 촬영해주세요.',
            onTap: _pickCertificate,
          )
        else
          CertificateAttached(
            bytes: certificate,
            documentName: '졸업 증명서',
            caption: '졸업 증명서가 첨부됐어요.',
            onDelete: () => setState(() => _certificate = null),
          ),
      ],
    );
  }
}
