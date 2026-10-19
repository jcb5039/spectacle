// [A] 06 랭킹·MY > 프로필 사진 변경 창 (디자인: InfoEdit-Photo)
import 'package:flutter/material.dart';

import '../../../services/photo_service.dart';
import '../../auth/widgets/photo_picker_sheet.dart';

// 디자인이 회원가입의 증명서 사진 선택 창과 같아서 그 창을 그대로 쓴다.
Future<PhotoSource?> showProfilePhotoSheet(BuildContext context) {
  return showPhotoPickerSheet(context);
}
