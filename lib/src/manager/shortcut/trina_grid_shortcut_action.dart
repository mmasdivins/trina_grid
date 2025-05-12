import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:trina_grid/trina_grid.dart';

/// Define the action by implementing the [execute] method
/// as an action that can be mapped to a shortcut key.
///
/// User-defined behavior other than the default implemented class
/// can be implemented by extending this class.
///
/// [TrinaGridActionMoveCellFocus]
/// {@macro trina_grid_action_move_cell_focus}
///
/// [TrinaGridActionMoveSelectedCellFocus]
/// {@macro trina_grid_action_move_selected_cell_focus}
///
/// [TrinaGridActionMoveCellFocusByPage]
/// {@macro trina_grid_action_move_cell_focus_by_page}
///
/// [TrinaGridActionMoveSelectedCellFocusByPage]
/// {@macro trina_grid_action_move_selected_cell_focus_by_page}
///
/// [TrinaGridActionDefaultTab]
/// {@macro trina_grid_action_default_tab}
///
/// [TrinaGridActionDefaultEnterKey]
/// {@macro trina_grid_action_default_enter_key}
///
/// [TrinaGridActionDefaultEscapeKey]
/// {@macro trina_grid_action_default_escape_key}
///
/// [TrinaGridActionMoveCellFocusToEdge]
/// {@macro trina_grid_action_move_cell_focus_to_edge}
///
/// [TrinaGridActionMoveSelectedCellFocusToEdge]
/// {@macro trina_grid_action_move_selected_cell_focus_to_edge}
///
/// [TrinaGridActionSetEditing]
/// {@macro trina_grid_action_set_editing}
///
/// [TrinaGridActionFocusToColumnFilter]
/// {@macro trina_grid_action_focus_to_column_filter}
///
/// [TrinaGridActionToggleColumnSort]
/// {@macro trina_grid_action_toggle_column_sort}
///
/// [TrinaGridActionCopyValues]
/// {@macro trina_grid_action_copy_values}
///
/// [TrinaGridActionPasteValues]
/// {@macro trina_grid_action_paste_values}
///
/// [TrinaGridActionSelectAll]
/// {@macro trina_grid_action_select_all}
abstract class TrinaGridShortcutAction {
  const TrinaGridShortcutAction();

  /// Implement actions to be mapped to shortcut keys.
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  });
}

/// {@template trina_grid_action_move_cell_focus}
/// Move the current cell focus in the [direction] direction.
///
/// If the current cell is not selected, focus the first cell.
///
/// If [TrinaGridConfiguration.enableMoveHorizontalInEditing] is true,
/// Moves to the previous or next cell when the text cursor reaches the left or right edge
/// while the cell is in edit state.
/// {@endtemplate}
class TrinaGridActionMoveCellFocus extends TrinaGridShortcutAction {
  const TrinaGridActionMoveCellFocus(this.direction);

