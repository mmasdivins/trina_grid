import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/manager/event/trina_grid_error_event.dart';

/// Occurs when the it tries to create a cell that does not exist.
class TrinaGridCellNotExistEvent extends TrinaGridErrorEvent {
  /// The column of the cell that does not exists.
  final String column;

  TrinaGridCellNotExistEvent({
    required this.column,
  }) : super();

  @override
  void handler(TrinaGridStateManager stateManager) {}
}