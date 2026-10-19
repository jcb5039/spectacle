import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spectacle/app.dart';

void main() {
  testWidgets('하단 탭 5개가 보이고 누르면 화면이 바뀐다', (WidgetTester tester) async {
    await tester.pumpWidget(const SpectacleApp());

    final tabBar = find.byType(BottomNavigationBar);
    for (final label in ['홈', '검색', 'Q&A', '랭킹', 'MY']) {
      expect(
        find.descendant(of: tabBar, matching: find.text(label)),
        findsOneWidget,
      );
    }

    await tester.tap(find.descendant(of: tabBar, matching: find.text('MY')));
    await tester.pump();

    final bar = tester.widget<BottomNavigationBar>(tabBar);
    expect(bar.currentIndex, 4);
  });
}