  final TrinaMoveDirection direction;

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) async {
    bool force = keyEvent.isHorizontal &&
        stateManager.configuration.enableMoveHorizontalInEditing == true;

    if (stateManager.currentCell == null) {
      stateManager.setCurrentCell(stateManager.firstCell, 0);
      return;
    }

    var index = stateManager.rows.indexOf(stateManager.currentCell!.row);

    stateManager.moveCurrentCell(direction, force: force);

    var isRowDefaultFunction = stateManager.isRowDefault ?? _isRowDefault;

    if (stateManager.mode != TrinaGridMode.readOnly
        && direction.isDown
        && stateManager.rows.length == (index + 1)) {

      bool isRowDefault = isRowDefaultFunction(stateManager.currentCell!.row, stateManager);

      // If row changed notifiy changed row
      // Put index + 1 so it detects it that we are changing the row
      await stateManager.notifyTrackingRow(index + 1);

      // Si tenim definit l'event onLastRowKeyDown no fem cas de la configuració
      // lastRowKeyDownAction
      if (stateManager.onLastRowKeyDown != null){
        stateManager.onLastRowKeyDown!.call(TrinaGridOnLastRowKeyDownEvent(
          rowIdx: index,
          row: stateManager.currentCell!.row,
          isRowDefault: isRowDefault,
        ));
      }
      else {
        if (stateManager.configuration.lastRowKeyDownAction.isAddMultiple){
          // Afegim una nova fila al final
          stateManager.insertRows(
            index + 1,
            [stateManager.getNewRow()],
          );
          stateManager.moveCurrentCell(direction, force: force);
        }
        else if (stateManager.configuration.lastRowKeyDownAction.isAddOne){
          if (!isRowDefault){
            // Afegim una nova fila al final
            stateManager.insertRows(
              index + 1,
              [stateManager.getNewRow()],
            );
            stateManager.moveCurrentCell(direction, force: force);
          }
        }
      }
    }
    else if (stateManager.mode != TrinaGridMode.readOnly
        && direction.isUp
        && stateManager.rows.length == (index + 1)) {

      var row = stateManager.rows.elementAt(index);
      bool isRowDefault = isRowDefaultFunction(row, stateManager);

      // Si tenim definit l'event onLastRowKeyUp no fem cas de la configuració
      // lastRowKeyUpAction
      if (stateManager.onLastRowKeyUp != null){
        stateManager.onLastRowKeyUp!.call(TrinaGridOnLastRowKeyUpEvent(
          rowIdx: index,
          row: row,
          isRowDefault: isRowDefault,
        ));
      }
      else {
        if (stateManager.configuration.lastRowKeyUpAction.isRemoveOne && isRowDefault && stateManager.rows.length > 1){
          // Esborrem la última fila si s'ha creat i no conté res i hi ha més d'una
          // fila
          stateManager.removeRows([row]);
        }
      }
    }
    else if (stateManager.mode != TrinaGridMode.readOnly
        && direction.isUp
        && index == 0) {
      // If row changed notifiy changed row
      // Put -1 so it detects it that we are changing the row
      await stateManager.notifyTrackingRow(-1);
    }
  }

  bool _isRowDefault(TrinaRow row, TrinaGridStateManager stateManager){
    for (var element in stateManager.refColumns) {
      var cell = row.cells[element.field]!;

      var value = element.type.defaultValue;
      if (element.type.defaultValue is Function){
        value = element.type.defaultValue.call();
      }

      if (value != cell.value) {
        return false;
      }
    }
    return true;
  }

}

/// {@template trina_grid_action_move_selected_cell_focus}
/// Moves the selected focus in the [direction] direction in the cell or row selection state.
/// {@endtemplate}
class TrinaGridActionMoveSelectedCellFocus extends TrinaGridShortcutAction {
  const TrinaGridActionMoveSelectedCellFocus(this.direction);

  final TrinaMoveDirection direction;

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    if (stateManager.isEditing == true) return;

    stateManager.moveSelectingCell(direction);
  }
}

/// {@template trina_grid_action_move_cell_focus_by_page}
/// Move the focus of the current cell page by page.
///
/// If [direction] is up or down, it moves in the vertical direction on the current page.
///
/// If [direction] is left or right, the page moves when pagination is enabled.
/// If pagination is not enabled, no action is taken.
/// {@endtemplate}
class TrinaGridActionMoveCellFocusByPage extends TrinaGridShortcutAction {
  const TrinaGridActionMoveCellFocusByPage(this.direction);

