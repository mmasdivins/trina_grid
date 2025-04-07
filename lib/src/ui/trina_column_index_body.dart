import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:trina_grid/src/ui/trina_column_index.dart';

import '../helper/platform_helper.dart';
import 'ui.dart';

class TrinaColumnIndexBody extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  const TrinaColumnIndexBody(
      this.stateManager, {
        super.key,
      });

  @override
  TrinaColumnIndexBodyState createState() => TrinaColumnIndexBodyState();
}

class TrinaColumnIndexBodyState extends TrinaStateWithChange<TrinaColumnIndexBody> {
  List<TrinaColumn> _columns = [];

  List<TrinaRow> _rows = [];

  late final ScrollController _verticalScroll;

  // late final ScrollController _horizontalScroll;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    // _horizontalScroll = stateManager.scroll.horizontal!.addAndGet();
    //
    // stateManager.scroll.setBodyRowsHorizontal(_horizontalScroll);
    //
    _verticalScroll = stateManager.scroll.vertical!.addAndGet();
    //
    stateManager.scroll.setBodyRowsVertical(_verticalScroll);

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void dispose() {
    _verticalScroll.dispose();

    // _horizontalScroll.dispose();

    super.dispose();
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    forceUpdate();

    _columns = _getColumns();

    _rows = stateManager.refRows;
  }

  List<TrinaColumn> _getColumns() {
    return stateManager.showFrozenColumn == true
        ? stateManager.bodyColumns
        : stateManager.columns;
  }

  @override
  Widget build(BuildContext context) {
    final style = stateManager.style;

    return ListView.builder(
      controller: _verticalScroll,
      scrollDirection: Axis.vertical,
      physics: const ClampingScrollPhysics(),
      itemCount: _rows.length,
      itemExtent: stateManager.rowTotalHeight,
      itemBuilder: (ctx, i) {
        var index = "${i+1}";

        bool isRowFocused = false;
        var ccp = stateManager.currentCellPosition;
        Color? color;
        if (ccp != null && ccp.rowIdx == i){
          isRowFocused = true;
          color = style.activatedColor;
        }

        Widget widget = Center(
          child: Text(index, style: TextStyle(
            fontWeight: isRowFocused ? FontWeight.bold : FontWeight.normal,
          )),
        );


        var row = stateManager.refRows[i];

        if (row.isLoading) {
          return const Center(
            child: Padding(
                padding: EdgeInsets.all(4.0),
                child: CircularProgressIndicator()
            ),
          );
        }
        else if (row.errorState.error) {
          return Tooltip(
            message: row.errorState.msgError,
            child: const Icon(Icons.error_outline, color: Colors.red,),
          );
        }
        else if (stateManager.createColumnIndex != null){
          var w = stateManager.createColumnIndex!(i, stateManager);
          if (w != null){
            widget = w;
          }
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            color: null,
            border: style.enableCellBorderVertical ? BorderDirectional(
                end: BorderSide(
                  color: style.borderColor,
                  width: 1.0,
                ),
                bottom: BorderSide(
                  width: TrinaGridSettings.rowBorderWidth,
                  color: style.borderColor,
                )
            ) : null,
          ),
          child: Container(
            color: color,
            child: widget,
          ),
        );
      },
    );
  }

}