import 'package:excel/excel.dart';
import 'package:trina_grid/trina_grid.dart';

/// Excel exporter for TrinaGrid
class TrinaGridDefaultExportExcel extends TrinaGridExport {

  /// [state] TrinaGrid's TrinaGridStateManager.
  @override
 Future<Excel> export({
    required TrinaGridStateManager stateManager,
    List<String>? columns,
    bool includeHeaders = true,
    String separator = ',',
    bool ignoreFixedRows = false,
  }) async {

    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Sheet1'];

    var trinaColumns = exportableColumns(stateManager);

    List<CellValue?> columns = [];
    int i = 0;
    for (var col in trinaColumns/*getColumnTitles(state)*/) {
      columns.add(TextCellValue(col.title));
      sheet.setColumnWidth(i++, pixelsToExcelWidth(col.width));
    }

    sheet.appendRow(columns);

    List<TrinaRow> rowsToExport = mapStateToListOfTrinaRows(stateManager);

    // Starts at row index 1 since the first row is for the column titles
    int indexRow = 1;
    for (var rowExport in rowsToExport) {
      List<CellValue?> row = [];

      int indexCol = 0;
      // Order is important, so we iterate over columns
      for (TrinaColumn column in trinaColumns) {
        dynamic value = rowExport.cells[column.field]?.value;
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: indexCol, rowIndex: indexRow));

        if (value != null && value is String) {
          cell.value = TextCellValue(column.formattedValueForDisplay(value) ?? "");
          // row.add(TextCellValue(column.formattedValueForDisplay(value) ?? ""));
        }
        else if (value is double) {
          cell.value = DoubleCellValue(value);

          if (column.formatExportExcel != null && column.formatExportExcel != "") {
            cell.cellStyle = CellStyle(numberFormat: CustomNumericNumFormat(formatCode: column.formatExportExcel!));
          }
          // row.add(DoubleCellValue(value));
        }
        else if (value is int) {
          cell.value = IntCellValue(value);

          if (column.formatExportExcel != null && column.formatExportExcel != "") {
            cell.cellStyle = CellStyle(numberFormat: CustomNumericNumFormat(formatCode: column.formatExportExcel!));
          }
          // row.add(IntCellValue(value));
        }
        else if (value is DateTime) {
          // If it's dateTime we set the width to 20 to ensure it's visible
          sheet.setColumnWidth(indexCol, 20);
          cell.value = DateTimeCellValue.fromDateTime(value);
          if (column.formatExportExcel == null || column.formatExportExcel == "") {
            cell.cellStyle = CellStyle(numberFormat: const CustomDateTimeNumFormat(formatCode: "dd/mm/yyyy"));
          }
          else {
            cell.cellStyle = CellStyle(numberFormat: CustomDateTimeNumFormat(formatCode: column.formatExportExcel!));
          }
          // row.add(DateTimeCellValue.fromDateTime(value));
        }
        else {
          cell.value = TextCellValue(value != null ? column.formattedValueForDisplay(value) : "");
          // row.add(TextCellValue(value != null ? column.formattedValueForDisplay(value) : ""));
        }

        indexCol++;
      }

