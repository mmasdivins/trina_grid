import 'package:trina_grid/src/model/column_types/trina_column_type_custom.dart';
import 'package:trina_grid/src/model/column_types/trina_column_type_date_time.dart';
import 'package:trina_grid/src/model/column_types/trina_column_type_percentage.dart';
import 'package:trina_grid/trina_grid.dart';

extension TrinaColumnTypeExtension on TrinaColumnType {
  bool get isText => this is TrinaColumnTypeText;

  bool get isNumber => this is TrinaColumnTypeNumber;

  bool get isCurrency => this is TrinaColumnTypeCurrency;

  bool get isSelect => this is TrinaColumnTypeSelect;

  bool get isDate => this is TrinaColumnTypeDate;

  bool get isTime => this is TrinaColumnTypeTime;

  bool get isDateTime => this is TrinaColumnTypeDateTime;

  bool get isBoolean => this is TrinaColumnTypeBoolean;

  bool get isPercentage => this is TrinaColumnTypePercentage;

  bool get isCustom => this is TrinaColumnTypeCustom;


  TrinaColumnTypeText get text {
    if (this is! TrinaColumnTypeText) {
      throw TypeError();
    }
    return this as TrinaColumnTypeText;
  }

  TrinaColumnTypeNumber get number {
    if (this is! TrinaColumnTypeNumber) {
      throw TypeError();
    }
    return this as TrinaColumnTypeNumber;
  }

  TrinaColumnTypeCurrency get currency {
    if (this is! TrinaColumnTypeCurrency) {
      throw TypeError();
    }
    return this as TrinaColumnTypeCurrency;
  }

  TrinaColumnTypeBoolean get boolean {
    if (this is! TrinaColumnTypeBoolean) {
      throw TypeError();
    }
    return this as TrinaColumnTypeBoolean;
  }

  TrinaColumnTypeSelect get select {
    if (this is! TrinaColumnTypeSelect) {
      throw TypeError();
    }
    return this as TrinaColumnTypeSelect;
  }

  TrinaColumnTypeDate get date {
    if (this is! TrinaColumnTypeDate) {
      throw TypeError();
    }
    return this as TrinaColumnTypeDate;
  }

  TrinaColumnTypeTime get time {
    if (this is! TrinaColumnTypeTime) {
      throw TypeError();
    }
    return this as TrinaColumnTypeTime;
  }

  TrinaColumnTypeDateTime get dateTime {
    if (this is! TrinaColumnTypeDateTime) {
      throw TypeError();
    }
    return this as TrinaColumnTypeDateTime;
  }

  TrinaColumnTypePercentage get percentage {
    if (this is! TrinaColumnTypePercentage) {
      throw TypeError();
    }
    return this as TrinaColumnTypePercentage;
  }

  TrinaColumnTypeCustom get custom{
    if (this is! TrinaColumnTypeCustom) {
      throw TypeError();
    }

    return this as TrinaColumnTypeCustom;
  }

  bool get hasFormat => this is TrinaColumnTypeHasFormat;

  bool get applyFormatOnInit =>
      hasFormat ? (this as TrinaColumnTypeHasFormat).applyFormatOnInit : false;

  dynamic applyFormat(dynamic value) =>
      hasFormat ? (this as TrinaColumnTypeHasFormat).applyFormat(value) : value;
}
