import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/players/presentation/pages/player_detail_page.dart';
import '../../../../test_helpers/sample_lck_test_data.dart';

void main() {
  testWidgets('does not overflow when a metric value wraps to two lines', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(390, 844));

    final player = sampleFaker.copyWith(
      realName: 'Minseok Ryu',
      nationality: 'Korea',
      birthDate: DateTime(1996, 5, 7),
    );

    await tester.pumpWidget(
      MaterialApp(home: PlayerDetailPage(player: player)),
    );
    await tester.pumpAndSettle();

    expect(find.text('실명'), findsOneWidget);
    expect(find.text('Minseok\nRyu'), findsNothing);
    expect(find.text('Minseok Ryu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps a stable wide layout on desktop-sized screens', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1280, 900));

    final player = sampleFaker.copyWith(
      realName: 'Lee Sang-hyeok',
      nationality: 'Korea',
      birthDate: DateTime(1996, 5, 7),
    );

    await tester.pumpWidget(
      MaterialApp(home: PlayerDetailPage(player: player)),
    );
    await tester.pumpAndSettle();

    expect(find.text('소속 팀 보기'), findsOneWidget);
    expect(find.text('시즌 기록'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
