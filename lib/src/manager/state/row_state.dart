import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class RowEditingState {
  int? indexRow;
  Map<String, dynamic>? cellValues;
  TrinaRow? newRow;
  bool semaphor = false;
}

abstract class IRowState {
  List<TrinaRow> get rows;

  RowEditingState get rowEditingState;

  /// [refRows] is a List&lt;TrinaRow&gt; type and holds the entire row data.
  ///
  /// [refRows] returns a list of final results
  /// according to pagination and filtering status.
  /// If the total number of rows is 100 and paginated in size 10,
  /// [refRows] returns a list of 10 of the current page.
  ///
  /// [refRows.originalList] to get the entire row data with pagination or filtering.
  ///
  /// A list with pagination and filtering applied and pagination not applied
  /// can be obtained with [refRows.filterOrOriginalList].
  ///
  /// Directly accessing [refRows] to process insert, remove, etc. may cause unexpected behavior.
  /// It is preferable to use the methods
  /// such as insertRows and removeRows of the built-in [TrinaGridStateManager] to handle it.
  FilteredList<TrinaRow> get refRows;

  List<TrinaRow> get checkedRows;

  List<TrinaRow> get checkedRowsViaSelect;

  List<TrinaRow> get unCheckedRows;

  bool get hasCheckedRow;

  bool get hasUnCheckedRow;

  /// Property for [tristate] value in [Checkbox] widget.
  bool? get tristateCheckedRow;

  /// Row index of currently selected cell.
  int? get currentRowIdx;

  /// Row of currently selected cell.
  TrinaRow? get currentRow;

  /// {@template trina_grid_row_wrapper}
  ///
  /// A wrapper that wraps arround each row.
  ///
  /// {@endtemplate}
  RowWrapper? get rowWrapper;

  TrinaRowColorCallback? get rowColorCallback;

  int? getRowIdxByOffset(double offset);

  TrinaRow? getRowByIdx(int rowIdx);

  TrinaRow getNewRow();

  List<TrinaRow> getNewRows({
    int count = 1,
  });

  void setRowChecked(
    TrinaRow row,
    bool flag, {
    bool notify = true,
  });

  void insertRows(
    int rowIdx,
    List<TrinaRow> rows, {
    bool notify = true,
  });

  void prependNewRows({
    int count = 1,
  });

  void prependRows(List<TrinaRow> rows);

  void appendNewRows({
    int count = 1,
  });

  void appendRows(List<TrinaRow> rows);

  void removeCurrentRow();

  void removeRows(List<TrinaRow> rows);

  void removeAllRows({bool notify = true});

  void moveRowsByOffset(
    List<TrinaRow> rows,
    double offset, {
    bool notify = true,
  });

  void moveRowsByIndex(
    List<TrinaRow> rows,
    int index, {
    bool notify = true,
  });

  void toggleAllRowChecked(
    bool flag, {
    bool notify = true,
  });


  void resetRowEditingState();

  void trackRowCell(int idxRow, TrinaRow row);

  Future notifyTrackingRow(int idxRow);
}

