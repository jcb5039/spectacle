// [B] 04 검색 > 검색 화면: 키워드 검색·검색 결과·필터 적용·결과 없음 (디자인: Search, Search-Result, Search-Filtered, Search-Empty)
import 'package:flutter/material.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_text_styles.dart';
import '../../common/widgets/verified_badge.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import '../auth/data/signup_options.dart';
import '../review/review_detail_screen.dart';
import 'widgets/filter_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  // 고른 필터 (비어 있으면 전체)
  Set<String> _schools = _defaultSchools();
  Set<String> _departments = {};
  Set<String> _categories = {};
  Set<String> _companies = {};
  bool _isLatest = true;

  // 처음에는 내 학교 필터가 켜져 있다. (디자인: 대림대학교)
  static Set<String> _defaultSchools() {
    for (final school in schoolOptions) {
      if (school.startsWith(SampleCurrentUser.school)) return {school};
    }
    return {};
  }

  @override
  void initState() {
    super.initState();
    ReviewService.changes.addListener(_onReviewsChanged);
  }

  @override
  void dispose() {
    ReviewService.changes.removeListener(_onReviewsChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onReviewsChanged() => setState(() {});

  List<Review> get _results {
    final list = ReviewService.searchReviews(
      keyword: _controller.text,
      schools: _schools,
      departments: _departments,
      categories: _categories,
      companies: _companies,
    );
    if (_isLatest) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      list.sort((a, b) => b.likeCount.compareTo(a.likeCount));
    }
    return list;
  }

  // 키보드를 내리고 검색창 선택도 푼다.
  // (FocusScope.unfocus는 검색창을 기억해 두었다가, 다른 화면에서 돌아오면 다시 선택한다)
  void _hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  // 필터 초기화: 처음 상태로 되돌린다.
  void _resetFilters() {
    setState(() {
      _controller.clear();
      _schools = _defaultSchools();
      _departments = {};
      _categories = {};
      _companies = {};
    });
  }

  Future<void> _openFilter(
    String title,
    List<String> options,
    Set<String> selected,
    void Function(Set<String>) onApply,
  ) async {
    _hideKeyboard();
    final picked = await showFilterSheet(
      context,
      title: title,
      options: options,
      selected: selected,
    );
    if (picked != null) setState(() => onApply(picked));
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          // 빈 곳을 누르면 키보드를 내린다.
          onTap: _hideKeyboard,
          behavior: HitTestBehavior.translucent,
          child: ListView(
            padding: EdgeInsets.zero,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 19, 20, 15),
                child: Text(
                  '검색',
                  style: TextStyle(
                    fontSize: 28,
                    letterSpacing: -1.54, // -0.055em
                    height: 1.5,
                    color: AppColors.text,
                  ),
                ),
              ),
              _buildSearchField(),
              _buildFilterRow(),
              if (results.isEmpty)
                _buildEmpty()
              else ...[
                _buildHeading(results.length),
                _buildResultList(results),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ───── 검색창 ─────
  Widget _buildSearchField() {
    final hasText = _controller.text.isNotEmpty;

    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 18,
            color: hasText ? AppColors.textSub : AppColors.textOff,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '회사, 직무, 학과로 검색해보세요',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textOff,
                ),
              ),
            ),
          ),
          if (hasText) ...[
            const SizedBox(width: 8),
            Semantics(
              label: '검색어 지우기',
              button: true,
              child: GestureDetector(
                onTap: () => setState(_controller.clear),
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC4C4C4),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '×',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ───── 학교·학과·직무·기업 필터 버튼 ─────
  Widget _buildFilterRow() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 7, 20, 20),
        child: Row(
          children: [
            _FilterChip(
              label: '학교',
              selected: _schools,
              onTap: () => _openFilter(
                '학교',
                schoolOptions,
                _schools,
                (v) => _schools = v,
              ),
            ),
            const SizedBox(width: 7),
            _FilterChip(
              label: '학과',
              selected: _departments,
              onTap: () => _openFilter(
                '학과',
                departmentOptions,
                _departments,
                (v) => _departments = v,
              ),
            ),
            const SizedBox(width: 7),
            _FilterChip(
              label: '직무',
              selected: _categories,
              onTap: () => _openFilter(
                '직무',
                ReviewService.jobCategories,
                _categories,
                (v) => _categories = v,
              ),
            ),
            const SizedBox(width: 7),
            _FilterChip(
              label: '기업',
              selected: _companies,
              onTap: () => _openFilter(
                '기업',
                ReviewService.companyNames,
                _companies,
                (v) => _companies = v,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───── "후기 N개" + 최신순 | 인기순 ─────
  Widget _buildHeading(int count) {
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
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('후기 $count개', style: AppTextStyles.sectionTitle),
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

  // ───── 검색 결과 목록 ─────
  Widget _buildResultList(List<Review> results) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        children: [
          for (var i = 0; i < results.length; i++)
            _ResultItem(
              review: results[i],
              showTopLine: i > 0,
              onTap: () {
                _hideKeyboard();
                openReviewDetail(context, results[i]);
              },
            ),
        ],
      ),
    );
  }

  // ───── 결과 없음 ─────
  Widget _buildEmpty() {
    return Container(
      constraints: const BoxConstraints(minHeight: 430),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            margin: const EdgeInsets.only(bottom: 19),
            decoration: const BoxDecoration(
              color: AppColors.iconBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search,
              size: 28,
              color: AppColors.textInactive,
            ),
          ),
          const Text(
            '조건에 맞는 후기가 없어요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '필터 조건을 바꾸거나 초기화해보세요.',
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: AppColors.textSub,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _resetFilters,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCCCCCC)),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '필터 초기화',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF555555),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 필터 버튼 하나. 고른 항목이 있으면 검정 바탕에 항목 이름을 보여준다.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Set<String> selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final applied = selected.isNotEmpty;
    final text = switch (selected.length) {
      0 => label,
      1 => selected.first,
      _ => '${selected.first} 외 ${selected.length - 1}',
    };
    final style = TextStyle(
      fontSize: 12,
      height: 1.5,
      color: applied ? Colors.white : const Color(0xFF555555),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: applied ? AppColors.text : null,
          border: Border.all(
            color: applied ? AppColors.text : AppColors.separator,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$text ', style: style),
            const SizedBox(width: 4),
            Text('⌄', style: style),
          ],
        ),
      ),
    );
  }
}

// 검색 결과 한 줄: 제목, 회사 · 직무 · 학과, 인증 선배
class _ResultItem extends StatelessWidget {
  const _ResultItem({
    required this.review,
    required this.showTopLine,
    required this.onTap,
  });

  final Review review;
  final bool showTopLine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meta = [
      review.company,
      review.job,
      review.authorDepartment,
    ].where((t) => t.isNotEmpty).join(' · ');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: showTopLine
              ? const Border(top: BorderSide(color: AppColors.divider))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 7),
              child: Text(
                keepAll(review.title),
                style: const TextStyle(
                  fontSize: 15,
                  letterSpacing: -0.525, // -0.035em
                  height: 1.45,
                  color: AppColors.text,
                ),
              ),
            ),
            Text(
              meta,
              style: const TextStyle(
                fontSize: 10,
                height: 1.5,
                color: AppColors.textSub,
              ),
            ),
            const SizedBox(height: 10),
            const VerifiedBadge(style: VerifiedBadgeStyle.muted),
          ],
        ),
      ),
    );
  }
}
