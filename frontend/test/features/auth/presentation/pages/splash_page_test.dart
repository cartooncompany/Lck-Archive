import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/presentation/pages/splash_page.dart';
import 'package:frontend/core/constants/app_strings.dart';

void main() {
  testWidgets('splash renders logo and tagline', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.byType(Image), findsOneWidget);
    expect(find.text(AppStrings.appTagline), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 반복 애니메이션 정리
    await tester.pumpWidget(const SizedBox());
  });
}
