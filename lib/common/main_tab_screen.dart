// [공통-A] 하단 탭 5개(홈/검색/Q&A/랭킹/MY)를 묶는 화면
import 'package:flutter/material.dart';

import '../features/home/home_screen.dart';
import '../features/my/my_screen.dart';
import '../features/qa/qa_screen.dart';
import '../features/ranking/ranking_screen.dart';
import '../features/search/search_screen.dart';
import 'tab_bar_icons.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  // 다른 화면에서 하단 탭을 바꿀 때 쓴다. 값에 탭 번호(0 홈 ~ 4 MY)를 넣는다.
  // (B: 후기 상세의 "같은 학과 선배 후기 → 전체보기"가 홈 DISCOVER로 갈 때 사용)
  static final ValueNotifier<int?> tabRequest = ValueNotifier(null);

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    MainTabScreen.tabRequest.addListener(_onTabRequest);
  }

  @override
  void dispose() {
    MainTabScreen.tabRequest.removeListener(_onTabRequest);
    super.dispose();
  }

  void _onTabRequest() {
    final index = MainTabScreen.tabRequest.value;
    if (index == null) return;
    MainTabScreen.tabRequest.value = null;
    setState(() => _currentIndex = index);
  }

  // B가 검색·Q&A 화면을 만들면 Center(...)를 실제 화면으로 바꾼다.
  // 홈·검색·Q&A: B / 랭킹·MY: A
  static const List<Widget> _tabs = [
    HomeScreen(),
    SearchScreen(),
    QaScreen(),
    RankingScreen(),
    MyScreen(),
  ];

  // (이름, 아이콘 모양)
  static const List<(String, TabIconType)> _items = [
    ('홈', TabIconType.home),
    ('검색', TabIconType.search),
    ('Q&A', TabIconType.qa),
    ('랭킹', TabIconType.ranking),
    ('MY', TabIconType.my),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xF5FFFFFF),
          selectedItemColor: const Color(0xFF111111),
          unselectedItemColor: const Color(0xFFA7A7A7),
          iconSize: 22,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          items: [
            for (final (label, type) in _items)
              BottomNavigationBarItem(
                icon: TabBarIcon(type),
                activeIcon: TabBarIcon(type, filled: true),
                label: label,
              ),
          ],
        ),
      ),
    );
  }
}
