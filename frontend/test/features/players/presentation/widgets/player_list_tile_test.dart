import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/mock_lck_data.dart';
import 'package:frontend/features/players/presentation/widgets/player_list_tile.dart';

void main() {
  group('PlayerListTile', () {
    testWidgets('keeps the player name on a single line in a narrow layout', (
      tester,
    ) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(360, 800));

      final faker = MockLckData.players.firstWhere(
        (player) => player.id == 'faker',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: PlayerListTile(player: faker, onTap: () {}),
              ),
            ),
          ),
        ),
      );

      final tileFinder = find.byType(PlayerListTile);
      final nameFinder = find.descendant(
        of: tileFinder,
        matching: find.text(faker.name),
      );
      final headlineFinder = find.descendant(
        of: tileFinder,
        matching: find.text(faker.headline),
      );

      expect(tileFinder, findsOneWidget);
      expect(find.text('${faker.seasonMatches}경기'), findsOneWidget);

      final nameText = tester.widget<Text>(nameFinder);
      expect(nameText.maxLines, 1);
      expect(nameText.overflow, TextOverflow.ellipsis);

      final headlineText = tester.widget<Text>(headlineFinder);
      expect(headlineText.maxLines, 2);
      expect(headlineText.overflow, TextOverflow.ellipsis);

      expect(tester.getSize(nameFinder).height, lessThan(32.0));
    });

    testWidgets('calls onTap when the tile is pressed', (tester) async {
      final faker = MockLckData.players.firstWhere(
        (player) => player.id == 'faker',
      );
      var didTap = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerListTile(
              player: faker,
              onTap: () {
                didTap = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PlayerListTile));
      await tester.pump();

      expect(didTap, isTrue);
    });
  });
}
