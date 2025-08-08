import 'package:flutter/material.dart';
import 'package:trina_grid/src/model/trina_column_sorting.dart';
import 'package:trina_grid/trina_grid.dart';

/// [TrinaGrid.onLoaded] Argument received by registering callback.
class TrinaGridOnLoadedEvent {
  final TrinaGridStateManager stateManager;

  const TrinaGridOnLoadedEvent({required this.stateManager});
}

/// Event called when the value of [TrinaCell] is changed.
///
/// Notice.
/// [columnIdx], [rowIdx] are the values in the current screen state.
/// Values in their current state, not actual data values
/// with filtering, sorting, or pagination applied.
/// This value is from
/// [TrinaGridStateManager.columns] and [TrinaGridStateManager.rows].
///
/// All data is in
/// [TrinaGridStateManager.refColumns.originalList]
/// [TrinaGridStateManager.refRows.originalList]
class TrinaGridOnChangedEvent {
  final int columnIdx;
  final TrinaColumn column;
  final int rowIdx;
  final TrinaRow row;
  final dynamic value;
  final dynamic oldValue;

  const TrinaGridOnChangedEvent({
    required this.columnIdx,
    required this.column,
    required this.rowIdx,
    required this.row,
    this.value,
    this.oldValue,
  });

  @override
  String toString() {
    String out = '[TrinaOnChangedEvent] ';
    out += 'ColumnIndex : $columnIdx, RowIndex : $rowIdx\n';
    out += '::: oldValue : $oldValue\n';
    out += '::: newValue : $value';
    return out;
  }
}

class TrinaGridOnRowChangedEvent {
  final int rowIdx;
  final TrinaRow row;
  final Map<String,dynamic> oldCellValues;

  const TrinaGridOnRowChangedEvent({
    required this.rowIdx,
    required this.row,
    required this.oldCellValues,
  });

  @override
  String toString() {
    String out = '[TrinaGridOnRowChangedEvent] ';
    out += 'RowIndex : $rowIdx\n';
    out += '::: oldCellValues : $oldCellValues\n';
    out += '::: row : $row';
    return out;
  }
}

class TrinaGridOnLastRowKeyDownEvent {
  final int rowIdx;
  final TrinaRow row;
  final bool isRowDefault;

  const TrinaGridOnLastRowKeyDownEvent({
    required this.rowIdx,
    required this.row,
    required this.isRowDefault,
  });

  @override
  String toString() {
    String out = '[TrinaGridOnLastRowKeyDownEvent] ';
    out += 'RowIndex : $rowIdx\n';
    out += '::: isRowDefault : $isRowDefault\n';
    out += '::: row : $row';
    return out;
  }
}

class TrinaGridOnLastRowKeyUpEvent {
  final int rowIdx;
  final TrinaRow row;
  final bool isRowDefault;

  const TrinaGridOnLastRowKeyUpEvent({
    required this.rowIdx,
    required this.row,
    required this.isRowDefault,
  });

  @override
  String toString() {
    String out = '[TrinaGridOnLastRowKeyUpEvent] ';
    out += 'RowIndex : $rowIdx\n';
    out += '::: isRowDefault : $isRowDefault\n';
    out += '::: row : $row';
    return out;
  }
}

class TrinaGridOnRightClickCellEvent {
  final int rowIdx;
  final TrinaRow row;
  final TrinaCell cell;
  final TapDownDetails details;

  const TrinaGridOnRightClickCellEvent({
    required this.rowIdx,
    required this.row,
    required this.cell,
    required this.details,
  });

  @override
  String toString() {
    String out = '[TrinaGridOnRightClickCellEvent] ';
    out += 'RowIndex : $rowIdx\n';
    out += '::: cell : $cell\n';
    out += '::: row : $row';
    out += '::: details : $details';
    return out;
  }
}

class TrinaGridRightClickCellContextMenuEvent {
  final int rowIdx;
  final TrinaRow row;
  final TrinaCell cell;
  final Widget child;

  const TrinaGridRightClickCellContextMenuEvent({
    required this.rowIdx,
    required this.row,
    required this.cell,
    required this.child,
  });

  @override
  String toString() {
    String out = '[TrinaGridRightClickCellContextMenuEvent] ';
    out += 'RowIndex : $rowIdx\n';
    out += '::: cell : $cell\n';
    out += '::: row : $row';
    out += '::: child : $child';
    return out;
  }
}

class TrinaGridOnSelectedCellChangedEvent {
  final TrinaCell? oldCell;
  final TrinaCell cell;