  final TrinaMoveDirection direction;

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    switch (direction) {
      case TrinaMoveDirection.left:
      case TrinaMoveDirection.right:
        if (!stateManager.isPaginated) return;

        final currentColumn = stateManager.currentColumn;

        final previousPosition = stateManager.currentCellPosition;

        int toPage =
            direction.isLeft ? stateManager.page - 1 : stateManager.page + 1;

        if (toPage < 1) {
          toPage = 1;
        } else if (toPage > stateManager.totalPage) {
          toPage = stateManager.totalPage;
        }

        stateManager.setPage(toPage);

        _restoreCurrentCellPosition(
          stateManager: stateManager,
          currentColumn: currentColumn,
          previousPosition: previousPosition,
        );

        break;
      case TrinaMoveDirection.up:
      case TrinaMoveDirection.down:
        final int moveCount =
            (stateManager.rowContainerHeight / stateManager.rowTotalHeight)
                .floor();

        int rowIdx = stateManager.currentRowIdx!;

        rowIdx += direction.isUp ? -moveCount : moveCount;

        stateManager.moveCurrentCellByRowIdx(rowIdx, direction);

        break;
    }
  }

  void _restoreCurrentCellPosition({
    required TrinaGridStateManager stateManager,
    TrinaColumn? currentColumn,
    TrinaGridCellPosition? previousPosition,
  }) {
    if (currentColumn == null || previousPosition?.hasPosition != true) {
      return;
    }

    int rowIdx = previousPosition!.rowIdx!;

    if (rowIdx > stateManager.refRows.length - 1) {
      rowIdx = stateManager.refRows.length - 1;
    }

    stateManager.setCurrentCell(
      stateManager.refRows.elementAt(rowIdx).cells[currentColumn.field],
      rowIdx,
    );
  }
}

/// {@template trina_grid_action_move_selected_cell_focus_by_page}
/// Moves the selection position page by page in cell or row selection mode.
///
/// When [direction] is left or right, no action is taken.
/// {@endtemplate}
class TrinaGridActionMoveSelectedCellFocusByPage
    extends TrinaGridShortcutAction {
  const TrinaGridActionMoveSelectedCellFocusByPage(this.direction);

  final TrinaMoveDirection direction;

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    if (direction.horizontal) return;

    final int moveCount =
        (stateManager.rowContainerHeight / stateManager.rowTotalHeight).floor();

    int rowIdx = stateManager.currentSelectingPosition?.rowIdx ??
        stateManager.currentCellPosition?.rowIdx ??
        0;

    rowIdx += direction.isUp ? -moveCount : moveCount;

    stateManager.moveSelectingCellByRowIdx(rowIdx, direction);
  }
}

/// {@template trina_grid_action_default_tab}
/// This is the action in which the default action of the tab key is set.
///
/// If there is no currently focused cell, focus the first cell.
///
/// Move the focus to the previous or next cell with the shift key combination.
///
/// If [TrinaGridConfiguration.tabKeyAction] is moveToNextOnEdge ,
/// continue moving focus to the next or previous row when focus reaches the end.
/// {@endtemplate}
class TrinaGridActionDefaultTab extends TrinaGridShortcutAction {
  const TrinaGridActionDefaultTab();

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    if (stateManager.currentCell == null) {
      stateManager.setCurrentCell(stateManager.firstCell, 0);
      return;
    }

    final saveIsEditing = stateManager.isEditing;

    keyEvent.isShiftPressed
        ? _moveCellPrevious(stateManager)
        : _moveCellNext(stateManager);

