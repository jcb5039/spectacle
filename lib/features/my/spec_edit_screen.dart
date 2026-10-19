// [A] 06 랭킹·MY > 스펙 수정 화면 (디자인: SpecEdit)
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/user_spec.dart';
import '../../services/user_service.dart';
import '../auth/widgets/auth_widgets.dart';
import 'widgets/my_widgets.dart';

class SpecEditScreen extends StatefulWidget {
  const SpecEditScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<SpecEditScreen> createState() => _SpecEditScreenState();
}

// 입력칸 두 개짜리 한 줄 (어학: 시험명·점수, 자격증: 자격증명·취득일, 활동: 활동명·내용)
class _PairRow {
  _PairRow(String first, String second)
    : first = TextEditingController(text: first),
      second = TextEditingController(text: second);

  final TextEditingController first;
  final TextEditingController second;

  bool get isEmpty => first.text.trim().isEmpty && second.text.trim().isEmpty;

  void dispose() {
    first.dispose();
    second.dispose();
  }
}

class _SpecEditScreenState extends State<SpecEditScreen> {
  late final UserSpec _spec = widget.user.spec;
  late bool _isPublic = _spec.isPublic;
  late final _gpa = TextEditingController(text: _spec.gpa);
  late final _gpaScale = TextEditingController(text: _spec.gpaScale);
  late final List<_PairRow> _languages = [
    for (final score in _spec.languageScores)
      _PairRow(score.testName, score.score),
  ];
  late final List<_PairRow> _certificates = [
    for (final certificate in _spec.certificates)
      _PairRow(certificate.name, certificate.acquiredDate),
  ];
  late final List<_PairRow> _activities = [
    for (final activity in _spec.activities)
      _PairRow(activity.name, activity.description),
  ];

  @override
  void dispose() {
    _gpa.dispose();
    _gpaScale.dispose();
    for (final row in [..._languages, ..._certificates, ..._activities]) {
      row.dispose();
    }
    super.dispose();
  }

  void _remove(List<_PairRow> rows, _PairRow row) {
    setState(() => rows.remove(row));
    row.dispose();
  }

  Future<void> _save() async {
    // 아무것도 안 쓴 줄은 저장하지 않는다
    List<_PairRow> filled(List<_PairRow> rows) =>
        rows.where((row) => !row.isEmpty).toList();
    final spec = UserSpec(
      isPublic: _isPublic,
      gpa: _gpa.text.trim(),
      gpaScale: _gpaScale.text.trim(),
      languageScores: [
        for (final row in filled(_languages))
          LanguageScore(
            testName: row.first.text.trim(),
            score: row.second.text.trim(),
          ),
      ],
      certificates: [
        for (final row in filled(_certificates))
          Certificate(
            name: row.first.text.trim(),
            acquiredDate: row.second.text.trim(),
          ),
      ],
      activities: [
        for (final row in filled(_activities))
          Activity(
            name: row.first.text.trim(),
            description: row.second.text.trim(),
          ),
      ],
    );
    await UserService.instance.saveUser(widget.user.copyWith(spec: spec));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ModalHeader(title: '내 스펙 수정'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildIntro(),
                  SettingsSection(
                    title: '공개 설정',
                    children: [
                      SettingToggleRow(
                        title: '내 스펙 공개',
                        description: '선배 프로필에서 스펙을 보여줘요.',
                        value: _isPublic,
                        onChanged: (value) => setState(() => _isPublic = value),
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: '학점',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SmallUnderlineField(
                              label: '평점',
                              controller: _gpa,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SmallUnderlineField(
                              label: '기준',
                              controller: _gpaScale,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: '어학 성적',
                    onAdd: () =>
                        setState(() => _languages.add(_PairRow('', ''))),
                    children: [
                      for (final row in _languages) _buildLanguageRow(row),
                    ],
                  ),
                  SettingsSection(
                    title: '자격증',
                    onAdd: () =>
                        setState(() => _certificates.add(_PairRow('', ''))),
                    children: [
                      for (final row in _certificates)
                        _buildCertificateRow(row),
                    ],
                  ),
                  SettingsSection(
                    title: '경험·활동',
                    onAdd: () =>
                        setState(() => _activities.add(_PairRow('', ''))),
                    children: [
                      for (var i = 0; i < _activities.length; i++)
                        _buildActivityRow(_activities[i], isFirst: i == 0),
                    ],
                  ),
                ],
              ),
            ),
            AuthBottomAction(
              topPadding: 10,
              child: AuthPrimaryButton(label: '저장', onPressed: _save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 30, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepKicker('SHARE YOUR EXPERIENCE'),
          SizedBox(height: 13),
          Text(
            '후배에게 도움이 될\n나의 스펙을 정리해요.',
            style: TextStyle(
              color: AuthColors.black,
              fontSize: 25,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.375,
              height: 1.35,
            ),
          ),
          SizedBox(height: 11),
          Text(
            '공개한 정보는 같은 학교 회원에게만 보여요.',
            style: TextStyle(color: AuthColors.gray8E, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _rowFrame(List<Widget> children) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AuthColors.lineEE)),
      ),
      child: Row(children: children),
    );
  }

  Widget _buildLanguageRow(_PairRow row) {
    return _rowFrame([
      SizedBox(
        width: 80,
        child: PlainTextField(controller: row.first, hint: '시험명', fontSize: 13),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: PlainTextField(
          controller: row.second,
          hint: '점수·등급',
          fontSize: 13,
        ),
      ),
      const SizedBox(width: 8),
      RemoveButton(onTap: () => _remove(_languages, row)),
    ]);
  }

  Widget _buildCertificateRow(_PairRow row) {
    return _rowFrame([
      Expanded(
        child: PlainTextField(
          controller: row.first,
          hint: '자격증명',
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(width: 9),
      SizedBox(
        width: 105,
        child: PlainTextField(
          controller: row.second,
          hint: '취득일',
          fontSize: 11,
        ),
      ),
      const SizedBox(width: 8),
      RemoveButton(onTap: () => _remove(_certificates, row)),
    ]);
  }

  Widget _buildActivityRow(_PairRow row, {required bool isFirst}) {
    return Container(
      margin: EdgeInsets.only(top: isFirst ? 0 : 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AuthColors.lineEE)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '활동명',
                  style: TextStyle(color: AuthColors.gray8E, fontSize: 10),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFCCCCCC)),
                    ),
                  ),
                  child: PlainTextField(
                    controller: row.first,
                    hint: '활동명',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 11),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 74),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AuthColors.fillF7,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: row.second,
                    maxLines: null,
                    style: const TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 11,
                      height: 1.6,
                    ),
                    decoration: const InputDecoration.collapsed(
                      hintText: '활동 내용을 입력해주세요',
                      hintStyle: TextStyle(
                        color: AuthColors.grayAA,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 3,
            child: GestureDetector(
              onTap: () => _remove(_activities, row),
              child: const Text(
                '삭제',
                style: TextStyle(color: Color(0xFF999999), fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
