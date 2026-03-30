import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/mock_lck_data.dart';
import 'package:frontend/features/players/presentation/pages/player_detail_page.dart';

void main() {
  testWidgets('does not overflow when a metric value wraps to two lines', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(390, 844));

    final player = MockLckData.players.first.copyWith(
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
}