    stateManager.setEditing(stateManager.autoEditing || saveIsEditing);
  }

  void _moveCellPrevious(TrinaGridStateManager stateManager) {
    if (_willMoveToPreviousRow(
        stateManager.currentCellPosition, stateManager)) {
      _moveCellToPreviousRow(stateManager);
    } else {
      stateManager.moveCurrentCell(TrinaMoveDirection.left, force: true);
    }
  }

  void _moveCellNext(TrinaGridStateManager stateManager) {
    if (_willMoveToNextRow(stateManager.currentCellPosition, stateManager)) {
      _moveCellToNextRow(stateManager);
    } else {
      stateManager.moveCurrentCell(TrinaMoveDirection.right, force: true);
    }
  }

  bool _willMoveToPreviousRow(
    TrinaGridCellPosition? position,
    TrinaGridStateManager stateManager,
  ) {
    if (!stateManager.configuration.tabKeyAction.isMoveToNextOnEdge ||
        position == null ||
        !position.hasPosition) {
      return false;
    }

    return position.rowIdx! > 0 && position.columnIdx == 0;
  }

  bool _willMoveToNextRow(
    TrinaGridCellPosition? position,
    TrinaGridStateManager stateManager,
  ) {
    if (!stateManager.configuration.tabKeyAction.isMoveToNextOnEdge ||
        position == null ||
        !position.hasPosition) {
      return false;
    }

    return position.rowIdx! < stateManager.refRows.length - 1 &&
        position.columnIdx == stateManager.refColumns.length - 1;
  }

  void _moveCellToPreviousRow(TrinaGridStateManager stateManager) {
    stateManager.moveCurrentCell(
      TrinaMoveDirection.up,
      force: true,
      notify: false,
    );

    stateManager.moveCurrentCellToEdgeOfColumns(
      TrinaMoveDirection.right,
      force: true,
    );
  }

  void _moveCellToNextRow(TrinaGridStateManager stateManager) {
    stateManager.moveCurrentCell(
      TrinaMoveDirection.down,
      force: true,
      notify: false,
    );

    stateManager.moveCurrentCellToEdgeOfColumns(
      TrinaMoveDirection.left,
      force: true,
    );
  }
}

/// {@template trina_grid_action_default_enter_key}
/// This action is the default action of the Enter key.
///
/// If [TrinaGrid.mode] is in selection mode,
/// the [TrinaGrid.onSelected] callback that returns information
/// of the currently selected row is called.
///
/// Otherwise, it behaves according to [TrinaGridConfiguration.enterKeyAction].
/// {@endtemplate}
class TrinaGridActionDefaultEnterKey extends TrinaGridShortcutAction {
  const TrinaGridActionDefaultEnterKey();

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    // In SelectRow mode, the current Row is passed to the onSelected callback.
    if (stateManager.mode.isSelectMode && stateManager.onSelected != null) {
      stateManager.onSelected!(TrinaGridOnSelectedEvent(
        row: stateManager.currentRow,
        rowIdx: stateManager.currentRowIdx,
        cell: stateManager.currentCell,
        selectedRows: (stateManager.mode.isMultiSelectMode || stateManager.mode.isMultiSelectAlwaysOne)
            ? stateManager.currentSelectingRows
            : null,
      ));
      return;
    }

    if (stateManager.configuration.enterKeyAction.isNone) {
      return;
    }

    if (!stateManager.isEditing && _isExpandableCell(stateManager)) {
      stateManager.toggleExpandedRowGroup(rowGroup: stateManager.currentRow!);
      return;
    }

