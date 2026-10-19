// [A] 02 시작·회원가입 > 회원가입 3/3 인증 화면 부품: 이메일 인증칸, 증명서 사진 올리기 상자, 첨부된 증명서, 학교 이메일·재학 증명서 선택 버튼 (디자인: SignUp-3, SignUp-3-Done, SignUp-3-Student, SignUp-3-Student-Doc)
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'auth_widgets.dart';

// 이메일 입력칸 + 오른쪽 "인증 메일 보내기 / 재전송" 버튼
class EmailVerifyField extends StatelessWidget {
  const EmailVerifyField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.sent,
    required this.helpText,
    required this.sentHelpText,
    required this.onSend,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool sent;
  final String helpText;
  final String sentHelpText;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 29),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              UnderlineTextField(
                label: label,
                hint: hint,
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                padding: const EdgeInsets.fromLTRB(0, 17, 118, 13),
              ),
              Positioned(
                top: 28,
                right: 0,
                child: _SendButton(sent: sent, onPressed: onSend),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            sent ? sentHelpText : helpText,
            style: const TextStyle(color: AuthColors.gray8E, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.sent, required this.onPressed});

  final bool sent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sent ? AuthColors.fillF2 : Colors.transparent,
          border: Border.all(
            color: sent ? AuthColors.lineDD : AuthColors.black,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          sent ? '재전송' : '인증 메일 보내기',
          style: TextStyle(
            color: sent ? AuthColors.gray77 : AuthColors.black,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// 점선 상자: "증명서 사진 업로드"
class CertificateUploadBox extends StatelessWidget {
  const CertificateUploadBox({
    super.key,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 174),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 47,
                  height: 47,
                  margin: const EdgeInsets.only(bottom: 13),
                  decoration: const BoxDecoration(
                    color: AuthColors.fillF1,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    size: 25,
                    color: AuthColors.black,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: AuthColors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AuthColors.gray8E,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AuthColors.grayAA
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
          const Radius.circular(11),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 4), paint);
        distance += 7;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 첨부된 증명서 미리보기 + 삭제(×) 버튼
class CertificateAttached extends StatelessWidget {
  const CertificateAttached({
    super.key,
    required this.bytes,
    required this.documentName,
    required this.caption,
    required this.onDelete,
  });

  final Uint8List bytes;
  final String documentName;
  final String caption;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 174,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF6F6F6), Color(0xFFE9E9E9)],
                  ),
                  border: Border.all(color: AuthColors.lineDD),
                  borderRadius: BorderRadius.circular(11),
                ),
                // 실제 사진이 있으면 사진, 없으면(가짜 서비스) 디자인의 예시 모양
                child: bytes.isNotEmpty
                    ? Image.memory(bytes, fit: BoxFit.cover)
                    : _SampleDocument(documentName: documentName),
              ),
              Positioned(
                top: 9,
                right: 9,
                child: Semantics(
                  button: true,
                  label: '삭제',
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xB8000000),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '×',
                        style: TextStyle(
                          color: AuthColors.white,
                          fontSize: 19,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: const TextStyle(color: AuthColors.gray77, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _SampleDocument extends StatelessWidget {
  const _SampleDocument({required this.documentName});

  final String documentName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DAELIM UNIVERSITY',
            style: TextStyle(
              color: Color(0xFF999999),
              fontFamily: 'Georgia',
              fontSize: 8,
              letterSpacing: 0.96,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            documentName,
            style: const TextStyle(
              color: AuthColors.black,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 13),
          for (var i = 0; i < 3; i++)
            FractionallySizedBox(
              widthFactor: 0.75,
              child: Container(
                height: 5,
                margin: const EdgeInsets.only(top: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFD3D3D3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 재학생 인증 방법 선택: 학교 이메일 / 재학 증명서
class VerifyMethodSegment extends StatelessWidget {
  const VerifyMethodSegment({
    super.key,
    required this.useEmail,
    required this.onChanged,
  });

  final bool useEmail;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43,
      margin: const EdgeInsets.only(top: 29),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AuthColors.fillF1,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          _segment('학교 이메일', selected: useEmail, onTap: () => onChanged(true)),
          _segment(
            '재학 증명서',
            selected: !useEmail,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _segment(
    String label, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: selected
              ? BoxDecoration(
                  color: AuthColors.white,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x17000000),
                      offset: Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                )
              : null,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AuthColors.black : AuthColors.gray88,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
