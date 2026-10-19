// [공통-A] 하단 탭 5개(홈/검색/Q&A/랭킹/MY)를 묶는 화면
import 'package:flutter/material.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  // 각 담당자가 화면을 만들면 Center(...)를 실제 화면으로 바꾼다.
  // 홈·검색·Q&A: B / 랭킹·MY: A
  static const List<Widget> _tabs = [
    Center(child: Text('홈')),
    Center(child: Text('검색')),
    Center(child: Text('Q&A')),
    Center(child: Text('랭킹')),
    Center(child: Text('MY')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF111111),
        unselectedItemColor: const Color(0xFFAAAAAA),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Q&A',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            label: '랭킹',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'MY',
          ),
        ],
      ),
    );
  }
}
