import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

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
  // Cantonada de la columna d'índex: no té cap llista, així que no ha
  // d'afegir cap controlador al grup de scroll vertical ni registrar-se com a
  // bodyRowsVertical (trencava el scroll amb teclat fins al final).

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    forceUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final style = stateManager.style;

    Widget? corner = null;

    if (widget.stateManager.createCornerWidget != null) {
      corner = widget.stateManager.createCornerWidget!.call(stateManager);
    }

    corner ??= Container();

    final double totalHeight = stateManager.columnHeight +
        (stateManager.showColumnFilter ? stateManager.columnFilterHeight : 0);

    return SizedBox(
      height: totalHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // color: Colors.green,
          border: style.enableCellBorderVertical
              ? BorderDirectional(
                  end: BorderSide(
                    color: style.borderColor,
                    width: 1.0,
                  ),
                  bottom: BorderSide(
                    width: TrinaGridSettings.cellVerticalBorderWidth,
                    color: style.borderColor,
                  ))
              : null,
        ),
        child: corner,
      ),
    );
  }
}
