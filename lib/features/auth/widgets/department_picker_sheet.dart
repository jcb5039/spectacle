// [A] 02 시작·회원가입 > 학과 선택 창 (디자인: SignUp-2-Department)
import 'package:flutter/material.dart';

import '../data/signup_options.dart';
import 'list_picker_sheet.dart';

Future<String?> showDepartmentPickerSheet(
  BuildContext context, {
  String? selected,
}) {
  return showListPickerSheet(
    context,
    title: '학과 선택',
    options: departmentOptions,
    selected: selected,
    searchHint: '학과명을 검색해주세요',
  );
}
