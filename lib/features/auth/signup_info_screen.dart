// [A] 02 시작·회원가입 > 회원가입 2/3 기본 정보 입력, 취업자·재학생 공용 (디자인: SignUp-2, SignUp-2-Filled, SignUp-2-Student)
import 'package:flutter/material.dart';

import 'data/signup_options.dart';
import 'signup_data.dart';
import 'signup_student_verify_screen.dart';
import 'signup_verify_screen.dart';
import 'widgets/auth_widgets.dart';
import 'widgets/department_picker_sheet.dart';
import 'widgets/list_picker_sheet.dart';
import 'widgets/school_picker_sheet.dart';
import 'widgets/year_picker_sheet.dart';

class SignUpInfoScreen extends StatefulWidget {
  const SignUpInfoScreen({super.key, required this.data});

  final SignUpData data;

  @override
  State<SignUpInfoScreen> createState() => _SignUpInfoScreenState();
}

class _SignUpInfoScreenState extends State<SignUpInfoScreen> {
  late final _companyController = TextEditingController(
    text: widget.data.company,
  );

  SignUpData get _data => widget.data;

  @override
  void dispose() {
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _pickSchool() async {
    final school = await showSchoolPickerSheet(context, selected: _data.school);
    if (school != null) setState(() => _data.school = school);
  }

  Future<void> _pickDepartment() async {
    final department = await showDepartmentPickerSheet(
      context,
      selected: _data.department,
    );
    if (department != null) setState(() => _data.department = department);
  }

  Future<void> _pickJobGroup() async {
    final jobGroup = await showListPickerSheet(
      context,
      title: '직군 선택',
      options: jobGroupOptions,
      selected: _data.jobGroup,
    );
    if (jobGroup != null) setState(() => _data.jobGroup = jobGroup);
  }

  Future<void> _pickAdmissionYear() async {
    final years = pastYearOptions();
    final year = await showYearPickerSheet(
      context,
      title: '입학년도 선택',
      years: years,
      initialYear: _data.admissionYear ?? years.last,
    );
    if (year != null) setState(() => _data.admissionYear = year);
  }

  Future<void> _pickGraduationYear() async {
    final years = _data.isEmployee
        ? pastYearOptions()
        : expectedGraduationYearOptions();
    final year = await showYearPickerSheet(
      context,
      title: _data.isEmployee ? '졸업년도 선택' : '졸업 예정년도 선택',
      years: years,
      initialYear:
          _data.graduationYear ?? (_data.isEmployee ? years.last : years.first),
    );
    if (year != null) setState(() => _data.graduationYear = year);
  }

  void _next() {
    _data.company = _companyController.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _data.isEmployee
            ? SignUpVerifyScreen(data: _data)
            : SignUpStudentVerifyScreen(data: _data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmployee = _data.isEmployee;
    return SignUpStepScaffold(
      step: 2,
      buttonLabel: '다음',
      onButtonPressed: _next,
      children: [
        SignUpStepIntro(
          kicker: 'BASIC INFORMATION',
          title: isEmployee ? '선배님의 정보를\n알려주세요.' : '학교 정보를\n알려주세요.',
          description: '같은 학교 선후배를 정확하게 연결하기 위해 필요해요.',
        ),
        const SizedBox(height: 31),
        // 안내 문구("~을 선택해주세요")는 디자인 문구 그대로
        UnderlineSelectField(
          label: isEmployee ? '출신학교' : '학교',
          hint: isEmployee ? '출신학교을 선택해주세요' : '학교을 선택해주세요',
          value: _data.school,
          onTap: _pickSchool,
        ),
        UnderlineSelectField(
          label: '학과',
          hint: '학과을 선택해주세요',
          value: _data.department,
          onTap: _pickDepartment,
        ),
        UnderlineSelectField(
          label: '입학년도',
          hint: '입학년도을 선택해주세요',
          value: _data.admissionYear?.toString(),
          onTap: _pickAdmissionYear,
        ),
        UnderlineSelectField(
          label: isEmployee ? '졸업년도' : '졸업 예정년도',
          hint: isEmployee ? '졸업년도을 선택해주세요' : '졸업 예정년도을 선택해주세요',
          value: _data.graduationYear?.toString(),
          onTap: _pickGraduationYear,
        ),
        if (isEmployee) ...[
          UnderlineSelectField(
            label: '직군',
            hint: '직군을 선택해주세요',
            value: _data.jobGroup,
            onTap: _pickJobGroup,
          ),
          UnderlineTextField(
            label: '회사명',
            hint: '현재 회사명을 입력해주세요',
            controller: _companyController,
          ),
        ],
      ],
    );
  }
}