  const TrinaGridOnSelectedCellChangedEvent({
    required this.oldCell,
    required this.cell,
  });

  @override
  String toString() {
    String out = '[TrinaGridOnSelectedCellChangedEvent] ';
    out += 'oldCell : $oldCell\n';
    out += 'cell : $cell\n';
    return out;
  }
}

/// This is the argument value of the [TrinaGrid.onSelected] callback
/// that is called when the [TrinaGrid.mode] value is in select mode.
///
/// If [row], [rowIdx], [cell] is [TrinaGridMode.select] or [TrinaGridMode.selectWithOneTap],
/// Information of the row selected with the tab or enter key.
/// If the Escape key is pressed, these values are null.
///
/// [selectedRows] is valid only in case of [TrinaGridMode.multiSelect].
/// If rows are selected by tab or keyboard, the selected rows are included.
/// If the Escape key is pressed, this value is null.
class TrinaGridOnSelectedEvent {
  final TrinaRow? row;
  final int? rowIdx;
  final TrinaCell? cell;
  final List<TrinaRow>? selectedRows;

  const TrinaGridOnSelectedEvent({
    this.row,
    this.rowIdx,
    this.cell,
    this.selectedRows,
  });

  @override
  String toString() {
    return '[TrinaGridOnSelectedEvent] rowIdx: $rowIdx, selectedRows: ${selectedRows?.length}';
  }
}

/// Argument of [TrinaGrid.onSorted] callback for receiving column sort change event.
class TrinaGridOnSortedEvent {
  final TrinaColumn column;

  final TrinaColumnSorting oldSort;

  const TrinaGridOnSortedEvent({required this.column, required this.oldSort});

  @override
  String toString() {
    return '[TrinaGridOnSortedEvent] ${column.title} (changed: ${column.sort}, old: $oldSort)';
  }
}

/// Argument of [TrinaGrid.onRowChecked] callback to receive row checkbox event.
///
/// [runtimeType] is [TrinaGridOnRowCheckedAllEvent] if [isAll] is true.
/// When [isAll] is true, it means the entire check button event of the column.
///
/// [runtimeType] is [TrinaGridOnRowCheckedOneEvent] if [isRow] is true.
/// If [isRow] is true, it means the check button event of a specific row.
abstract class TrinaGridOnRowCheckedEvent {
  bool get isAll => runtimeType == TrinaGridOnRowCheckedAllEvent;

  bool get isRow => runtimeType == TrinaGridOnRowCheckedOneEvent;

  final TrinaRow? row;
  final int? rowIdx;
  final bool? isChecked;

  const TrinaGridOnRowCheckedEvent({this.row, this.rowIdx, this.isChecked});

  @override
  String toString() {
    String checkMessage = isAll ? 'All rows ' : 'RowIdx $rowIdx ';
    checkMessage += isChecked == true ? 'checked' : 'unchecked';
    return '[TrinaGridOnRowCheckedEvent] $checkMessage';
  }
}

/// Argument of [TrinaGrid.onRowChecked] callback when the checkbox of the row is tapped.
class TrinaGridOnRowCheckedOneEvent extends TrinaGridOnRowCheckedEvent {
  const TrinaGridOnRowCheckedOneEvent({
    required TrinaRow super.row,
    required int super.rowIdx,
    required super.isChecked,
  });
}

/// Argument of [TrinaGrid.onRowChecked] callback when all checkboxes of the column are tapped.
class TrinaGridOnRowCheckedAllEvent extends TrinaGridOnRowCheckedEvent {
  const TrinaGridOnRowCheckedAllEvent({super.isChecked})
      : super(row: null, rowIdx: null);
}

/// The argument of the [TrinaGrid.onRowDoubleTap] callback
/// to receive the event of double-tapping the row.
class TrinaGridOnRowDoubleTapEvent {
  final TrinaRow row;
  final int rowIdx;
  final TrinaCell cell;

  const TrinaGridOnRowDoubleTapEvent({
    required this.row,
    required this.rowIdx,
    required this.cell,
  });
}

/// Argument of the [TrinaGrid.onRowSecondaryTap] callback
/// to receive the event of tapping the row with the right mouse button.
class TrinaGridOnRowSecondaryTapEvent {
  final TrinaRow row;
  final int rowIdx;
  final TrinaCell cell;
  final Offset offset;

  const TrinaGridOnRowSecondaryTapEvent({
    required this.row,
    required this.rowIdx,
    required this.cell,
    required this.offset,
  });
}

/// Argument of the [TrinaGrid.onRowInserted] callback
/// to receive the event when a row is inserted.
class TrinaGridOnRowInsertedEvent {
  final TrinaRow row;
  final int rowIdx;

