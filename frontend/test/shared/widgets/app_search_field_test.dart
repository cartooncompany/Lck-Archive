import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/app_search_field.dart';

void main() {
  testWidgets('clears focus when tapping outside the search field', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppSearchField(
                hintText: '검색',
                focusNode: focusNode,
                onChanged: (_) {},
              ),
              const Expanded(child: SizedBox.expand()),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();

    expect(focusNode.hasFocus, isTrue);

    await tester.tapAt(const Offset(20, 300));
    await tester.pump();

    expect(focusNode.hasFocus, isFalse);
  });
}
