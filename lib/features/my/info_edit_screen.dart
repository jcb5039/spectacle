// [A] 06 랭킹·MY > 개인정보 수정 화면 (디자인: InfoEdit)
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/photo_service.dart';
import '../../services/user_service.dart';
import '../auth/widgets/auth_widgets.dart';
import 'widgets/my_widgets.dart';
import 'widgets/profile_photo_sheet.dart';

class InfoEditScreen extends StatefulWidget {
  const InfoEditScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<InfoEditScreen> createState() => _InfoEditScreenState();
}

class _InfoEditScreenState extends State<InfoEditScreen> {
  late final AppUser _user = widget.user;
  late final _nickname = TextEditingController(text: _user.nickname);
  late final _email = TextEditingController(text: _user.email);
  late final _phone = TextEditingController(text: _user.phone);
  late final _school = TextEditingController(text: _user.school);
  late final _department = TextEditingController(text: _user.department);
  late final _admissionYear = TextEditingController(
    text: _user.admissionYear?.toString(),
  );
  late final _graduationYear = TextEditingController(
    text: _user.graduationYear?.toString(),
  );
  late final _company = TextEditingController(text: _user.company);
  late final _jobTitle = TextEditingController(text: _user.jobTitle);
  late bool _showCompany = _user.showCompany;
  late bool _allowQuestions = _user.allowQuestions;
  Uint8List? _photo;
  Uint8List? _newPhoto;

  List<TextEditingController> get _controllers => [
    _nickname,
    _email,
    _phone,
    _school,
    _department,
    _admissionYear,
    _graduationYear,
    _company,
    _jobTitle,
  ];

  @override
  void initState() {
    super.initState();
    PhotoService.instance.getProfilePhoto(_user.id).then((photo) {
      if (mounted) setState(() => _photo = photo);
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _changePhoto() async {
    final source = await showProfilePhotoSheet(context);
    if (source == null) return;
    final bytes = await PhotoService.instance.pickPhoto(source);
    if (bytes != null && mounted) setState(() => _newPhoto = bytes);
  }

  Future<void> _save() async {
    // 닉네임이 바뀌었으면 글자 규칙과 중복을 확인한다 (디자인에 없는 상황이라 임시로 아래쪽 안내 문구)
    final nickname = _nickname.text.trim();
    final changed = nickname != (_user.nickname ?? '');
    final problem = changed ? nicknameProblem(nickname) : null;
    if (problem != null) {
      _notice(problem);
      return;
    }
    // 이메일은 로그인 계정이라 여기서 바꾸지 않는다
    final updated = _user.copyWith(
      nickname: nickname,
      phone: _phone.text.trim(),
      school: _school.text.trim(),
      department: _department.text.trim(),
      admissionYear: int.tryParse(_admissionYear.text.trim()),
      graduationYear: int.tryParse(_graduationYear.text.trim()),
      company: _company.text.trim(),
      jobTitle: _jobTitle.text.trim(),
      showCompany: _showCompany,
      allowQuestions: _allowQuestions,
    );
    try {
      await UserService.instance.updateUser(
        updated,
        oldNickname: _user.nickname,
      );
      final newPhoto = _newPhoto;
      if (newPhoto != null) {
        await PhotoService.instance.uploadProfilePhoto(
          userId: _user.id,
          bytes: newPhoto,
        );
      }
    } on NicknameTakenException catch (error) {
      _notice(error.toString());
      return;
    } catch (_) {
      _notice('저장하지 못했어요. 잠시 후 다시 시도해주세요.');
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  void _notice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isEmployee = _user.isEmployee;
    return Scaffold(
      backgroundColor: AuthColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ModalHeader(title: '개인정보 수정'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildAvatar(),
                  SettingsSection(
                    title: '기본 정보',
                    children: [
                      _field('닉네임', _nickname),
                      _fieldWith('이메일', _email, readOnly: true),
                      _field('휴대폰 번호', _phone, TextInputType.phone),
                    ],
                  ),
                  SettingsSection(
                    title: '학교 정보',
                    children: [
                      _field('학교', _school),
                      _field('학과', _department),
                      Row(
                        children: [
                          Expanded(
                            child: SmallUnderlineField(
                              label: '입학년도',
                              controller: _admissionYear,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SmallUnderlineField(
                              label: isEmployee ? '졸업년도' : '졸업 예정년도',
                              controller: _graduationYear,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // 취업 정보와 공개 설정은 취업자만
                  if (isEmployee) ...[
                    SettingsSection(
                      title: '취업 정보',
                      children: [
                        _field('회사명', _company),
                        _field('직무', _jobTitle),
                      ],
                    ),
                    SettingsSection(
                      title: '공개 및 알림',
                      children: [
                        SettingToggleRow(
                          title: '회사·직무 공개',
                          description: '선배 프로필에 취업 정보를 표시해요.',
                          value: _showCompany,
                          onChanged: (value) =>
                              setState(() => _showCompany = value),
                        ),
                        SettingToggleRow(
                          title: '후배 질문 받기',
                          description: '같은 학교 후배가 질문을 보낼 수 있어요.',
                          value: _allowQuestions,
                          onChanged: (value) =>
                              setState(() => _allowQuestions = value),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            AuthBottomAction(
              topPadding: 10,
              child: AuthPrimaryButton(label: '변경사항 저장', onPressed: _save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
      child: Column(
        children: [
          ProfileAvatar(
            name: _nickname.text.isEmpty ? '회원' : _nickname.text,
            size: 82,
            fontSize: 22,
            photo: _newPhoto ?? _photo,
          ),
          const SizedBox(height: 11),
          GestureDetector(
            onTap: _changePhoto,
            child: const Text(
              '프로필 사진 변경',
              style: TextStyle(
                color: Color(0xFF555555),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, [
    TextInputType? keyboardType,
  ]) => _fieldWith(label, controller, keyboardType: keyboardType);

  Widget _fieldWith(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return UnderlineTextField(
      label: label,
      hint: '',
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 13),
    );
  }
}
