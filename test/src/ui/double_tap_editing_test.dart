import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {

  late TrinaGridStateManager stateManager;

  Future<void> buildGrid(WidgetTester tester) async {
    final columns = [
      TrinaColumn(title: 'a', field: 'a', type: TrinaColumnType.text()),
      TrinaColumn(title: 'b', field: 'b', type: TrinaColumnType.text()),
    ];
    final rows = List.generate(
      3,
      (i) => TrinaRow(cells: {
        'a': TrinaCell(value: 'a$i'),
        'b': TrinaCell(value: 'b$i'),
      }),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(children: [
          const TextField(key: Key('outside')),
          SizedBox(
            height: 400,
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onRowDoubleTap: (_) {},
              onLoaded: (e) => stateManager = e.stateManager,
            ),
          ),
        ]),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> fastDoubleClick(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }


  testWidgets('fast double click on a non current cell enters editing',
      (tester) async {
    await buildGrid(tester);

    // The focus is outside the grid.
    await tester.tap(find.byKey(const Key('outside')));
    await tester.pumpAndSettle();
    expect(stateManager.hasFocus, isFalse);

    await fastDoubleClick(tester, find.text('b1'));

    expect(stateManager.currentCell?.value, 'b1');
    expect(stateManager.isEditing, isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('fast double click on another cell of a focused grid',
      (tester) async {
    await buildGrid(tester);

    await tester.tap(find.text('a0'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));

    await fastDoubleClick(tester, find.text('b2'));

    expect(stateManager.currentCell?.value, 'b2');
    expect(stateManager.isEditing, isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}
