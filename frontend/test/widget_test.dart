import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/app/app.dart';
import 'package:frontend/features/auth/presentation/pages/splash_page.dart';

void main() {
  testWidgets('shows auth entry flow on app launch', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const LckArchiveApp());

    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('좋아하는 팀을 중심으로\nLCK를 더 빠르게 봅니다.'), findsOneWidget);
    expect(find.text('로그인하고 시작'), findsOneWidget);
    expect(find.text('게스트로 둘러보기'), findsOneWidget);

    await tester.tap(find.text('로그인하고 시작'));
    await tester.pumpAndSettle();

    expect(find.text('로그인'), findsWidgets);
    expect(find.text('이메일'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '로그인'), findsOneWidget);
  });
}
