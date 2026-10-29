// [A] 06 랭킹·MY > 랭킹 화면: 도움된 글 / 활동 많은 선배 탭 (디자인: Ranking, Ranking-Seniors)
import 'package:flutter/material.dart';

import '../../services/qa_service.dart';
import '../../services/ranking_service.dart';
import '../../services/review_service.dart';
import '../auth/widgets/auth_widgets.dart';
import '../my/widgets/my_widgets.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  int _tabIndex = 0;
  late Future<List<RankedPost>> _posts = RankingService.instance
      .topHelpfulPosts();
  late Future<List<RankedSenior>> _seniors = RankingService.instance
      .topActiveSeniors();

  @override
  void initState() {
    super.initState();
    // 후기·질문·답변·좋아요가 바뀌면 랭킹을 다시 계산한다
    ReviewService.changes.addListener(_reload);
    QaService.changes.addListener(_reload);
  }

  @override
  void dispose() {
    ReviewService.changes.removeListener(_reload);
    QaService.changes.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _posts = RankingService.instance.topHelpfulPosts();
      _seniors = RankingService.instance.topActiveSeniors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const PageTitle(title: '랭킹', subtitle: '후배들에게 가장 도움 된 이야기'),
            UnderlineTabs(
              labels: const ['도움된 글', '활동 많은 선배'],
              selectedIndex: _tabIndex,
              onChanged: (index) => setState(() => _tabIndex = index),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 3, 20, 30),
              child: _tabIndex == 0 ? _buildPosts() : _buildSeniors(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosts() {
    return FutureBuilder<List<RankedPost>>(
      future: _posts,
      builder: (context, snapshot) {
        final posts = snapshot.data ?? [];
        return Column(
          children: [
            for (var i = 0; i < posts.length; i++)
              _RankedPostRow(rank: i + 1, post: posts[i]),
          ],
        );
      },
    );
  }

  Widget _buildSeniors() {
    return FutureBuilder<List<RankedSenior>>(
      future: _seniors,
      builder: (context, snapshot) {
        final seniors = snapshot.data ?? [];
        return Column(
          children: [
            for (var i = 0; i < seniors.length; i++)
              _RankedSeniorRow(rank: i + 1, senior: seniors[i]),
          ],
        );
      },
    );
  }
}

class _RankedPostRow extends StatelessWidget {
  const _RankedPostRow({required this.rank, required this.post});

  final int rank;
  final RankedPost post;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // TODO: B의 후기 상세 화면(review_detail_screen)이 생기면 연결
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AuthColors.lineEE)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              child: RankNumber(rank: rank, fontSize: 24, twoDigits: true),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      color: AuthColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.49,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 12,
                        color: AuthColors.gray8E,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount}',
                        style: const TextStyle(
                          color: AuthColors.gray8E,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankedSeniorRow extends StatelessWidget {
  const _RankedSeniorRow({required this.rank, required this.senior});

  final int rank;
  final RankedSenior senior;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // TODO: B의 선배 프로필 화면(senior_profile_screen)이 생기면 연결
      onTap: () {},
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AuthColors.lineEE)),
        ),
        child: Row(
          children: [
            SizedBox(width: 22, child: RankNumber(rank: rank, fontSize: 18)),
            const SizedBox(width: 10),
            ProfileAvatar(name: senior.name, size: 46, fontSize: 13),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        senior.name,
                        style: const TextStyle(
                          color: AuthColors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const VerifiedSeniorBadge(),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    // 비어 있는 값은 빼고 잇는다
                    [
                      senior.company,
                      senior.jobTitle,
                    ].where((t) => t.isNotEmpty).join(' · '),
                    style: const TextStyle(
                      color: AuthColors.gray8E,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            OutlinePill(label: '답변 ${senior.answerCount}'),
          ],
        ),
      ),
    );
  }
}
