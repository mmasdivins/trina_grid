import 'package:trina_grid/src/model/trina_column_sorting.dart';
import 'package:trina_grid/trina_grid.dart';

/// Event issued when the sort state of a column is changed.
class TrinaGridChangeColumnSortEvent extends TrinaGridEvent {
  TrinaGridChangeColumnSortEvent({
    required this.column,
    required this.oldSort,
  });

  final TrinaColumn column;

  final TrinaColumnSorting oldSort;

  @override
  void handler(TrinaGridStateManager stateManager) {}
}
