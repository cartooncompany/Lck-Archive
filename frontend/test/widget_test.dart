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

    expect(find.text('응원팀 기준으로\nLCK를 바로 봅니다.'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);
    expect(find.text('게스트로 보기'), findsOneWidget);

    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();

    expect(find.text('아카이브 로그인'), findsOneWidget);
    expect(find.text('아카이브 입장'), findsOneWidget);
  });
}
