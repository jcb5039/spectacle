// [B] 03 홈·후기 > 홈 화면: TODAY / DISCOVER 탭 (디자인: Today, Discover)
import 'package:flutter/material.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/review_card.dart';
import '../../common/widgets/verified_badge.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import 'notifications_screen.dart';
import 'widgets/banner_slider.dart';

const List<String> _jobCategories = ['전체', ...ReviewService.jobCategories];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isToday = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildHomeTabs(),
                  if (_isToday) const _TodayView() else const _DiscoverView(),
                ],
              ),
            ),
            if (_isToday)
              Positioned(
                right: 18,
                bottom: 14,
                child: _WriteButton(
                  // 후기 작성 화면을 만든 뒤 이동 기능을 넣는다.
                  onTap: () {},
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 로고 + 알림 버튼
  Widget _buildHeader() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              _BrandLogo(size: 34),
              SizedBox(width: 10),
              Text('스팩타클', style: AppTextStyles.logo),
            ],
          ),
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: '알림',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_none,
                    size: 21,
                    color: AppColors.text,
                  ),
                ),
                Positioned(
                  top: 7,
                  right: 7,
                  child: IgnorePointer(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.text,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TODAY / DISCOVER 전환
  Widget _buildHomeTabs() {
    Widget tab(String label, bool selected, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: AppTextStyles.homeTab.copyWith(
            color: selected ? AppColors.text : AppColors.textInactive,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 13, 20, 0),
      child: Row(
        children: [
          tab('TODAY', _isToday, () => setState(() => _isToday = true)),
          const SizedBox(width: 18),
          tab('DISCOVER', !_isToday, () => setState(() => _isToday = false)),
        ],
      ),
    );
  }
}

// ───────────────────────── TODAY ─────────────────────────

class _TodayView extends StatefulWidget {
  const _TodayView();

  @override
  State<_TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<_TodayView> {
  static const double _cardWidth = 326;
  static const double _cardGap = 12;

  PageController? _controller;
  double _viewportWidth = 0;
  int _page = 0;

  // 새 후기가 등록되면 다시 그린다.
  void _onReviewsChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    ReviewService.changes.addListener(_onReviewsChanged);
  }

  @override
  void dispose() {
    ReviewService.changes.removeListener(_onReviewsChanged);
    _controller?.dispose();
    super.dispose();
  }

  // 카드 한 장(326) + 간격(12)이 한 페이지가 되도록 화면 폭에 맞춰 만든다.
  PageController _controllerFor(double width) {
    if (_controller == null || _viewportWidth != width) {
      _controller?.dispose();
      _viewportWidth = width;
      _controller = PageController(
        initialPage: _page,
        viewportFraction: (_cardWidth + _cardGap) / width,
      );
    }
    return _controller!;
  }

  @override
  Widget build(BuildContext context) {
    final todayReviews = ReviewService.homeReviews.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '우리 학교 선배의 진짜 취업 이야기',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textSub,
                ),
              ),
              SizedBox(height: 7),
              Text(
                '이번 주, 꼭 읽어볼 후기',
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: -0.99,
                  height: 1.35,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 500,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return PageView.builder(
                  controller: _controllerFor(constraints.maxWidth),
                  padEnds: false,
                  clipBehavior: Clip.none,
                  itemCount: todayReviews.length,
                  onPageChanged: (index) => setState(() => _page = index),
                  itemBuilder: (context, index) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: _StoryCard(
                        review: todayReviews[index],
                        // 후기 상세 화면을 만든 뒤 이동 기능을 넣는다.
                        onTap: () {},
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: 34,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < todayReviews.length; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                Container(
                  width: i == _page ? 15 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.text : AppColors.dotOff,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ],
          ),
        ),
        // 글쓰기 버튼에 카드가 가리지 않도록 아래 여백
        const SizedBox(height: 80),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.review, this.onTap});

  final Review review;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subColor = Colors.white.withValues(alpha: 0.72);

    return SizedBox(
      width: _TodayViewState._cardWidth,
      height: 500,
      child: Material(
        color: AppColors.text,
        borderRadius: BorderRadius.circular(11),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                top: 24,
                left: 22,
                child: Text(
                  review.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.24,
                    height: 1.5,
                    color: subColor,
                  ),
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const VerifiedBadge(),
                    const SizedBox(height: 13),
                    Text(
                      keepAll(review.title),
                      style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: -1.2,
                        height: 1.3,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Text(
                      review.companyAndJob,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: subColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WriteButton extends StatelessWidget {
  const _WriteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x38000000), // rgba(0,0,0,0.22)
            offset: Offset(0, 8),
            blurRadius: 25,
          ),
        ],
      ),
      child: Material(
        color: AppColors.text,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const Tooltip(
            message: '후기 작성',
            child: Icon(Icons.edit_outlined, size: 21, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────── DISCOVER ────────────────────────

class _DiscoverView extends StatefulWidget {
  const _DiscoverView();

  @override
  State<_DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<_DiscoverView> {
  String _category = '전체';
  bool _isLatest = true;

  // 새 후기가 등록되면 다시 그린다.
  void _onReviewsChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    ReviewService.changes.addListener(_onReviewsChanged);
  }

  @override
  void dispose() {
    ReviewService.changes.removeListener(_onReviewsChanged);
    super.dispose();
  }

  List<Review> get _visibleReviews {
    final list = ReviewService.homeReviews
        .where((r) => _category == '전체' || r.category == _category)
        .toList();
    if (!_isLatest) {
      list.sort((a, b) => b.likeCount.compareTo(a.likeCount));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 17),
        _buildJobTabs(),
        // 배너 모음 화면을 만든 뒤 이동 기능을 넣는다.
        BannerSlider(onTap: () {}),
        _buildFeedHeading(),
        _buildFeedGrid(),
      ],
    );
  }

  Widget _buildJobTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 13),
        child: Row(
          children: [
            for (int i = 0; i < _jobCategories.length; i++) ...[
              if (i > 0) const SizedBox(width: 20),
              GestureDetector(
                onTap: () => setState(() => _category = _jobCategories[i]),
                child: Text(
                  _jobCategories[i],
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: _category == _jobCategories[i]
                        ? FontWeight.w800
                        : FontWeight.w400,
                    color: _category == _jobCategories[i]
                        ? AppColors.text
                        : AppColors.textOff,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeedHeading() {
    Widget sortButton(String label, bool on, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            height: 1.5,
            fontWeight: on ? FontWeight.w800 : FontWeight.w500,
            color: on ? AppColors.text : AppColors.textOff,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('선배들의 최신 후기', style: AppTextStyles.sectionTitle),
          Row(
            children: [
              sortButton(
                '최신순',
                _isLatest,
                () => setState(() => _isLatest = true),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '|',
                  style: TextStyle(fontSize: 11, color: AppColors.separator),
                ),
              ),
              sortButton(
                '인기순',
                !_isLatest,
                () => setState(() => _isLatest = false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2칸씩 나란히 놓는 후기 카드 목록
  Widget _buildFeedGrid() {
    final reviews = _visibleReviews;
    final rows = <Widget>[];
    for (int i = 0; i < reviews.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 12));
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _card(reviews[i])),
            const SizedBox(width: 12),
            Expanded(
              child: i + 1 < reviews.length
                  ? _card(reviews[i + 1])
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(children: rows),
    );
  }

  Widget _card(Review review) {
    return ReviewCard(
      category: review.category,
      title: review.title,
      subtitle: review.companyAndJob,
      likeCount: review.likeCount,
      // 후기 상세 화면을 만든 뒤 이동 기능을 넣는다.
      onTap: () {},
    );
  }
}

// ──────────────────────── 로고 ────────────────────────

// 디자인의 로고 SVG를 그대로 옮겨 그린다. (44×44 기준 좌표)
class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _BrandLogoPainter());
  }
}

class _BrandLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 44);
    final black = Paint()..color = const Color(0xFF111111);
    final white = Paint()..color = Colors.white;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 44, 44),
        const Radius.circular(11),
      ),
      black,
    );

    const r7 = Radius.circular(7);
    const r4 = Radius.circular(4);

    final topBubble = Path()
      ..moveTo(10, 11)
      ..lineTo(24, 11)
      ..arcToPoint(const Offset(31, 18), radius: r7)
      ..lineTo(31, 20)
      ..arcToPoint(const Offset(24, 27), radius: r7)
      ..lineTo(18, 27)
      ..lineTo(12, 31.5)
      ..lineTo(12, 27)
      ..arcToPoint(const Offset(7, 20.3), radius: r7)
      ..lineTo(7, 15)
      ..arcToPoint(const Offset(11, 11), radius: r4)
      ..close();
    canvas.drawPath(topBubble, white);

    final bottomBubble = Path()
      ..moveTo(34, 33)
      ..lineTo(20, 33)
      ..arcToPoint(const Offset(13, 26), radius: r7)
      ..lineTo(13, 24)
      ..arcToPoint(const Offset(20, 17), radius: r7)
      ..lineTo(26, 17)
      ..lineTo(32, 12.5)
      ..lineTo(32, 17)
      ..arcToPoint(const Offset(37, 23.7), radius: r7)
      ..lineTo(37, 29)
      ..arcToPoint(const Offset(33, 33), radius: r4)
      ..close();
    canvas.drawPath(bottomBubble, white);

    final overlap = Path()
      ..moveTo(16, 17)
      ..lineTo(24, 17)
      ..arcToPoint(const Offset(31, 24), radius: r7)
      ..lineTo(31, 27)
      ..lineTo(20, 27)
      ..arcToPoint(const Offset(13, 20), radius: r7)
      ..lineTo(13, 17)
      ..close();
    canvas.drawPath(overlap, black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
