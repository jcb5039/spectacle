// [A] 02 시작·회원가입 > 학교 선택 창 (디자인: SignUp-2-School)
import 'package:flutter/material.dart';

import '../data/signup_options.dart';
import 'list_picker_sheet.dart';

Future<String?> showSchoolPickerSheet(
  BuildContext context, {
  String? selected,
}) {
  return showListPickerSheet(
    context,
    title: '학교 선택',
    options: schoolOptions,
    selected: selected,
    searchHint: '학교명을 검색해주세요',
  );
}
