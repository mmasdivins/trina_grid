import 'package:trina_grid/src/manager/trina_grid_state_manager.dart';

/// Interface for Trina Grid export functionality
abstract class TrinaGridExport {
  /// Exports grid data based on the provided state manager and optional column list
  /// 
  /// [stateManager] - The grid state manager containing grid data
  /// [columns] - Optional list of column names to export. If null, all visible columns will be exported
  Future<dynamic> export({
    required TrinaGridStateManager stateManager,
    List<String>? columns,
  });
}