  const TrinaGridOnRowInsertedEvent({
    required this.row,
    required this.rowIdx,
  });
}

/// Argument of [TrinaGrid.onRowEnter] callback
/// to receive the event of entering the row with the mouse.
class TrinaGridOnRowEnterEvent {
  final TrinaRow? row;
  final int? rowIdx;

  const TrinaGridOnRowEnterEvent({this.row, this.rowIdx});
}

/// Argument of [TrinaGrid.onRowExit] callback
/// to receive the event of exiting the row with the mouse.
class TrinaGridOnRowExitEvent {
  final TrinaRow? row;
  final int? rowIdx;

  const TrinaGridOnRowExitEvent({this.row, this.rowIdx});
}

/// Argument of [TrinaGrid.onRowMoveAccept] callback
/// to receive the rows that we are trying to move and the
/// position where we are trying to drop it
class TrinaGridOnRowMoveAcceptEvent {
  final int idx;
  final List<TrinaRow> rows;

  const TrinaGridOnRowMoveAcceptEvent({required this.idx, required this.rows});
}

/// Argument of [TrinaGrid.onRowsMoved] callback
/// to receive the event of moving the row by dragging it.
class TrinaGridOnRowsMovedEvent {
  final int idx;
  final List<TrinaRow> rows;

  const TrinaGridOnRowsMovedEvent({required this.idx, required this.rows});
}

/// Argument of [TrinaGrid.onColumnTap] callback
/// to move columns by dragging or receive left or right fixed events.
///
/// [TrinaGridStateManager.column].
class TrinaGridOnColumnTapEvent {
  final TrinaColumn column;

  const TrinaGridOnColumnTapEvent({
    required this.column,
  });

  @override
  String toString() {
    String text =
        '[TrinaGridOnColumnTapEvent] idx: $column\n';

    return text;
  }
}

/// Argument of [TrinaGrid.onColumnsMoved] callback
/// to move columns by dragging or receive left or right fixed events.
///
/// [idx] means the actual index of
/// [TrinaGridStateManager.columns] or [TrinaGridStateManager.refColumns].
///
/// [visualIdx] means the order displayed on the screen, not the actual index.
/// For example, if there are 5 columns of [0, 1, 2, 3, 4]
/// If 1 column is frozen to the right, [visualIndex] becomes 4.
/// But the actual index is preserved.
class TrinaGridOnColumnsMovedEvent {
  final int idx;
  final int visualIdx;
  final List<TrinaColumn> columns;

  const TrinaGridOnColumnsMovedEvent({
    required this.idx,
    required this.visualIdx,
    required this.columns,
  });

  @override
  String toString() {
    String text =
        '[TrinaGridOnColumnsMovedEvent] idx: $idx, visualIdx: $visualIdx\n';

    text += columns.map((e) => e.title).join(',');

    return text;
  }
}

/// When the active cell changes this callback is called
class TrinaGridOnActiveCellChangedEvent {
  final int idx;
  final TrinaCell? cell;

  const TrinaGridOnActiveCellChangedEvent({
    required this.idx,
    required this.cell,
  });
}

/// Event triggered when cell validation fails
class TrinaGridValidationEvent {
  final TrinaColumn column;
  final TrinaRow row;
  final int rowIdx;
  final dynamic value;
  final dynamic oldValue;
  final String errorMessage;

  const TrinaGridValidationEvent({
    required this.column,
    required this.row,
    required this.rowIdx,
    required this.value,
    required this.oldValue,
    required this.errorMessage,
  });

  @override
  String toString() {
    String out = '[TrinaGridValidationEvent] ';
    out += 'Column: ${column.title}, RowIndex: $rowIdx\n';
    out += '::: oldValue: $oldValue\n';
    out += '::: newValue: $value\n';
    out += '::: error: $errorMessage';
    return out;
  }
}

/// Event triggered when a lazy pagination fetch operation completes
class TrinaGridOnLazyFetchCompletedEvent {
  /// The associated state manager
  final TrinaGridStateManager stateManager;

  /// The current page number
  final int page;

  /// The total number of pages
  final int totalPage;

  /// The total number of records (if available)
  final int? totalRecords;

  const TrinaGridOnLazyFetchCompletedEvent({
    required this.stateManager,
    required this.page,
    required this.totalPage,
    this.totalRecords,
  });

  @override
  String toString() {
    return '[TrinaGridOnLazyFetchCompletedEvent] page: $page, totalPage: $totalPage, totalRecords: $totalRecords';
  }
}
