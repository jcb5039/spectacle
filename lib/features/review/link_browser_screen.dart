// [B] 03 홈·후기 > 포트폴리오 링크 열기 화면 (디자인: Browser)
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/theme/app_colors.dart';

// 후기의 취업 준비 자료 링크를 앱 안에서 연다.
// 페이지를 불러오는 동안에는 디자인의 회색 빈 화면을 보여준다.
class LinkBrowserScreen extends StatefulWidget {
  const LinkBrowserScreen({super.key, required this.url});

  final String url;

  @override
  State<LinkBrowserScreen> createState() => _LinkBrowserScreenState();
}

class _LinkBrowserScreenState extends State<LinkBrowserScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  // 주소창에는 https:// 를 빼고 보여준다. (디자인: notion.site/airline-interview)
  String get _displayUrl =>
      widget.url.replaceFirst(RegExp(r'^https?://(www\.)?'), '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_loading) const _LoadingPlaceholder(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE7E7E7))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 36,
                height: 36,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: AppColors.text,
                  ),
                  child: const Text(
                    '×',
                    semanticsLabel: '닫기',
                    style: TextStyle(
                      fontSize: 31,
                      fontWeight: FontWeight.w300,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.link, size: 12, color: AppColors.textLike),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      _displayUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textLike,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }
}

// 디자인의 회색 빈 웹페이지 모양 (불러오는 중 표시)
class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    Widget line(double widthFactor) {
      return FractionallySizedBox(
        widthFactor: widthFactor,
        alignment: Alignment.centerLeft,
        child: Container(
          height: 12,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFDDDDDD),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      );
    }

    Widget dot() => Container(
          width: 9,
          height: 9,
          decoration: const BoxDecoration(
            color: Color(0xFFB7B7B7),
            shape: BoxShape.circle,
          ),
        );

    return Container(
      color: const Color(0xFFEEEEEE),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: const BoxDecoration(
              color: Color(0xFFDEDEDE),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFAAAAAA),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const Spacer(),
                dot(),
                const SizedBox(width: 6),
                dot(),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F7F7),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      margin: const EdgeInsets.only(bottom: 25),
                      decoration: const BoxDecoration(
                        color: AppColors.dotOff,
                        shape: BoxShape.circle,
                      ),
                    ),
                    line(0.88),
                    line(0.63),
                    Container(
                      height: 180,
                      margin: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    line(0.88),
                    line(0.88),
                    line(0.46),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        for (var i = 0; i < 2; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 72,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDDDDDD),
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
