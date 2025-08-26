import 'package:trina_grid/trina_grid.dart';

abstract class IKeyboardState {
  /// Currently pressed key
  TrinaGridKeyPressed get keyPressed;

  /// The index position of the cell to move in that direction in the current cell.
  TrinaGridCellPosition cellPositionToMove(
    TrinaGridCellPosition cellPosition,
    TrinaMoveDirection direction,
  );

  /// Change the current cell to the cell in the [direction] and move the scroll
  /// [force] true : Allow left and right movement with tab key in editing state.
  void moveCurrentCell(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveCurrentCellToEdgeOfColumns(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveCurrentCellToEdgeOfRows(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveCurrentCellByRowIdx(
    int rowIdx,
    TrinaMoveDirection direction, {
    bool notify = true,
  });

  void moveSelectingCell(TrinaMoveDirection direction);

  void moveSelectingCellToEdgeOfColumns(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveSelectingCellToEdgeOfRows(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveSelectingCellByRowIdx(
    int rowIdx,
    TrinaMoveDirection direction, {
    bool notify = true,
  });
}

mixin KeyboardState implements ITrinaGridState {
  final TrinaGridKeyPressed _keyPressed = TrinaGridKeyPressed();

  @override
  TrinaGridKeyPressed get keyPressed => _keyPressed;

  @override
  TrinaGridCellPosition cellPositionToMove(
    TrinaGridCellPosition? cellPosition,
    TrinaMoveDirection direction,
  ) {
    final columnIndexes = columnIndexesByShowFrozen;

    switch (direction) {
      case TrinaMoveDirection.left:
        if (cellPosition!.columnIdx! - 1 < 0) {
          return cellPosition!;
        }
        return TrinaGridCellPosition(
          columnIdx: columnIndexes[cellPosition!.columnIdx! - 1],
          rowIdx: cellPosition.rowIdx,
        );
      case TrinaMoveDirection.right:
        if (cellPosition!.columnIdx! + 1 >= columnIndexes.length) {
          return cellPosition!;
        }
        return TrinaGridCellPosition(
          columnIdx: columnIndexes[cellPosition!.columnIdx! + 1],
          rowIdx: cellPosition.rowIdx,
        );
      case TrinaMoveDirection.up:
        return TrinaGridCellPosition(
          columnIdx: columnIndexes[cellPosition!.columnIdx!],
          rowIdx: cellPosition.rowIdx! - 1,
        );
      case TrinaMoveDirection.down:
        return TrinaGridCellPosition(
          columnIdx: columnIndexes[cellPosition!.columnIdx!],
          rowIdx: cellPosition.rowIdx! + 1,
        );
    }
  }

  @override
  void moveCurrentCell(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) async {
    if (currentCell == null) return;

    // @formatter:off
    if (!force && isEditing && direction.horizontal) {
      // Select type column can be moved left or right even in edit state
      if (currentColumn?.type.isSelect == true) {
      }
      // Date type column can be moved left or right even in edit state
      else if (currentColumn?.type.isDate == true) {
      }
      // Time type column can be moved left or right even in edit state
      else if (currentColumn?.type.isTime == true) {
      }
      // Currency type column can be moved left or right even in edit state
      else if (currentColumn?.type.isCurrency == true) {
      }
      // Read only type column can be moved left or right even in edit state
      else if (currentColumn?.readOnly == true) {
      }
      // Unable to move left and right in other modified states
      else {
        return;
      }
    }
    // @formatter:on

    final cellPosition = currentCellPosition;

    if (cellPosition != null && canNotMoveCell(cellPosition, direction, this as TrinaGridStateManager)) {
      eventManager!.addEvent(
        TrinaGridCannotMoveCurrentCellEvent(
          cellPosition: cellPosition,
          direction: direction,
        ),
      );

      return;
    }

    var index = rows.indexOf(currentCell!.row);

    var isRowDefaultFunction = isRowDefault ?? _isRowDefault;

    bool moveToLeftEdge = false;

    if (mode != TrinaGridMode.readOnly
        && direction.isDown
        && rows.length == (index + 1)) {

      bool isRowDefault = isRowDefaultFunction(currentCell!.row,  this as TrinaGridStateManager, true);

      // If row changed notifiy changed row
      // Put index + 1 so it detects it that we are changing the row
      await notifyTrackingRow(index + 1);

      // Si tenim definit l'event onLastRowKeyDown no fem cas de la configuració
      // lastRowKeyDownAction
      if (onLastRowKeyDown != null){
        onLastRowKeyDown!.call(TrinaGridOnLastRowKeyDownEvent(
          rowIdx: index,
          row: currentCell!.row,
          isRowDefault: isRowDefault,
        ));
      }
      else {
        if (configuration.lastRowKeyDownAction.isAddMultiple) {

          // Afegim una nova fila al final
          insertRows(
            index + 1,
            [getNewRow()],
          );


          moveToLeftEdge = true;
          // moveCurrentCell(direction, force: force);
          // moveCurrentCellToEdgeOfColumns(
          //   TrinaMoveDirection.left,
          //   force: true,
          //   notify: false,
          // );
        }
        else if (configuration.lastRowKeyDownAction.isAddOne){
          if (!isRowDefault){

            // Afegim una nova fila al final
            insertRows(
              index + 1,
              [getNewRow()],
            );
            moveToLeftEdge = true;
            // moveCurrentCell(direction, force: force);
            // moveCurrentCellToEdgeOfColumns(
            //   TrinaMoveDirection.left,
            //   force: true,
            //   notify: false,
            // );
          }
        }
      }
    }
    else if (mode != TrinaGridMode.readOnly
        && direction.isUp
        && rows.length == (index + 1)) {

      var row = rows.elementAt(index);
      bool isRowDefault = isRowDefaultFunction(row, this as TrinaGridStateManager, false);

      // Si tenim definit l'event onLastRowKeyUp no fem cas de la configuració
      // lastRowKeyUpAction
      if (onLastRowKeyUp != null){
        onLastRowKeyUp!.call(TrinaGridOnLastRowKeyUpEvent(
          rowIdx: index,
          row: row,
          isRowDefault: isRowDefault,
        ));
      }
      else {
        if (configuration.lastRowKeyUpAction.isRemoveOne && isRowDefault && rows.length > 1){
          // Esborrem la última fila si s'ha creat i no conté res i hi ha més d'una
          // fila
          removeRows([row]);
        }
      }
    }
    else if (mode != TrinaGridMode.readOnly
        && direction.isUp
        && index == 0) {

      // If row changed notifiy changed row
      // Put -1 so it detects it that we are changing the row
      await notifyTrackingRow(-1);
    }

    final toMove = cellPositionToMove(cellPosition, direction);

    setCurrentCell(
      refRows[toMove.rowIdx!].cells[refColumns[toMove.columnIdx!].field],
      toMove.rowIdx,
      notify: notify,
    );

    if (moveToLeftEdge) {
      moveCurrentCellToEdgeOfColumns(
        TrinaMoveDirection.left,
        force: true,
        notify: false,
      );
    }

    if (direction.horizontal) {
      moveScrollByColumn(direction, cellPosition!.columnIdx);
    } else if (direction.vertical) {
      moveScrollByRow(direction, cellPosition!.rowIdx);
    }

    return;
  }

  bool _isRowDefault(TrinaRow row, TrinaGridStateManager stateManager, bool isInsert){
    for (var element in refColumns) {
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

  @override
  void moveCurrentCellToEdgeOfColumns(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.horizontal) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    if (currentCell == null) {
      return;
    }

    final columnIndexes = columnIndexesByShowFrozen;

    final int columnIdx =
        direction.isLeft ? columnIndexes.first : columnIndexes.last;

    final column = refColumns[columnIdx];

    final cellToMove = currentRow!.cells[column.field];

    setCurrentCell(cellToMove, currentRowIdx, notify: notify);

    if (!showFrozenColumn || column.frozen.isFrozen != true) {
      direction.isLeft
          ? scroll.horizontal!.jumpTo(0)
          : scroll.horizontal!.jumpTo(scroll.maxScrollHorizontal);
    }
  }

  @override
  void moveCurrentCellToEdgeOfRows(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.vertical) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    final field = currentColumnField ?? columns.first.field;

    final int rowIdx = direction.isUp ? 0 : refRows.length - 1;

    final cellToMove = refRows[rowIdx].cells[field];

    setCurrentCell(cellToMove, rowIdx, notify: notify);

    direction.isUp
        ? scroll.vertical!.jumpTo(0)
        : scroll.vertical!.jumpTo(scroll.maxScrollVertical);
  }

  @override
  void moveCurrentCellByRowIdx(
    int rowIdx,
    TrinaMoveDirection direction, {
    bool notify = true,
  }) {
    if (!direction.vertical) {
      return;
    }

    if (rowIdx < 0) {
      rowIdx = 0;
    }

    if (rowIdx > refRows.length - 1) {
      rowIdx = refRows.length - 1;
    }

    final field = currentColumnField ?? refColumns.first.field;

    final cellToMove = refRows[rowIdx].cells[field];

    setCurrentCell(cellToMove, rowIdx, notify: notify);

    moveScrollByRow(direction, rowIdx - direction.offset);
  }

  @override
  void moveSelectingCell(TrinaMoveDirection direction) {
    final TrinaGridCellPosition? cellPosition =
        currentSelectingPosition ?? currentCellPosition;

    if (canNotMoveCell(cellPosition, direction, this as TrinaGridStateManager)) {
      return;
    }

    setCurrentSelectingPosition(
      cellPosition: TrinaGridCellPosition(
        columnIdx: cellPosition!.columnIdx! +
            (direction.horizontal ? direction.offset : 0),
        rowIdx:
            cellPosition.rowIdx! + (direction.vertical ? direction.offset : 0),
      ),
    );

    if (direction.horizontal) {
      moveScrollByColumn(direction, cellPosition.columnIdx);
    } else {
      moveScrollByRow(direction, cellPosition.rowIdx);
    }
  }

  @override
  void moveSelectingCellToEdgeOfColumns(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.horizontal) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    if (currentCell == null) {
      return;
    }

    final int columnIdx = direction.isLeft ? 0 : refColumns.length - 1;

    final int? rowIdx = hasCurrentSelectingPosition
        ? currentSelectingPosition!.rowIdx
        : currentCellPosition!.rowIdx;

    setCurrentSelectingPosition(
      cellPosition: TrinaGridCellPosition(columnIdx: columnIdx, rowIdx: rowIdx),
      notify: notify,
    );

    direction.isLeft
        ? scroll.horizontal!.jumpTo(0)
        : scroll.horizontal!.jumpTo(scroll.maxScrollHorizontal);
  }

  @override
  void moveSelectingCellToEdgeOfRows(
    TrinaMoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.vertical) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    if (currentCell == null) {
      return;
    }

    final columnIdx = hasCurrentSelectingPosition
        ? currentSelectingPosition!.columnIdx
        : currentCellPosition!.columnIdx;

    final int rowIdx = direction.isUp ? 0 : refRows.length - 1;

    setCurrentSelectingPosition(
      cellPosition: TrinaGridCellPosition(columnIdx: columnIdx, rowIdx: rowIdx),
      notify: notify,
    );

    direction.isUp
        ? scroll.vertical!.jumpTo(0)
        : scroll.vertical!.jumpTo(scroll.maxScrollVertical);
  }

  @override
  void moveSelectingCellByRowIdx(
    int rowIdx,
    TrinaMoveDirection direction, {
    bool notify = true,
  }) {
    if (rowIdx < 0) {
      rowIdx = 0;
    }

    if (rowIdx > refRows.length - 1) {
      rowIdx = refRows.length - 1;
    }

    if (currentCell == null) {
      return;
    }

    int? columnIdx = hasCurrentSelectingPosition
        ? currentSelectingPosition!.columnIdx
        : currentCellPosition!.columnIdx;

    setCurrentSelectingPosition(
      cellPosition: TrinaGridCellPosition(columnIdx: columnIdx, rowIdx: rowIdx),
    );

    moveScrollByRow(direction, rowIdx - direction.offset);
  }
}
