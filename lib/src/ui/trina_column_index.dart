import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../helper/platform_helper.dart';
import 'ui.dart';

class TrinaColumnIndex extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  const TrinaColumnIndex(
      this.stateManager, {
        super.key,
      });

  @override
  TrinaColumnIndexState createState() => TrinaColumnIndexState();
}

class TrinaColumnIndexState extends TrinaStateWithChange<TrinaColumnIndex> {

  late final ScrollController _verticalScroll;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _verticalScroll = stateManager.scroll.vertical!.addAndGet();

    stateManager.scroll.setBodyRowsVertical(_verticalScroll);

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void dispose() {
    _verticalScroll.dispose();

    super.dispose();
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    forceUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final style = stateManager.style;

    var w = widget.stateManager.createCornerWidget;

    return SizedBox(
      height: stateManager.columnHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // color: Colors.green,
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
        child: w?.call(stateManager),
      ),
    );
  }

}