      // sheet.appendRow(row);
      indexRow++;

    }

    // Export the footer if it exists
    if (trinaColumns.where((x) => x.footerRenderer != null).isNotEmpty) {
      int indexCol = 0;
      for (TrinaColumn column in trinaColumns) {
        dynamic value = column.footerExportValue?.call(
            TrinaColumnFooterRendererContext(column: column,
                stateManager: stateManager
            )
        );
        // dynamic value = rowExport.cells[column.field]?.value;
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: indexCol, rowIndex: indexRow));

        if (value != null && value is String) {
          cell.value = TextCellValue(column.formattedValueForDisplay(value) ?? "");
          // row.add(TextCellValue(column.formattedValueForDisplay(value) ?? ""));
        }
        else if (value is double) {
          cell.value = DoubleCellValue(value);

          if (column.formatExportExcel != null && column.formatExportExcel != "") {
            cell.cellStyle = CellStyle(numberFormat: CustomNumericNumFormat(formatCode: column.formatExportExcel!));
          }
          // row.add(DoubleCellValue(value));
        }
        else if (value is int) {
          cell.value = IntCellValue(value);

          if (column.formatExportExcel != null && column.formatExportExcel != "") {
            cell.cellStyle = CellStyle(numberFormat: CustomNumericNumFormat(formatCode: column.formatExportExcel!));
          }
          // row.add(IntCellValue(value));
        }
        else if (value is DateTime) {
          // If it's dateTime we set the width to 20 to ensure it's visible
          sheet.setColumnWidth(indexCol, 20);
          cell.value = DateTimeCellValue.fromDateTime(value);
          if (column.formatExportExcel == null || column.formatExportExcel == "") {
            cell.cellStyle = CellStyle(numberFormat: const CustomDateTimeNumFormat(formatCode: "dd/mm/yyyy"));
          }
          else {
            cell.cellStyle = CellStyle(numberFormat: CustomDateTimeNumFormat(formatCode: column.formatExportExcel!));
          }
          // row.add(DateTimeCellValue.fromDateTime(value));
        }
        else {
          cell.value = TextCellValue(value != null ? column.formattedValueForDisplay(value) : "");
        }

        indexCol++;
      }
    }



    return excel;

    // String toCsv = const ListToCsvConverter().convert(
    //   [
    //     getColumnTitles(state),
    //     ...mapStateToListOfRows(state),
    //   ],
    //   fieldDelimiter: fieldDelimiter,
    //   textDelimiter: textDelimiter,
    //   textEndDelimiter: textEndDelimiter,
    //   delimitAllFields: true,
    //   eol: eol,
    // );
    //
    // return toCsv;
  }


  /// Les columns trina tenen el width amb pixels,
  /// excel fa servir com ha width l'espai que ocupen els caràcters
  /// de la lletra de la cel·la (normalment és calibri 11) llavors
  /// segons aquesta caligrafia hem de dividir per 7 aproximadament
  double pixelsToExcelWidth(double pixels) {
    return pixels / 7.0;
  }

  /// Returns the titles of the active column of TrinaGrid.
  List<String> getColumnTitles(TrinaGridStateManager state) =>
      exportableColumns(state).map((e) => e.title).toList();

  /// Converts a list of TrinaRows to a string to be printed.
  ///
  /// [state] TrinaGrid's TrinaGridStateManager.
  List<List<String?>> mapStateToListOfRows(TrinaGridStateManager state) {
    List<List<String?>> outputRows = [];

    List<TrinaRow> rowsToExport = mapStateToListOfTrinaRows(state);

    for (var TrinaRow in rowsToExport) {
      outputRows.add(mapTrinaRowToList(state, TrinaRow));
    }

    return outputRows;
  }

  List<TrinaRow> mapStateToListOfTrinaRows(TrinaGridStateManager state) {

    List<TrinaRow> rowsToExport;

    // Use filteredList if available
    // https://github.com/bosskmk/Trina_grid/issues/318#issuecomment-987424407
    rowsToExport = state.refRows.filteredList.isNotEmpty
        ? state.refRows.filteredList
        : state.refRows.originalList;

    return rowsToExport;
  }


  /// [state] TrinaGrid's TrinaGridStateManager.
  List<String?> mapTrinaRowToList(
      TrinaGridStateManager state,
      TrinaRow TrinaRow,
      ) {
    List<String?> serializedRow = [];

    // Order is important, so we iterate over columns
    for (TrinaColumn column in exportableColumns(state)) {
      dynamic value = TrinaRow.cells[column.field]?.value;
      serializedRow
          .add(value != null ? column.formattedValueForDisplay(value) : "");
    }

    return serializedRow;
  }

  List<TrinaColumn> exportableColumns(TrinaGridStateManager state) =>
      state.columns.where((element) => element.exportable
      ).toList();



}