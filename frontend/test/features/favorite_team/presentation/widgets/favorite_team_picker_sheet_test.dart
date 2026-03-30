import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';

void main() {
  testWidgets('favorite team picker does not overflow on a short screen', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(390, 640));

    await tester.pumpWidget(const LckArchiveApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('설정'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('응원팀 변경'));
    await tester.pumpAndSettle();

    expect(find.text('응원팀 선택'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
