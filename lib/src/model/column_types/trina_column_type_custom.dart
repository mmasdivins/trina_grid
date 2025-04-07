import 'package:trina_grid/trina_grid.dart';

class TrinaColumnTypeCustom with TrinaColumnTypeDefaultMixin
    implements TrinaColumnType {
  @override
  final dynamic defaultValue;

  const TrinaColumnTypeCustom({
    this.defaultValue,
  });

  @override
  bool isValid(dynamic value) {
    return true;
  }

  @override
  int compare(dynamic a, dynamic b) {
    return _compareWithNull(a, b, () => a.compareTo(b));
  }

  @override
  dynamic makeCompareValue(dynamic v) {
    return v;
  }
}




int _compareWithNull(
    dynamic a,
    dynamic b,
    int Function() resolve,
    ) {
  if (a == null || b == null) {
    return a == b
        ? 0
        : a == null
        ? -1
        : 1;
  }

  return resolve();
}