    if (stateManager.configuration.enterKeyAction.isToggleEditing) {
      stateManager.toggleEditing(notify: false);
    }  else {

      bool isReadOnly = false;
      if (stateManager.currentColumn != null && stateManager.currentRow != null && stateManager.currentCell != null) {
        isReadOnly = stateManager.currentColumn!.checkReadOnly(stateManager.currentRow!, stateManager.currentCell!);
      }

      if (stateManager.isEditing == true ||
          stateManager.currentColumn?.enableEditingMode?.call(stateManager.currentCell) == false ||
          isReadOnly == true
      ) {

        bool saveIsEditing = stateManager.isEditing;

        // Si la següent cel·la no és editable hem de canviar l'estat
        // isEditing a false
        var position = _getNextPosition(keyEvent, stateManager);
        if (position != null && position.rowIdx != null && position.columnIdx != null) {
          var nextCell = stateManager.refRows[position.rowIdx!].cells[stateManager.refColumns[position.columnIdx!].field];
          if (nextCell != null) {
            bool isReadOnly = nextCell.column.checkReadOnly(stateManager.refRows[position.rowIdx!], nextCell);
            saveIsEditing = isReadOnly ? false : saveIsEditing;
          }
        }

        _moveCell(keyEvent, stateManager);

        stateManager.setEditing(saveIsEditing, notify: false);

        if (saveIsEditing) {

          // On change editing after enter, select all text in cell
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (stateManager.textEditingController != null) {
              stateManager.textEditingController!.selection = TextSelection(baseOffset: 0, extentOffset: stateManager.textEditingController!.value.text.length);
            }
          });
        }
      } else {
        stateManager.toggleEditing(notify: false);
        // On change editing after enter, select all text in cell
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (stateManager.textEditingController != null) {
            stateManager.textEditingController!.selection = TextSelection(baseOffset: 0, extentOffset: stateManager.textEditingController!.value.text.length);
          }
        });

      }
    }

    if (stateManager.autoEditing) {
      stateManager.setEditing(true, notify: false);
    }

    stateManager.notifyListeners();
  }

  bool _isExpandableCell(TrinaGridStateManager stateManager) {
    return stateManager.currentCell != null &&
        stateManager.enabledRowGroups &&
        stateManager.rowGroupDelegate
                ?.isExpandableCell(stateManager.currentCell!) ==
            true;
  }

  void _moveCell(
    TrinaKeyManagerEvent keyEvent,
    TrinaGridStateManager stateManager,
  ) {
    final enterKeyAction = stateManager.configuration.enterKeyAction;

    if (enterKeyAction.isNone) {
      return;
    }

    if (enterKeyAction.isEditingAndMoveDown) {
      if (keyEvent.isShiftPressed) {
        stateManager.moveCurrentCell(
          TrinaMoveDirection.up,
          notify: false,
        );
      } else {
        stateManager.moveCurrentCell(
          TrinaMoveDirection.down,
          notify: false,
        );
      }
    } else if (enterKeyAction.isEditingAndMoveRight) {
      if (keyEvent.isShiftPressed) {
        stateManager.moveCurrentCell(
          TrinaMoveDirection.left,
          force: true,
          notify: false,
        );
      } else {
        stateManager.moveCurrentCell(
          TrinaMoveDirection.right,
          force: true,
          notify: false,
        );
      }
    }
  }

  TrinaGridCellPosition? _getNextPosition(
      TrinaKeyManagerEvent keyEvent,
      TrinaGridStateManager stateManager,
      ) {
    final enterKeyAction = stateManager.configuration.enterKeyAction;

    if (enterKeyAction.isNone) {
      return null;
    }

    if (enterKeyAction.isEditingAndMoveDown) {
      if (keyEvent.isShiftPressed) {
        return stateManager.cellPositionToMove(
          stateManager.currentCellPosition,
          TrinaMoveDirection.up,
        );

      } else {
        return stateManager.cellPositionToMove(
          stateManager.currentCellPosition,
          TrinaMoveDirection.down,
        );
      }
    }
    else if (enterKeyAction.isEditingAndMoveRight) {
      if (keyEvent.isShiftPressed) {
        return stateManager.cellPositionToMove(
          stateManager.currentCellPosition,
          TrinaMoveDirection.left,
        );
      } else {
        return stateManager.cellPositionToMove(
          stateManager.currentCellPosition,
          TrinaMoveDirection.right,
        );
      }
    }
    return null;
  }

}

/// {@template trina_grid_action_default_escape_key}
/// This is the action in which the default behavior of the Escape key is set.
///
/// If [TrinaGridMode] is in selection or popup mode,
/// call the [TrinaGrid.onSelected] callback,
/// which returns a [TrinaGridOnSelectedEvent] with a null value meaning unselected.
///
/// In other cases, it cancels the currently edited cell.
/// {@endtemplate}
class TrinaGridActionDefaultEscapeKey extends TrinaGridShortcutAction {
  const TrinaGridActionDefaultEscapeKey();

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    if (stateManager.mode.isSelectMode ||
        (stateManager.mode.isPopup && !stateManager.isEditing)) {
      if (stateManager.onSelected != null) {
        stateManager.clearCurrentSelecting();
        stateManager.onSelected!(const TrinaGridOnSelectedEvent());
      }
      return;
    }

    if (stateManager.isEditing) {
      stateManager.setEditing(false);
    }
  }
}