mixin RowState implements ITrinaGridState {
  @override
  List<TrinaRow> get rows => [...refRows];

  RowEditingState _rowEditingState = RowEditingState();

  @override
  RowEditingState get rowEditingState => _rowEditingState;

  @override
  List<TrinaRow> get checkedRows => refRows.where((row) => row.checked!).toList(
        growable: false,
      );

  @override
  List<TrinaRow> get checkedRowsViaSelect =>
      checkedRows.where((row) => row.checkedViaSelect).toList(growable: false);

  @override
  List<TrinaRow> get unCheckedRows =>
      refRows.where((row) => !row.checked!).toList(
            growable: false,
          );

  @override
  bool get hasCheckedRow =>
      refRows.firstWhereOrNull((element) => element.checked!) != null;

  @override
  bool get hasUnCheckedRow =>
      refRows.firstWhereOrNull((element) => !element.checked!) != null;

  @override
  bool? get tristateCheckedRow {
    final length = refRows.length;

    if (length == 0) return false;

    int countTrue = 0;

    int countFalse = 0;

    int lengthCheckableRows = 0;
    for (var i = 0; i < length; i += 1) {
      var row = refRows[i];
      var checked =  row.checked == true;

      bool enabledCheckedRow = enableCheckSelection?.call(row) ?? true;

      if (enabledCheckedRow) {
        checked ? ++countTrue : ++countFalse;
        ++lengthCheckableRows;
      }

      if (countTrue > 0 && countFalse > 0) return null;
    }

    return (countTrue == lengthCheckableRows) && (countTrue > 0);
  }

  @override
  int? get currentRowIdx => currentCellPosition?.rowIdx;

  @override
  TrinaRow? get currentRow {
    if (currentRowIdx == null) {
      return null;
    }

    return refRows[currentRowIdx!];
  }

  @override
  int? getRowIdxByOffset(double offset) {
    offset -= bodyTopOffset - scroll.verticalOffset;

    double currentOffset = 0.0;

    int? indexToMove;

    final int rowsLength = refRows.length;

    for (var i = 0; i < rowsLength; i += 1) {
      if (currentOffset <= offset && offset < currentOffset + rowTotalHeight) {
        indexToMove = i;
        break;
      }

      currentOffset += rowTotalHeight;
    }

    return indexToMove;
  }

  @override
  TrinaRow? getRowByIdx(int? rowIdx) {
    if (rowIdx == null || rowIdx < 0 || refRows.length - 1 < rowIdx) {
      return null;
    }

    return refRows[rowIdx];
  }

  @override
  TrinaRow getNewRow() {
    final cells = <String, TrinaCell>{};

    for (var column in refColumns.originalList) {
      var value = column.type.defaultValue;
      if (value is Function){
        value = column.type.defaultValue.call();
      }

      cells[column.field] = TrinaCell(
        value: value,
      );
    }

    return TrinaRow(cells: cells);
  }

  @override
  List<TrinaRow> getNewRows({
    int count = 1,
  }) {
    List<TrinaRow> rows = [];

    for (var i = 0; i < count; i += 1) {
      rows.add(getNewRow());
    }

    if (rows.isEmpty) {
      return [];
    }

    return rows;
  }

  @override
  void setRowChecked(
    TrinaRow row,
    bool flag, {
    bool notify = true,
    bool checkedViaSelect = false,
  }) {
    final findRow = refRows.firstWhereOrNull(
      (element) => element.key == row.key,
    );

    if (findRow == null) {
      return;
    }

    findRow.setChecked(flag, viaSelect: checkedViaSelect);

    notifyListeners(notify, setRowChecked.hashCode);
  }

  @override
  void insertRows(
    int rowIdx,
    List<TrinaRow> rows, {
    bool notify = true,
  }) {
    _insertRows(rowIdx, rows);

    /// Update currentRowIdx
    if (currentCell != null) {
      updateCurrentCellPosition(notify: false);

      // todo : whether to apply scrolling.
    }

    /// Update currentSelectingPosition
    if (currentSelectingPosition != null &&
        rowIdx <= currentSelectingPosition!.rowIdx!) {
      setCurrentSelectingPosition(
        cellPosition: TrinaGridCellPosition(
          columnIdx: currentSelectingPosition!.columnIdx,
          rowIdx: rows.length + currentSelectingPosition!.rowIdx!,
        ),
        notify: false,
      );
    }

    notifyListeners(notify, insertRows.hashCode);
  }

  @override
  void prependNewRows({
    int count = 1,
  }) {
    prependRows(getNewRows(count: count));
  }

  @override
  void prependRows(List<TrinaRow> rows) {
    _insertRows(0, rows);

    /// Update currentRowIdx
    if (currentCell != null) {
      setCurrentCellPosition(
        TrinaGridCellPosition(
          columnIdx: currentCellPosition!.columnIdx,
          rowIdx: rows.length + currentRowIdx!,
        ),
        notify: false,
      );

      double offsetToMove = rows.length * rowTotalHeight;

      scrollByDirection(TrinaMoveDirection.up, offsetToMove);
    }

    /// Update currentSelectingPosition
    if (currentSelectingPosition != null) {
      setCurrentSelectingPosition(
        cellPosition: TrinaGridCellPosition(
          columnIdx: currentSelectingPosition!.columnIdx,
          rowIdx: rows.length + currentSelectingPosition!.rowIdx!,
        ),
        notify: false,
      );
    }

    notifyListeners(true, prependRows.hashCode);
  }

  @override
  void appendNewRows({
    int count = 1,
  }) {
    appendRows(getNewRows(count: count));
  }

  @override
  void appendRows(List<TrinaRow> rows) {
    _insertRows(refRows.length, rows);

    notifyListeners(true, appendRows.hashCode);
  }

  @override
  void removeCurrentRow() {
    if (currentRowIdx == null) {
      return;
    }

    if (enabledRowGroups) {
      removeRowAndGroupByKey([currentRow!.key]);
    } else {
      refRows.removeAt(currentRowIdx!);
    }

    // Si esborrem la fila que teniem tracking,
    // reiniciem l'estat
    if (_rowEditingState.indexRow == currentRowIdx){
      _rowEditingState = RowEditingState();
    }

    resetCurrentState(notify: false);

    notifyListeners(true, removeCurrentRow.hashCode);
  }

  @override
  void removeRows(
    List<TrinaRow> rows, {
    bool notify = true,
  }) {
    if (showLoading) {
      return;
    }

    if (rows.isEmpty) {
      return;
    }

    final Set<Key> removeKeys = Set.from(rows.map((e) => e.key));

    if (currentRowIdx != null &&
        refRows.length > currentRowIdx! &&
        removeKeys.contains(refRows[currentRowIdx!].key)) {
      resetCurrentState(notify: false);
    }

    Key? selectingCellKey;

    if (hasCurrentSelectingPosition) {
      selectingCellKey = refRows
          .originalList[currentSelectingPosition!.rowIdx!].cells.entries
          .elementAt(currentSelectingPosition!.columnIdx!)
          .value
          .key;
    }

    if (enabledRowGroups) {
      removeRowAndGroupByKey(removeKeys);
    } else {
      refRows.removeWhereFromOriginal((row) => removeKeys.contains(row.key));
    }

    // Si esborrem la fila que teniem tracking,
    // reiniciem l'estat
    if (rows.contains(_rowEditingState.newRow)){
      _rowEditingState = RowEditingState();
    }

    updateCurrentCellPosition(notify: false);

    setCurrentSelectingPositionByCellKey(selectingCellKey, notify: false);

    currentSelectingRows.removeWhere((row) => removeKeys.contains(row.key));

    notifyListeners(notify, removeRows.hashCode);
  }

  @override
  void removeAllRows({bool notify = true}) {
    if (refRows.originalList.isEmpty) {
      return;
    }

    refRows.clearFromOriginal();

    _rowEditingState = RowEditingState();

    resetCurrentState(notify: false);

    notifyListeners(notify, removeAllRows.hashCode);
  }

  @override
  void moveRowsByOffset(
    List<TrinaRow> rows,
    double offset, {
    bool notify = true,
  }) {
    int? indexToMove = getRowIdxByOffset(offset);

    moveRowsByIndex(rows, indexToMove, notify: notify);
  }

  @override
  void moveRowsByIndex(
    List<TrinaRow> rows,
    int? indexToMove, {
    bool notify = true,
  }) {
    if (rows.isEmpty || indexToMove == null) {
      return;
    }

    if (indexToMove + rows.length > refRows.length) {
      indexToMove = refRows.length - rows.length;
    }

    if (isPaginated &&
        page > 1 &&
        indexToMove + pageRangeFrom > refRows.originalLength - 1) {
      indexToMove = refRows.originalLength - 1;
    }

    final Set<Key> removeKeys = Set.from(rows.map((e) => e.key));

    refRows.removeWhereFromOriginal((e) => removeKeys.contains(e.key));

    refRows.insertAll(indexToMove, rows);

    int sortIdx = 0;

    for (var element in refRows.originalList) {
      element.sortIdx = sortIdx++;
    }

    updateCurrentCellPosition(notify: false);

    if (onRowsMoved != null) {
      onRowsMoved!(TrinaGridOnRowsMovedEvent(
        idx: indexToMove,
        rows: rows,
      ));
    }

    notifyListeners(notify, moveRowsByIndex.hashCode);
  }

  @override
  void toggleAllRowChecked(
    bool? flag, {
    bool notify = true,
  }) {
    for (final row in iterateRowAndGroup) {
      if (enableCheckSelection?.call(row) ?? true) {
        row.setChecked(flag == true);
      }
    }

    notifyListeners(notify, toggleAllRowChecked.hashCode);
  }

  void _insertRows(int index, List<TrinaRow> rows) {
    if (rows.isEmpty) {
      return;
    }

    int safetyIndex = _getSafetyIndexForInsert(index);

    if (enabledRowGroups) {
      insertRowGroup(safetyIndex, rows);
    } else {
      final bool append = refRows.isNotEmpty && index >= refRows.length;
      final targetIdx = append ? refRows.length - 1 : safetyIndex;
      final target = refRows.isEmpty ? null : refRows[targetIdx];
      int sortIdx = target?.sortIdx ?? 0;
      if (append) ++sortIdx;

      _setSortIdx(rows: rows, start: sortIdx);

      if (hasSortedColumn) {
        _increaseSortIdxGreaterThanOrEqual(
          rows: refRows.originalList,
          compare: sortIdx,
          increase: rows.length,
        );
      } else if (!append) {
        _increaseSortIdx(
          rows: refRows.originalList,
          start: target == null ? 0 : refRows.originalList.indexOf(target),
          increase: rows.length,
        );
      }

      for (final row in rows) {
        if (isRowDefault?.call(row, this as TrinaGridStateManager, true) ?? false) {
          row.setState(TrinaRowState.added);
        }
        else {
          row.setState(TrinaRowState.none);
        }
      }

      bool wasEmpty = refRows.isEmpty;
      refRows.insertAll(safetyIndex, rows);

      if (onRowInserted != null) {
        for(final row in rows) {
          if (row.state.isAdded) {
            onRowInserted!(
              TrinaGridOnRowInsertedEvent(
                row: row,
                rowIdx: safetyIndex,
              ),
            );
          }
        }
      }

      // Initialize the original list without the filter
      TrinaGridStateManager.initializeRows(
        refColumns.originalList,
        rows,
        eventManager,
        forceApplySortIdx: false,
      );

      // If the rows were empty on initializing new rows we set
      // the first cell as focused
      if (wasEmpty){
        setCurrentCell(firstCell, 0);
        if (configuration.focusFirstCellOnRowsLoaded) {
          gridFocusNode.requestFocus();
        }
      }

    }

    if (isPaginated) {
      resetPage(notify: false);
    }
  }

  int _getSafetyIndexForInsert(int index) {
    if (index < 0) {
      return 0;
    }

    if (index > refRows.length) {
      return refRows.length;
    }

    return index;
  }

  void _setSortIdx({
    required List<TrinaRow> rows,
    int start = 0,
  }) {
    for (final row in rows) {
      row.sortIdx = start++;
    }
  }

  void _increaseSortIdx({
    required List<TrinaRow> rows,
    int start = 0,
    int increase = 1,
  }) {
    final length = rows.length;

    for (int i = start; i < length; i += 1) {
      rows[i].sortIdx += increase;
    }
  }

  void _increaseSortIdxGreaterThanOrEqual({
    required List<TrinaRow> rows,
    int compare = 0,
    int increase = 1,
  }) {
    for (final row in rows) {
      if (row.sortIdx < compare) {
        continue;
      }

      row.sortIdx += increase;
    }
  }

  @override
  void trackRowCell(int idxRow, TrinaRow row){
    if (_rowEditingState.cellValues == null){
      Map<String,dynamic> cellValues = <String,dynamic>{};
      row.cells.forEach((key, cell) {
        cellValues[key] = cell.value;
      });
      _rowEditingState.cellValues = cellValues;
    }

    if (idxRow >= 0 && refRows.length >= idxRow){
      _rowEditingState.indexRow ??= idxRow;
      _rowEditingState.newRow ??= refRows[idxRow];
    }
  }

  void setRowEditingState(RowEditingState rowEditingState) {
    _rowEditingState = rowEditingState;
  }

  @override
  Future notifyTrackingRow(int idxRow) async {

    // If semaphor don't notify
    if (_rowEditingState.semaphor) {
      return;
    }


    if (_rowEditingState.indexRow != null && _rowEditingState.indexRow != idxRow){

      // Primer comprovem si s'ha canviat alguna cel·la
      // o si és una fila per defecte i tenim la configuració d'afegir múltiples files
      bool isRowDefaultResult = isRowDefault?.call(_rowEditingState.newRow!, this as TrinaGridStateManager, true) ?? false;
      bool isAddMultiple = configuration.lastRowKeyDownAction.isAddMultiple;

      if (!_compareCells(_rowEditingState.newRow!.cells, _rowEditingState.cellValues!)) {

        if (!isRowDefaultResult || !isAddMultiple) {
          // No s'ha canviat cap cel·la per tant no generem l'event de on row changed
          // i reïniciem el row editing state
          resetRowEditingState();

          (this as TrinaGridStateManager).commitChanges();
          return;
        }

      }

      // S'ha canviat la fila seleccionada enviem els canvis si n'hi havia
      // de la fila que modificavem
      bool? result = await onRowChanged?.call(TrinaGridOnRowChangedEvent(
          rowIdx: _rowEditingState.indexRow!,
          row: _rowEditingState.newRow!,
          oldCellValues: _rowEditingState.cellValues!
      ));

      if (result == null || result == true) {
        // Reiniciem el row editing state
        (this as TrinaGridStateManager).commitChanges();
        resetRowEditingState();
      }
    }
  }

  ///
  /// Retorna true si s'ha canviat alguna cell, false altrament
  bool _compareCells(Map<String, TrinaCell> newCells,  Map<String, dynamic> oldCells){
    for(var entry in newCells.entries) {

      // Si la cel·la és dirty vol dir que s'ha canviat el valor així que retornem true
      var cell = newCells[entry.key];
      var isDirty = cell?.isDirty;
      if (isDirty != null && isDirty)
        return true;

      if(!oldCells.containsKey(entry.key))
        return true;

      var oc = oldCells[entry.key];
      if (oc != entry.value.value)
        return true;
    }
    return false;
  }

  @override
  void resetRowEditingState(){
    // Reiniciem el row editing state
    _rowEditingState = RowEditingState();
  }

}
