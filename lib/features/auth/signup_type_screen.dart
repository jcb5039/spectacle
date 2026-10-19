// [A] 02 시작·회원가입 > 회원가입 1/3 회원 유형 선택 (디자인: SignUp-1, SignUp-1-Student)
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import 'signup_data.dart';
import 'signup_info_screen.dart';
import 'widgets/auth_widgets.dart';

class SignUpTypeScreen extends StatefulWidget {
  const SignUpTypeScreen({super.key});

  @override
  State<SignUpTypeScreen> createState() => _SignUpTypeScreenState();
}

class _SignUpTypeScreenState extends State<SignUpTypeScreen> {
  MemberType _memberType = MemberType.employee;

  @override
  Widget build(BuildContext context) {
    return SignUpStepScaffold(
      step: 1,
      buttonLabel: '다음',
      onButtonPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SignUpInfoScreen(data: SignUpData(memberType: _memberType)),
        ),
      ),
      children: [
        const SignUpStepIntro(
          kicker: 'WELCOME TO SPECTACLE',
          title: '어떤 회원으로\n가입할까요?',
          description: '회원 유형에 따라 이용할 수 있는 기능이 달라요.',
        ),
        const SizedBox(height: 44),
        _RoleCard(
          icon: Icons.edit_outlined,
          title: '취업한 선배예요',
          subtitle: '후기 작성 · 질문 답변',
          selected: _memberType == MemberType.employee,
          onTap: () => setState(() => _memberType = MemberType.employee),
        ),
        const SizedBox(height: 12),
        _RoleCard(
          icon: Icons.contact_support_outlined,
          title: '재학생이에요',
          subtitle: '후기 보기 · 질문하기',
          selected: _memberType == MemberType.student,
          onTap: () => setState(() => _memberType = MemberType.student),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 116),
        padding: selected
            ? const EdgeInsets.symmetric(horizontal: 17, vertical: 19)
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: AuthColors.white,
          border: Border.all(
            color: selected ? AuthColors.black : AuthColors.lineE5,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.centerStart,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: AuthColors.fillF2,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 23, color: AuthColors.black),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AuthColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AuthColors.gray8E,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 오른쪽 위 체크 표시 (카드 바깥 기준 위 15, 오른쪽 15)
            Positioned(
              top: selected ? -4 : -5,
              right: selected ? -2 : -3,
              child: Container(
                width: 23,
                height: 23,
                decoration: BoxDecoration(
                  color: selected ? AuthColors.black : null,
                  border: Border.all(
                    color: selected ? AuthColors.black : AuthColors.lineDD,
                  ),
                  shape: BoxShape.circle,
                ),
                child: selected
                    ? const Icon(Icons.check, size: 14, color: AuthColors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
