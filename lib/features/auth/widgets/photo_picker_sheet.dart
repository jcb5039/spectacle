// [A] 02 시작·회원가입 > 증명서 사진 선택 창 (디자인: SignUp-3-Photo)
import 'package:flutter/material.dart';

import '../../../services/photo_service.dart';
import 'auth_widgets.dart';

// 사진 촬영 / 앨범에서 선택 중 고른 것을 돌려준다. 취소하면 null
Future<PhotoSource?> showPhotoPickerSheet(BuildContext context) {
  return showAuthBottomSheet<PhotoSource>(
    context,
    (context) => SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(9, 0, 9, 9),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        decoration: BoxDecoration(
          color: AuthColors.fillF7,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(),
            _option(context, '사진 촬영', PhotoSource.camera),
            _option(context, '앨범에서 선택', PhotoSource.gallery),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Material(
                color: AuthColors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Center(
                      child: Text(
                        '취소',
                        style: TextStyle(
                          color: AuthColors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _option(BuildContext context, String label, PhotoSource source) {
  return InkWell(
    onTap: () => Navigator.pop(context, source),
    child: Container(
      width: double.infinity,
      height: 55,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AuthColors.lineE5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AuthColors.black,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
