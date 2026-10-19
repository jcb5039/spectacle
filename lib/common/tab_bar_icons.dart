// [공통-A] 하단 탭 아이콘 5개(홈/검색/Q&A/랭킹/MY)를 디자인 SVG 모양 그대로 그리는 부품. 선택된 탭은 속을 채운다 (디자인: Today·Search·QA·Ranking·My의 tab-bar)
import 'package:flutter/material.dart';

enum TabIconType { home, search, qa, ranking, my }

// 디자인 SVG 원본 (24×24 기준)
const _paths = {
  TabIconType.home: [
    'm3 10 9-7 9 7v10a1 1 0 0 1-1 1h-5v-7H9v7H4a1 1 0 0 1-1-1V10Z',
  ],
  TabIconType.search: ['m15.5 15.5 5 5'],
  TabIconType.qa: [
    'M20 15a3 3 0 0 1-3 3H9l-5 3v-3a3 3 0 0 1-2-3V6a3 3 0 0 1 3-3h12a3 3 0 0 1 3 3v9Zm-11-5a3 3 0 1 1 4.8 2.4c-1.2.8-1.8 1.3-1.8 2.6m0-8.5v.01',
  ],
  TabIconType.ranking: ['M4 20V10h4v10H4Zm6 0V4h4v16h-4Zm6 0v-7h4v7h-4Z'],
  TabIconType.my: ['M4 21c.8-4.2 3.5-6.5 8-6.5s7.2 2.3 8 6.5'],
};

// 원 (가운데 x, 가운데 y, 반지름)
const _circles = {
  TabIconType.search: [(10.5, 10.5, 6.5)],
  TabIconType.my: [(12.0, 8.0, 4.0)],
};

// 색과 크기는 하단 탭이 정해주는 값(IconTheme)을 따른다
class TabBarIcon extends StatelessWidget {
  const TabBarIcon(this.type, {super.key, this.filled = false});

  final TabIconType type;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final size = iconTheme.size ?? 22;
    return CustomPaint(
      size: Size.square(size),
      painter: _TabIconPainter(
        type: type,
        filled: filled,
        color: iconTheme.color ?? Colors.black,
      ),
    );
  }
}

class _TabIconPainter extends CustomPainter {
  _TabIconPainter({
    required this.type,
    required this.filled,
    required this.color,
  });

  final TabIconType type;
  final bool filled;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final shape = Path();
    for (final data in _paths[type] ?? const <String>[]) {
      shape.addPath(parseSvgPath(data), Offset.zero);
    }
    for (final (cx, cy, r)
        in _circles[type] ?? const <(double, double, double)>[]) {
      shape.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    }
    if (filled) {
      canvas.drawPath(shape, Paint()..color = color);
    }
    canvas.drawPath(
      shape,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_TabIconPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.filled != filled ||
      oldDelegate.color != color;
}

// SVG path 글자(d="...")를 Flutter Path로 바꾼다. M L H V C S A Z (대·소문자)만 지원
Path parseSvgPath(String data) {
  final tokens = RegExp(r'[MmLlHhVvCcSsAaZz]|-?(?:\d+\.?\d*|\.\d+)')
      .allMatches(data)
      .map((match) => match.group(0)!)
      .toList();
  final path = Path();
  var index = 0;
  var command = 'M';
  var x = 0.0, y = 0.0, startX = 0.0, startY = 0.0;
  // S 명령에서 쓰는 직전 곡선의 두 번째 조절점
  double? lastControlX, lastControlY;

  bool isCommand(String token) => RegExp(r'^[A-Za-z]$').hasMatch(token);
  double next() => double.parse(tokens[index++]);

  while (index < tokens.length) {
    if (isCommand(tokens[index])) command = tokens[index++];
    final relative = command == command.toLowerCase();
    final baseX = relative ? x : 0.0;
    final baseY = relative ? y : 0.0;
    var keepControl = false;

    switch (command.toUpperCase()) {
      case 'M':
        x = baseX + next();
        y = baseY + next();
        path.moveTo(x, y);
        startX = x;
        startY = y;
        // M 뒤에 이어진 숫자는 선(L)으로 본다
        command = relative ? 'l' : 'L';
      case 'L':
        x = baseX + next();
        y = baseY + next();
        path.lineTo(x, y);
      case 'H':
        x = baseX + next();
        path.lineTo(x, y);
      case 'V':
        y = baseY + next();
        path.lineTo(x, y);
      case 'C':
        final x1 = baseX + next(), y1 = baseY + next();
        final x2 = baseX + next(), y2 = baseY + next();
        x = baseX + next();
        y = baseY + next();
        path.cubicTo(x1, y1, x2, y2, x, y);
        lastControlX = x2;
        lastControlY = y2;
        keepControl = true;
      case 'S':
        final x1 = lastControlX == null ? x : 2 * x - lastControlX;
        final y1 = lastControlY == null ? y : 2 * y - lastControlY;
        final x2 = baseX + next(), y2 = baseY + next();
        x = baseX + next();
        y = baseY + next();
        path.cubicTo(x1, y1, x2, y2, x, y);
        lastControlX = x2;
        lastControlY = y2;
        keepControl = true;
      case 'A':
        final rx = next(), ry = next(), rotation = next();
        final largeArc = next() != 0, sweep = next() != 0;
        x = baseX + next();
        y = baseY + next();
        path.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rotation,
          largeArc: largeArc,
          clockwise: sweep,
        );
      case 'Z':
        path.close();
        x = startX;
        y = startY;
    }
    if (!keepControl) {
      lastControlX = null;
      lastControlY = null;
    }
  }
  return path;
}
