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
  final _emailController = TextEditingController();
  bool _useEmail = true;
  bool _emailSent = false;
  Uint8List? _certificate;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    await AuthService.instance.sendVerificationEmail(
      _emailController.text.trim(),
    );
    if (mounted) setState(() => _emailSent = true);
  }

  Future<void> _pickCertificate() async {
    final source = await showPhotoPickerSheet(context);
    if (source == null) return;
    final bytes = await PhotoService.instance.pickPhoto(source);
    if (bytes != null && mounted) setState(() => _certificate = bytes);
  }

  // 학교 이메일: 인증 링크를 눌렀으면 바로 인증 완료
  // 재학 증명서: 관리자 확인 전이라 인증 대기
  Future<void> _submit() async {
    final data = widget.data;
    final userId = AuthService.instance.currentUserId ?? 'local-user';

    if (_useEmail) {
      data.email = _emailController.text.trim();
      final verified = await AuthService.instance.isEmailVerified();
      if (!verified) {
        if (!mounted) return;
        // 디자인에 없는 상황이라 임시로 아래쪽 안내 문구를 띄운다
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('메일의 인증 링크를 먼저 눌러주세요.')));
        return;
      }
      await UserService.instance.saveUser(
        data.toAppUser(
          id: userId,
          status: VerificationStatus.verified,
          method: VerificationMethod.schoolEmail,
        ),
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignUpDoneScreen()),
        (_) => false,
      );
      return;
    }

    await UserService.instance.saveUser(
      data.toAppUser(
        id: userId,
        status: VerificationStatus.pending,
        method: VerificationMethod.certificate,
      ),
    );
    final certificate = _certificate;
    if (certificate != null) {
      await PhotoService.instance.uploadCertificate(
        userId: userId,
        memberType: data.memberType,
        bytes: certificate,
      );
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
          title: '재학생 인증을\n진행해주세요.',
          description: '안전하고 신뢰할 수 있는 커뮤니티를 위한 마지막 단계예요.',
        ),
        VerifyMethodSegment(
          useEmail: _useEmail,
          onChanged: (useEmail) => setState(() => _useEmail = useEmail),
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
          )
        else if (certificate == null)
          CertificateUploadBox(
            title: '재학 증명서 사진 업로드',
            hint: '학교명과 재학 상태가 보이도록 촬영해주세요.',
            onTap: _pickCertificate,
          )
        else
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
