import 'package:trina_grid/src/export/trina_grid_export.dart';
import 'package:trina_grid/src/manager/trina_grid_state_manager.dart';
import 'package:trina_grid/src/model/trina_column.dart';
import 'package:trina_grid/src/model/trina_row.dart';

/// Implementation of [TrinaGridExport] for CSV format
class TrinaGridExportCsv implements TrinaGridExport {
  @override
  Future<String> export({
    required TrinaGridStateManager stateManager,
    List<String>? columns,
    bool includeHeaders = true,
  }) async {
    // Get visible columns if no specific columns are requested
    final List<TrinaColumn> visibleColumns =
        columns != null
            ? stateManager.refColumns
                .where((column) => columns.contains(column.title))
                .toList()
            : stateManager.getVisibleColumns();

    if (visibleColumns.isEmpty) {
      throw Exception('No columns to export');
    }

    // Get rows
    final List<TrinaRow> rows = stateManager.refRows;

    // Create CSV content
    final StringBuffer csvContent = StringBuffer();

    // Add header row if requested
    if (includeHeaders) {
      final List<String> headers =
          visibleColumns
              .map((column) => _escapeCsvField(column.title))
              .toList();
      csvContent.writeln(headers.join(','));
    }

    // Add data rows
    for (final row in rows) {
      final List<String> rowData = [];
      for (final column in visibleColumns) {
        final cell = row.cells[column.field];
        final value = cell?.value?.toString() ?? '';
        rowData.add(_escapeCsvField(value));
      }
      csvContent.writeln(rowData.join(','));
    }

    return csvContent.toString();
  }

  /// Escapes a field for CSV format
  /// - If the field contains commas, newlines, or double quotes, it is enclosed in double quotes
  /// - Double quotes within the field are escaped by doubling them
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('\n') || field.contains('"')) {
      // Replace double quotes with two double quotes
      final escaped = field.replaceAll('"', '""');
      // Enclose in double quotes
      return '"$escaped"';
    }
    return field;
  }
}
