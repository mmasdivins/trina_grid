
import 'package:trina_grid/src/model/trina_column.dart';

class TrinaColumnSorting {
  final TrinaColumnSort sortOrder;
  final int? sortPosition;

  const TrinaColumnSorting({
    required this.sortOrder,
    required this.sortPosition,
  });

  TrinaColumnSorting copyWith({
    TrinaColumnSort? sortOrder,
    int? sortPosition,
  }) {
    return TrinaColumnSorting(
      sortOrder: sortOrder ?? this.sortOrder,
      sortPosition: sortPosition ?? this.sortPosition,
    );
  }

}