/// {@template trina_grid_action_move_cell_focus_to_edge}
/// Move the focus of the current cell to the end of the [direction] direction.
/// {@endtemplate}
class TrinaGridActionMoveCellFocusToEdge extends TrinaGridShortcutAction {
  const TrinaGridActionMoveCellFocusToEdge(this.direction);

  final TrinaMoveDirection direction;

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    switch (direction) {
      case TrinaMoveDirection.left:
      case TrinaMoveDirection.right:
        stateManager.moveCurrentCellToEdgeOfColumns(direction);
        break;
      case TrinaMoveDirection.up:
      case TrinaMoveDirection.down:
        stateManager.moveCurrentCellToEdgeOfRows(direction);
        break;
    }
  }
}

/// {@template trina_grid_action_move_selected_cell_focus_to_edge}
/// Moves the selected focus to the end of the [direction] direction
/// in the cell or row selection state.
/// {@endtemplate}
class TrinaGridActionMoveSelectedCellFocusToEdge
    extends TrinaGridShortcutAction {
  const TrinaGridActionMoveSelectedCellFocusToEdge(this.direction);

  final TrinaMoveDirection direction;

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    switch (direction) {
      case TrinaMoveDirection.left:
      case TrinaMoveDirection.right:
        stateManager.moveSelectingCellToEdgeOfColumns(direction);
        break;
      case TrinaMoveDirection.up:
      case TrinaMoveDirection.down:
        stateManager.moveSelectingCellToEdgeOfRows(direction);
        break;
    }
  }
}

/// {@template trina_grid_action_set_editing}
/// Set the current cell to edit state.
/// {@endtemplate}
class TrinaGridActionSetEditing extends TrinaGridShortcutAction {
  const TrinaGridActionSetEditing();

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    if (stateManager.isEditing) return;

    stateManager.setEditing(true);
  }
}

/// {@template trina_grid_action_focus_to_column_filter}
/// Move the focus from the current cell position
/// to the filtering TextField of the corresponding column.
/// {@endtemplate}
class TrinaGridActionFocusToColumnFilter extends TrinaGridShortcutAction {
  const TrinaGridActionFocusToColumnFilter();

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    final currentColumn = stateManager.currentColumn;

    if (currentColumn == null) return;

    if (!stateManager.showColumnFilter) return;

    if (currentColumn.filterFocusNode?.canRequestFocus == true) {
      currentColumn.filterFocusNode?.requestFocus();

      stateManager.setKeepFocus(false);
    }
  }
}

/// {@template trina_grid_action_toggle_column_sort}
/// Toggles the sort state of the column.
/// {@endtemplate}
class TrinaGridActionToggleColumnSort extends TrinaGridShortcutAction {
  const TrinaGridActionToggleColumnSort();

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    final currentColumn = stateManager.currentColumn;

    if (currentColumn == null || !currentColumn.enableSorting) return;

    final previousPosition = stateManager.currentCellPosition;

    stateManager.toggleSortColumn(currentColumn);

    _restoreCurrentCellPosition(
      stateManager: stateManager,
      currentColumn: currentColumn,
      previousPosition: previousPosition,
      ignore: stateManager.sortOnlyEvent,
    );
  }

  void _restoreCurrentCellPosition({
    required TrinaGridStateManager stateManager,
    TrinaColumn? currentColumn,
    TrinaGridCellPosition? previousPosition,
    bool ignore = false,
  }) {
    if (ignore ||
        currentColumn == null ||
        previousPosition?.hasPosition != true) {
      return;
    }

    int rowIdx = previousPosition!.rowIdx!;

    if (rowIdx > stateManager.refRows.length - 1) {
      rowIdx = stateManager.refRows.length - 1;
    }

    stateManager.setCurrentCell(
      stateManager.refRows.elementAt(rowIdx).cells[currentColumn.field],
      rowIdx,
    );
  }
}

/// {@template trina_grid_action_copy_values}
/// Copies the value of the current cell or the selected cell or row to the clipboard.
/// {@endtemplate}
class TrinaGridActionCopyValues extends TrinaGridShortcutAction {
  const TrinaGridActionCopyValues();

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    if (stateManager.isEditing == true) {
      return;
    }

