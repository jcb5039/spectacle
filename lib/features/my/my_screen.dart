// [A] 06 랭킹·MY > MY 화면, 취업자·재학생 공용 (디자인: My, My-Student)
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/photo_service.dart';
import '../../services/qa_service.dart' show QaService;
import '../../services/ranking_service.dart';
import '../../services/review_service.dart';
import '../../services/user_service.dart';
import '../auth/login_screen.dart';
import '../auth/widgets/auth_widgets.dart';
import 'info_edit_screen.dart';
import 'spec_edit_screen.dart';
import 'widgets/my_widgets.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  AppUser? _user;
  Uint8List? _photo;
  MyActivityStats? _stats;
  List<ReviewSummary> _reviews = [];
  List<QuestionSummary> _questions = [];
  int _tabIndex = 0;

  String get _userId => AuthService.instance.currentUserId ?? 'local-user';

  @override
  void initState() {
    super.initState();
    _load();
    // 후기·질문·답변·좋아요가 바뀌면 숫자와 목록을 다시 불러온다
    ReviewService.changes.addListener(_loadActivity);
    QaService.changes.addListener(_loadActivity);
  }

  @override
  void dispose() {
    ReviewService.changes.removeListener(_loadActivity);
    QaService.changes.removeListener(_loadActivity);
    super.dispose();
  }

  Future<void> _load() async {
    final user = await UserService.instance.getUser(_userId);
    final photo = await PhotoService.instance.getProfilePhoto(_userId);
    if (!mounted) return;
    setState(() {
      _user = user;
      _photo = photo;
    });
    await _loadActivity();
  }

  // 활동 숫자와 목록만 다시 불러온다 (회원 정보·사진은 그대로)
  Future<void> _loadActivity() async {
    final ranking = RankingService.instance;
    final stats = await ranking.myStats(_userId);
    final isEmployee = _user?.isEmployee ?? true;
    // 취업자: 내가 쓴 글 / 질문·답변, 재학생: 내 질문 / 좋아요 누른 후기
    final reviews = isEmployee
        ? await ranking.myReviews(_userId)
        : await ranking.likedReviews(_userId);
    final questions = isEmployee
        ? await ranking.myAnsweredQuestions(_userId)
        : await ranking.myQuestions(_userId);
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _reviews = reviews;
      _questions = questions;
    });
  }

  // 수정 화면에서 돌아오면 다시 불러온다
  Future<void> _open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      backgroundColor: AuthColors.white,
      body: SafeArea(
        bottom: false,
        // 회원 정보가 없어도(가입을 끝내지 않은 계정) 로그아웃은 할 수 있게 버튼만 보여준다
        child: user == null
            ? Align(alignment: Alignment.bottomLeft, child: _buildLogout())
            : ListView(
                padding: EdgeInsets.zero,
                children: [
                  PageTitle(
                    title: 'MY',
                    trailing: OutlinePill(
                      label: '개인정보 수정',
                      height: 32,
                      fontWeight: FontWeight.w700,
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      onTap: () => _open(InfoEditScreen(user: user)),
                    ),
                  ),
                  _buildProfile(user),
                  _buildVerificationBox(user),
                  if (user.isEmployee) _buildSpecCard(user),
                  _buildStats(user),
                  UnderlineTabs(
                    labels: user.isEmployee
                        ? const ['내가 쓴 글', '질문·답변']
                        : const ['내 질문', '도움돼요 누른 후기'],
                    selectedIndex: _tabIndex,
                    onChanged: (index) => setState(() => _tabIndex = index),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: _buildList(user),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildLogout(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProfile(AppUser user) {
    final name = user.nickname ?? '회원';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        children: [
          ProfileAvatar(name: name, size: 82, fontSize: 22, photo: _photo),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: AuthColors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 7),
              if (user.isEmployee)
                const VerifiedSeniorBadge()
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AuthColors.lineEE,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '재학생',
                    style: TextStyle(
                      color: AuthColors.gray77,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            _profileLines(user),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AuthColors.gray8E,
              fontSize: 11,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  // 예: 대림대 항공서비스 · 20학번 · 23년 졸업 \n 에어웨이브 · 객실승무원
  String _profileLines(AppUser user) {
    final school = user.school.endsWith('대학교')
        ? user.school.replaceFirst(RegExp(r'학교$'), '')
        : user.school;
    final parts = [
      '$school ${user.department}'.trim(),
      if (user.admissionYear != null) '${user.admissionYear! % 100}학번',
      if (user.graduationYear != null)
        user.isEmployee
            ? '${user.graduationYear! % 100}년 졸업'
            : '${user.graduationYear! % 100}년 졸업 예정',
    ];
    final first = parts.where((part) => part.isNotEmpty).join(' · ');
    if (!user.isEmployee) return first;
    final job = [
      user.company,
      user.jobTitle,
    ].whereType<String>().where((part) => part.isNotEmpty).join(' · ');
    return job.isEmpty ? first : '$first\n$job';
  }

  Widget _buildVerificationBox(AppUser user) {
    final type = user.isEmployee ? '취업자' : '재학생';
    final verifiedAt = user.verifiedAt;
    final method = user.verificationMethod == VerificationMethod.schoolEmail
        ? '학교 이메일 인증'
        : '인증';
    final detail = user.isVerified && verifiedAt != null
        ? user.isEmployee
              ? '${dotDate(verifiedAt)} 인증 · 회사 정보 공개 범위 설정'
              : '${dotDate(verifiedAt)} $method'
        : '증명서를 확인하고 있어요. 보통 1~2일 걸려요.';
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: AuthColors.lineE5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CheckDot(iconSize: 10),
              const SizedBox(width: 8),
              Text(
                user.isVerified ? '$type 인증 완료' : '$type 인증 확인 중',
                style: const TextStyle(
                  color: AuthColors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: const TextStyle(color: AuthColors.gray8E, fontSize: 10),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AuthColors.fillF1,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              user.isVerified ? '검토 중인 정보 없음' : '검토 중인 정보 있음',
              style: const TextStyle(color: AuthColors.gray77, fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCard(AppUser user) {
    final chips = user.spec.chips;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        border: Border.all(color: AuthColors.lineE5),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MY SPEC',
                      style: TextStyle(
                        color: AuthColors.gray8E,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.04,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '내 스펙',
                      style: TextStyle(
                        color: AuthColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinePill(
                label: '수정',
                color: AuthColors.black,
                fontWeight: FontWeight.w700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                onTap: () => _open(SpecEditScreen(user: user)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (chips.isEmpty)
            const Text(
              '아직 등록한 스펙이 없어요.',
              style: TextStyle(color: AuthColors.gray8E, fontSize: 10),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final chip in chips)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AuthColors.fillF2,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      chip,
                      style: const TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: user.spec.isPublic
                      ? AuthColors.black
                      : AuthColors.grayAA,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                user.spec.isPublic ? '같은 학교 회원에게 공개 중' : '나만 볼 수 있어요',
                style: const TextStyle(color: AuthColors.gray8E, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(AppUser user) {
    final stats = _stats;
    final items = stats == null
        ? <(String, String)>[]
        : user.isEmployee
        ? [
            ('${stats.reviewCount}', '작성한 후기'),
            ('${stats.receivedLikeCount}', '받은 도움돼요'),
            ('${stats.answerCount}', '답변'),
          ]
        : [
            ('${stats.questionCount}', '작성한 질문'),
            ('${stats.receivedAnswerCount}', '받은 답변'),
            ('${stats.givenLikeCount}', '누른 도움돼요'),
          ];
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      padding: const EdgeInsets.symmetric(vertical: 17),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: AuthColors.lineEE),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: i == 0
                        ? null
                        : const Border(
                            left: BorderSide(color: AuthColors.lineEE),
                          ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        items[i].$1,
                        style: const TextStyle(
                          color: AuthColors.black,
                          fontFamily: 'Georgia',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        items[i].$2,
                        style: const TextStyle(
                          color: AuthColors.gray8E,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 맨 아래 왼쪽 로그아웃 (디자인에 없어서 작은 회색 글자 버튼으로 추가)
  Widget _buildLogout() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _logout,
      child: const Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Text(
          '로그아웃',
          style: TextStyle(
            color: AuthColors.gray77,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
            decorationColor: AuthColors.gray77,
          ),
        ),
      ),
    );
  }

  // 로그아웃하고 하단 탭을 모두 닫은 뒤 로그인 화면으로
  Future<void> _logout() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _buildList(AppUser user) {
    // 취업자: 0=내가 쓴 글(후기), 1=질문·답변 / 재학생: 0=내 질문, 1=좋아요 누른 후기
    final showReviews = user.isEmployee ? _tabIndex == 0 : _tabIndex == 1;
    if (showReviews) {
      return Column(
        children: [
          for (final review in _reviews)
            MyListItem(
              leading: const ReviewThumbnail(),
              title: review.title,
              subtitle: review.subtitle,
              verticalPadding: 13,
              // TODO: B의 후기 상세 화면(review_detail_screen)이 생기면 연결
              onTap: () {},
            ),
        ],
      );
    }
    return Column(
      children: [
        for (final question in _questions)
          MyListItem(
            leading: const QuestionMark(),
            title: question.title,
            subtitle: question.answerCount > 0
                ? '선배 답변 ${question.answerCount} · ${timeAgo(question.createdAt)}'
                : '답변을 기다리고 있어요 · ${timeAgo(question.createdAt)}',
            verticalPadding: 15,
            // TODO: B의 Q&A 상세 화면(qa_detail_screen)이 생기면 연결
            onTap: () {},
          ),
      ],
    );
  }
}
