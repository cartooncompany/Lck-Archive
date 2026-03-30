import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app/app.dart';

void main() {
  testWidgets('shows personalized LCK home shell', (WidgetTester tester) async {
    await tester.pumpWidget(const LckArchiveApp());
    await tester.pumpAndSettle();

    expect(find.text('LCK Archive'), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('T1'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('예정 경기 일정'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('예정 경기 일정'), findsOneWidget);
  });
}
