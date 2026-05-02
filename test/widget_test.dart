import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tableclock/app.dart';

void main() {
  testWidgets('Clock app renders without crash', (WidgetTester tester) async {
    await tester.pumpWidget(const ClockApp());
    // 첫 프레임 + 일부 프레임 진행
    await tester.pump();
    // 시간 텍스트(콜론) 또는 Scaffold가 존재하는지 점검
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
