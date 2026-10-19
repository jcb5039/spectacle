// [공통-A] 하단 탭 5개(홈/검색/Q&A/랭킹/MY)를 묶는 화면
import 'package:flutter/material.dart';

import '../features/my/my_screen.dart';
import '../features/ranking/ranking_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  // B가 홈·검색·Q&A 화면을 만들면 Center(...)를 실제 화면으로 바꾼다.
  // 홈·검색·Q&A: B / 랭킹·MY: A
  static const List<Widget> _tabs = [
    Center(child: Text('홈')),
    Center(child: Text('검색')),
    Center(child: Text('Q&A')),
    RankingScreen(),
    MyScreen(),
  ];

  // (이름, 기본 아이콘, 선택됐을 때 아이콘)
  static const List<(String, IconData, IconData)> _items = [
    ('홈', Icons.home_outlined, Icons.home),
    ('검색', Icons.search, Icons.search),
    ('Q&A', Icons.contact_support_outlined, Icons.contact_support),
    ('랭킹', Icons.bar_chart, Icons.bar_chart),
    ('MY', Icons.person_outline, Icons.person),
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
            for (final (label, icon, selectedIcon) in _items)
              BottomNavigationBarItem(
                icon: Icon(icon),
                activeIcon: Icon(selectedIcon),
                label: label,
              ),
          ],
        ),
      ),
    );
  }
}
