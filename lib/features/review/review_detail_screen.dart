// [B] 03 홈·후기 > 후기 상세 화면 (디자인: Detail)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/app_dialog.dart';
import '../../common/widgets/verified_badge.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import '../qa/question_write_screen.dart';
import 'link_browser_screen.dart';
import 'senior_profile_screen.dart';

// 어느 화면에서든 후기 상세를 여는 함수
void openReviewDetail(BuildContext context, Review review) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => ReviewDetailScreen(review: review)));
}

// 후기 사진 자리. 사진 저장 방식을 정하기 전까지 회색 상자로 보여준다.
class ReviewPhoto extends StatelessWidget {
  const ReviewPhoto({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 0,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFDDDDDD),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ReviewDetailScreen extends StatefulWidget {
  const ReviewDetailScreen({
    super.key,
    required this.review,
    this.toastMessage,
  });

  final Review review;
  final String? toastMessage; // 열리자마자 띄울 알림 띠 (예: 후기가 등록됐어요)

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  static const double _coverHeight = 510;

  final ScrollController _scroll = ScrollController();
  bool _showStickyHeader = false;
  bool _liked = false;

  Review get review => widget.review;

  @override
  void initState() {
    super.initState();
    final message = widget.toastMessage;
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showBlackToast(context, message);
      });
    }
    _scroll.addListener(() {
      final topInset = MediaQuery.of(context).padding.top;
      final show = _scroll.offset > _coverHeight - (topInset + 40);
      if (show != _showStickyHeader) setState(() => _showStickyHeader = show);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 사진 위에서는 위쪽 시계·배터리 글자를 흰색으로
      value: _showStickyHeader
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.only(bottom: 86),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCover(),
                  if (review.authorName.isNotEmpty) _buildAuthor(),
                  Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAFAFA),
                      border: Border.symmetric(
                        horizontal: BorderSide(color: AppColors.divider),
                      ),
                    ),
                  ),
                  ..._buildBody(),
                  if (review.links.isNotEmpty) ..._buildLinks(),
                  if (review.hashtags.isNotEmpty) _buildHashtags(),
                  _buildRelated(),
                ],
              ),
            ),
            _buildStickyHeader(),
            Positioned(left: 0, right: 0, bottom: 0, child: _buildActions()),
          ],
        ),
      ),
    );
  }

  // ───── 표지: 사진 + 제목 ─────
  Widget _buildCover() {
    final topInset = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: _coverHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ReviewPhoto(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xEB000000), // rgba(0,0,0,0.92)
                  Color(0x38000000), // rgba(0,0,0,0.22)
                  Color(0x00000000),
                ],
                stops: [0, 0.48, 0.72],
              ),
            ),
          ),
          Positioned(
            top: topInset + 2,
            left: 15,
            child: Material(
              color: Colors.black.withValues(alpha: 0.22),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: '뒤로가기',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VerifiedBadge(style: VerifiedBadgeStyle.onPhoto),
                const SizedBox(height: 11),
                Text(
                  keepAll(review.title),
                  style: const TextStyle(
                    fontSize: 26,
                    letterSpacing: -1.43,
                    height: 1.3,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  review.companyAndJob,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───── 작성자 줄 (누르면 선배 프로필) ─────
  Widget _buildAuthor() {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SeniorProfileScreen(review: review)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            ReviewAuthorAvatar(name: review.authorName, size: 42, fontSize: 14),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        review.authorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.5,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const VerifiedBadge(style: VerifiedBadgeStyle.plain),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${review.authorSchool} ${review.authorDepartment} · '
                    '${review.authorAdmissionYear}학번 · '
                    '${review.authorGraduationYear}년 졸업 · '
                    '${review.company} ${review.job}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───── 본문 01~04 ─────
  List<Widget> _buildBody() {
    final sections = [
      ('취업 준비 과정', review.preparation),
      ('취업 과정의 어려움', review.difficulty),
      ('신입 시절 시행착오', review.trialAndError),
      ('후배에게 주는 팁', review.tip),
    ];

    final widgets = <Widget>[];
    var number = 0;
    for (var i = 0; i < sections.length; i++) {
      final (heading, body) = sections[i];
      if (body.isEmpty) continue;
      number++;
      widgets.add(
        _Section(
          index: number.toString().padLeft(2, '0'),
          heading: heading,
          body: body,
          // 인용문은 03 신입 시절 시행착오 아래에 붙는다.
          quote: i == 2 ? review.quote : '',
        ),
      );
      // 사진은 01 아래에 들어간다.
      if (i == 0 &&
          (review.photos.isNotEmpty || review.photoCaption.isNotEmpty)) {
        widgets.add(_buildArticlePhoto());
      }
    }
    return widgets;
  }

  Widget _buildArticlePhoto() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AspectRatio(
            aspectRatio: 1.4,
            child: ReviewPhoto(borderRadius: 9),
          ),
          if (review.photoCaption.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.photoCaption,
              style: const TextStyle(
                fontSize: 10,
                height: 1.5,
                color: AppColors.textSub,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ───── 취업 준비 자료 ─────
  List<Widget> _buildLinks() {
    return [
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 28, 20, 10),
        child: Text(
          '취업 준비 자료',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.5,
            color: AppColors.text,
          ),
        ),
      ),
      for (final link in review.links)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.divider),
              borderRadius: BorderRadius.circular(9),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LinkBrowserScreen(url: link.url),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.text,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        link.type.isEmpty ? '' : link.type[0],
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            link.type,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.5,
                              color: AppColors.textSub,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            link.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.text,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    ];
  }

  // ───── 해시태그 ─────
  Widget _buildHashtags() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (final tag in review.hashtags)
            // 검색 화면을 만든 뒤 누르면 이 해시태그로 검색하게 한다.
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.separator),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '#$tag',
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: AppColors.textBody,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ───── 같은 학과 선배 후기 ─────
  Widget _buildRelated() {
    final related = ReviewService.sameDepartmentReviews(review);
    if (related.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 27, 0, 40),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF7F7F7), width: 8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('같은 학과 선배 후기', style: AppTextStyles.sectionTitle),
                GestureDetector(
                  // 홈으로 돌아간다.
                  onTap: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text(
                    '전체보기',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      color: AppColors.textSub,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < related.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  _RelatedCard(
                    review: related[i],
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => ReviewDetailScreen(review: related[i]),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───── 내리면 나타나는 위쪽 제목 줄 ─────
  Widget _buildStickyHeader() {
    final topInset = MediaQuery.of(context).padding.top;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !_showStickyHeader,
        child: AnimatedOpacity(
          opacity: _showStickyHeader ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedSlide(
            offset: _showStickyHeader ? Offset.zero : const Offset(0, -0.08),
            duration: const Duration(milliseconds: 200),
            child: Container(
              height: topInset + 40,
              padding: EdgeInsets.fromLTRB(17, topInset - 3, 17, 0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                border: const Border(
                  bottom: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: '뒤로가기',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.chevron_left,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: Text(
                          review.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───── 아래 고정 버튼: 도움돼요 / 선배에게 질문하기 ─────
  Widget _buildActions() {
    final likeCount = review.likeCount + (_liked ? 1 : 0);
    return Container(
      height: 86,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 135,
            height: 48,
            child: OutlinedButton(
              // 좋아요 저장은 Firestore 연결 후에 한다.
              onPressed: () => setState(() => _liked = !_liked),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                side: const BorderSide(color: AppColors.separator),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _liked ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: AppColors.text,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '도움돼요 $likeCount',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        QuestionWriteScreen(initialCategory: review.category),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.text,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: const Text(
                  '선배에게 질문하기',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 본문 한 항목 (번호 + 제목 + 내용 + 인용문)
class _Section extends StatelessWidget {
  const _Section({
    required this.index,
    required this.heading,
    required this.body,
    this.quote = '',
  });

  final String index;
  final String heading;
  final String body;
  final String quote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 34, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index,
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 12,
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: AppColors.textSub,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            heading,
            style: const TextStyle(
              fontSize: 20,
              letterSpacing: -0.9,
              height: 1.4,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            keepAll(body),
            style: const TextStyle(
              fontSize: 15,
              letterSpacing: -0.27,
              height: 1.85,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 17),
          if (quote.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 24 - 17),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  left: BorderSide(color: AppColors.text, width: 2),
                ),
              ),
              child: Text(
                keepAll('“$quote”'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.65,
                  color: AppColors.text,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 같은 학과 선배 후기 카드 (옆으로 넘기는 목록 한 칸)
class _RelatedCard extends StatelessWidget {
  const _RelatedCard({required this.review, required this.onTap});

  final Review review;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 148,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ReviewPhoto(width: 148, height: 112, borderRadius: 8),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: Text(
                keepAll(review.title),
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              review.companyAndJob,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                height: 1.5,
                color: AppColors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 이름 첫 글자가 들어간 검정 원 (작성자·선배 프로필)
class ReviewAuthorAvatar extends StatelessWidget {
  const ReviewAuthorAvatar({
    super.key,
    required this.name,
    required this.size,
    required this.fontSize,
  });

  final String name;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.text,
        shape: BoxShape.circle,
      ),
      child: Text(
        // 성을 뺀 이름 첫 글자 (디자인: 김민지 → 민)
        name.length > 1 ? name.substring(1, 2) : name,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