    Clipboard.setData(ClipboardData(text: stateManager.currentSelectingText));
  }
}

/// {@template trina_grid_action_paste_values}
/// Pastes the copied values to the clipboard
/// depending on the position of the current cell or row.
/// {@endtemplate}
class TrinaGridActionPasteValues extends TrinaGridShortcutAction {
  const TrinaGridActionPasteValues();

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    if (stateManager.currentCell == null) {
      return;
    }

    if (stateManager.isEditing == true) {
      return;
    }

    Clipboard.getData('text/plain').then((value) {
      if (value == null) {
        return;
      }
      List<List<String>> textList =
          TrinaClipboardTransformation.stringToList(value.text!);

      stateManager.pasteCellValue(textList);
    });
  }
}

/// {@template trina_grid_action_select_all}
/// Select all cells or rows.
/// {@endtemplate}
class TrinaGridActionSelectAll extends TrinaGridShortcutAction {
  const TrinaGridActionSelectAll();

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {
    if (stateManager.isEditing == true) {
      return;
    }

    stateManager.setAllCurrentSelecting();
  }
}

/// {@template trina_grid_action_delete}
/// Delete selected row.
/// {@endtemplate}
class TrinaGridActionDelete extends TrinaGridShortcutAction {
  const TrinaGridActionDelete();

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {

    if (stateManager.isEditing == true
        || stateManager.mode == TrinaGridMode.readOnly
        || stateManager.currentCell == null
        || stateManager.onDeleteRowEvent == null) {
      return;
    }

    var row = stateManager.currentCell!.row;

    stateManager.onDeleteRowEvent!.call(row, stateManager);
  }
}

/// {@template trina_grid_action_insert}
/// Inserts a default row.
/// {@endtemplate}
class TrinaGridActionInsert extends TrinaGridShortcutAction {
  const TrinaGridActionInsert();

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {

    if (stateManager.isEditing == true
        || stateManager.showLoading
        // || stateManager.mode == PlutoGridMode.readOnly
        || !stateManager.mode.isEditableMode
        || stateManager.currentCellPosition == null
        || stateManager.currentCellPosition?.rowIdx == null) {
      return;
    }

    int rowIdx = stateManager.currentCellPosition!.rowIdx!;
    stateManager.insertRows(
        rowIdx,
        [stateManager.getNewRow()]
    );

    var newRow = stateManager.refRows[rowIdx];
    // Anem a la fila que hem creat
    var firstVisibleCol = stateManager.columns.firstWhereOrNull((element) => !element.hide);
    if (firstVisibleCol != null){
      var cell = newRow.cells[firstVisibleCol.field];
      stateManager.setCurrentCell(
        cell,
        rowIdx,
        notify: true,
      );
    }


  }
}

/// {@template trina_grid_action_search}
/// Search a string.
/// {@endtemplate}
class TrinaGridActionSearch extends TrinaGridShortcutAction {
  const TrinaGridActionSearch();

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {

    if (stateManager.isEditing == true
        || stateManager.showLoading
    /*|| stateManager.mode == PlutoGridMode.readOnly
        || stateManager.currentCellPosition == null
        || stateManager.currentCellPosition?.rowIdx == null*/) {
      return;
    }

    if (stateManager.onSearchCallback != null) {
      stateManager.onSearchCallback!.call(stateManager);
    }

  }
}

/// {@template trina_grid_action_search_next}
/// Search a string.
/// {@endtemplate}
class TrinaGridActionSearchNext extends TrinaGridShortcutAction {
  const TrinaGridActionSearchNext();

  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) {

    if (stateManager.isEditing == true
        || stateManager.showLoading
    /*|| stateManager.mode == PlutoGridMode.readOnly
        || stateManager.currentCellPosition == null
        || stateManager.currentCellPosition?.rowIdx == null*/) {
      return;
    }

    stateManager.searchNext(notify: true);

  }
}