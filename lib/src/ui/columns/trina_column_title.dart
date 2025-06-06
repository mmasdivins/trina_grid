import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trina_grid/src/model/trina_column_sorting.dart';
import 'package:trina_grid/trina_grid.dart';

import '../ui.dart';

class TrinaColumnTitle extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  late final double height;

  TrinaColumnTitle({
    required this.stateManager,
    required this.column,
    double? height,
  })  : height = height ?? stateManager.columnHeight,
        super(key: ValueKey('column_title_${column.key}'));

  @override
  TrinaColumnTitleState createState() => TrinaColumnTitleState();
}

class TrinaColumnTitleState extends TrinaStateWithChange<TrinaColumnTitle> {
  late Offset _columnRightPosition;

  bool _isPointMoving = false;

  TrinaColumnSorting _sort = const TrinaColumnSorting(
    sortOrder: TrinaColumnSort.none,
    sortPosition: null,
  );

  bool get showContextIcon {
    return widget.column.enableContextMenu ||
        widget.column.enableDropToResize ||
        !_sort.sortOrder.isNone;
  }

  bool get enableGesture {
    return widget.column.enableContextMenu || widget.column.enableDropToResize;
  }

  MouseCursor get contextMenuCursor {
    if (enableGesture) {
      return widget.column.enableDropToResize
          ? SystemMouseCursors.resizeLeftRight
          : SystemMouseCursors.click;
    }

    return SystemMouseCursors.basic;
  }

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _sort = update<TrinaColumnSorting>(_sort, widget.column.sort);
  }

  void _showContextMenu(BuildContext context, Offset position) async {
    final selected = await showColumnMenu(
      context: context,
      position: position,
      backgroundColor: stateManager.style.menuBackgroundColor,
      items: stateManager.columnMenuDelegate.buildMenuItems(
        stateManager: stateManager,
        column: widget.column,
      ),
    );

    if (context.mounted) {
      stateManager.columnMenuDelegate.onSelected(
        context: context,
        stateManager: stateManager,
        column: widget.column,
        mounted: mounted,
        selected: selected,
      );
    }
  }

  void _handleOnPointDown(PointerDownEvent event) {
    _isPointMoving = false;

    _columnRightPosition = event.position;
  }

  void _handleOnPointMove(PointerMoveEvent event) {
    // if at least one movement event has distanceSquared > 0.5 _isPointMoving will be true
    _isPointMoving |=
        (_columnRightPosition - event.position).distanceSquared > 0.5;

    if (!_isPointMoving) return;

    final moveOffset = event.position.dx - _columnRightPosition.dx;

    final bool isLTR = stateManager.isLTR;

    stateManager.resizeColumn(widget.column, isLTR ? moveOffset : -moveOffset);

    _columnRightPosition = event.position;
  }

  void _handleOnPointUp(PointerUpEvent event) {
    if (_isPointMoving) {
      stateManager.updateCorrectScrollOffset();
    } else if (mounted && widget.column.enableContextMenu) {
      _showContextMenu(context, event.position);
    }

    _isPointMoving = false;
  }

  @override
  Widget build(BuildContext context) {
    final style = stateManager.configuration.style;

    final resizeWithoutIcon = MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: SizedBox(width: 8, height: widget.height),
    );

    final columnWidget = _SortableWidget(
      stateManager: stateManager,
      column: widget.column,
      child: _ColumnWidget(
        stateManager: stateManager,
        column: widget.column,
        height: widget.height,
      ),
    );

    final contextMenuIcon = SizedBox(
      height: widget.height,
      child: Align(
        alignment: Alignment.center,
        child: IconButton(
          icon: TrinaGridColumnIcon(
            sort: _sort,
            color: style.iconColor,
            icon: widget.column.enableContextMenu
                ? style.columnContextIcon
                : style.columnResizeIcon,
            ascendingIcon: style.columnAscendingIcon,
            descendingIcon: style.columnDescendingIcon,
          ),
          iconSize: style.iconSize,
          mouseCursor: contextMenuCursor,
          onPressed: null,
        ),
      ),
    );

    Widget menuIconWidget = contextMenuIcon;
    if (!widget.column.enableContextMenu && style.hideResizeIcon) {
      menuIconWidget = resizeWithoutIcon;
    }

    // If a custom title renderer is provided, use it
    if (widget.column.hasTitleRenderer) {
      final rendererContext = _createTitleRendererContext(contextMenuIcon);
      final customTitleWidget = widget.column.titleRenderer!(rendererContext);

      // Ensure dragging functionality works with custom renderer
      return widget.column.enableColumnDrag
          ? _DraggableWidget(
              stateManager: stateManager,
              column: widget.column,
              child: customTitleWidget,
            )
          : customTitleWidget;
    }

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          child: widget.column.enableColumnDrag
              ? _DraggableWidget(
                  stateManager: stateManager,
                  column: widget.column,
                  child: columnWidget,
                )
              : columnWidget,
        ),
        if (showContextIcon)
          Positioned.directional(
            textDirection: stateManager.textDirection,
            end: -3,
            child:
                enableGesture
                    ? Listener(
                      onPointerDown: _handleOnPointDown,
                      onPointerMove: _handleOnPointMove,
                      onPointerUp: _handleOnPointUp,
                      child: menuIconWidget,
                    )
                    : menuIconWidget,
          ),
      ],
    );
  }

  TrinaColumnTitleRendererContext _createTitleRendererContext(
    Widget contextMenuIcon,
  ) {
    final isFiltered = stateManager.isFilteredColumn(widget.column);

    return TrinaColumnTitleRendererContext(
      column: widget.column,
      stateManager: stateManager,
      height: widget.height,
      showContextIcon: showContextIcon,
      contextMenuIcon: enableGesture
          ? Listener(
              onPointerDown: _handleOnPointDown,
              onPointerMove: _handleOnPointMove,
              onPointerUp: _handleOnPointUp,
              child: contextMenuIcon,
            )
          : contextMenuIcon,
      isFiltered: isFiltered,
      showContextMenu:
          mounted && widget.column.enableContextMenu ? _showContextMenu : null,
    );
  }
}

class TrinaGridColumnIcon extends StatelessWidget {
  final TrinaColumnSorting? sort;

  final Color color;

  final IconData icon;

  final Icon? ascendingIcon;

  final Icon? descendingIcon;

  const TrinaGridColumnIcon({
    this.sort,
    this.color = Colors.black26,
    this.icon = Icons.dehaze,
    this.ascendingIcon,
    this.descendingIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: color,
    );
    // switch (sort) {
    //   case TrinaColumnSort.ascending:
    //     return ascendingIcon == null
    //         ? Transform.rotate(
    //           angle: 90 * pi / 90,
    //           child: const Icon(Icons.sort, color: Colors.green),
    //         )
    //         : ascendingIcon!;
    //   case TrinaColumnSort.descending:
    //     return descendingIcon == null
    //         ? const Icon(Icons.sort, color: Colors.red)
    //         : descendingIcon!;
    //   default:
    //     return Icon(icon, color: color);
    // }
  }
}

class TrinaGridColumnIconSort extends StatelessWidget {
  final TrinaColumnSorting? sort;

  final Color color;

  final Icon? ascendingIcon;

  final Icon? descendingIcon;

  const TrinaGridColumnIconSort({
    this.sort,
    this.color = Colors.black26,
    this.ascendingIcon,
    this.descendingIcon,
    super.key,
  });

  _iconWithNumber(Widget child, int number) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          child:  Container(
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Text(
              number.toString(),
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (sort == null) {
      return const SizedBox(height: 0, width: 0,);
    }

    int sortPosition = (sort!.sortPosition ?? 0) + 1;

    switch (sort!.sortOrder) {
      case TrinaColumnSort.ascending:
        return ascendingIcon == null
            ? _iconWithNumber(Transform.rotate(
          angle: 90 * pi / 90,
          child: const Icon(
            Icons.sort,
            color: Colors.green,
          ),
        ), sortPosition)
            : _iconWithNumber(ascendingIcon!, sortPosition);
      case TrinaColumnSort.descending:
        return descendingIcon == null
            ? _iconWithNumber(const Icon(
          Icons.sort,
          color: Colors.red,
        ), sortPosition)
            : _iconWithNumber(descendingIcon!, sortPosition);
      default:
        return const SizedBox(height: 0, width: 0,);
    }
  }
}

class _IconWithNumber extends StatelessWidget {
  final IconData icon;
  final int number;
  final double iconSize;
  final TextStyle textStyle;

  _IconWithNumber({
    required this.icon,
    required this.number,
    this.iconSize = 24.0,
    this.textStyle = const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          icon,
          size: iconSize,
        ),
        Positioned(
          child: Text(
            number.toString(),
            style: textStyle,
          ),
        ),
      ],
    );
  }
}


class _DraggableWidget extends StatelessWidget {
  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  final Widget child;

  const _DraggableWidget({
    required this.stateManager,
    required this.column,
    required this.child,
  });

  void _handleOnPointerMove(PointerMoveEvent event) {
    stateManager.eventManager!.addEvent(
      TrinaGridScrollUpdateEvent(
        offset: event.position,
        scrollDirection: TrinaGridScrollUpdateDirection.horizontal,
      ),
    );
  }

  void _handleOnPointerUp(PointerUpEvent event) {
    TrinaGridScrollUpdateEvent.stopScroll(
      stateManager,
      TrinaGridScrollUpdateDirection.horizontal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _handleOnPointerMove,
      onPointerUp: _handleOnPointerUp,
      child: Draggable<TrinaColumn>(
        data: column,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: TrinaShadowContainer(
            alignment: column.titleTextAlign.alignmentValue,
            width: TrinaGridSettings.minColumnWidth,
            height: stateManager.columnHeight,
            backgroundColor:
                stateManager.configuration.style.gridBackgroundColor,
            borderColor: stateManager.configuration.style.gridBorderColor,
            child: Text(
              column.title,
              style: stateManager.configuration.style.columnTextStyle.copyWith(
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _SortableWidget extends StatelessWidget {
  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  final Widget child;

  const _SortableWidget({
    required this.stateManager,
    required this.column,
    required this.child,
  });

  void _onTap() {
    stateManager.toggleSortColumn(column);
  }

  @override
  Widget build(BuildContext context) {
    return column.enableSorting
        ? MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              key: const ValueKey('ColumnTitleSortableGesture'),
              onTap: _onTap,
              child: child,
            ),
          )
        : child;
  }
}

class _ColumnWidget extends StatelessWidget {
  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  final double height;

  const _ColumnWidget({
    required this.stateManager,
    required this.column,
    required this.height,
  });

  EdgeInsets get padding =>
      column.titlePadding ??
      stateManager.configuration.style.defaultColumnTitlePadding;

  bool get showSizedBoxForIcon =>
      column.isShowRightIcon &&
      (column.titleTextAlign.isRight || stateManager.isRTL);

  @override
  Widget build(BuildContext context) {
    return DragTarget<TrinaColumn>(
      onWillAcceptWithDetails: (columnToDrag) {
        return columnToDrag.data.key != column.key &&
            !stateManager.limitMoveColumn(
              column: columnToDrag.data,
              targetColumn: column,
            );
      },
      onAcceptWithDetails: (columnToMove) {
        if (columnToMove.data.key != column.key) {
          stateManager.moveColumn(
            column: columnToMove.data,
            targetColumn: column,
          );
        }
      },
      builder: (dragContext, candidate, rejected) {
        final bool noDragTarget = candidate.isEmpty;

        final style = stateManager.style;

        return SizedBox(
          width: column.width,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: column.backgroundGradient, //
              color: column.backgroundGradient == null
                  ? (noDragTarget
                      ? column.backgroundColor
                      : style.dragTargetColumnColor)
                  : null,
              border: BorderDirectional(
                end: style.enableColumnBorderVertical
                    ? BorderSide(color: style.borderColor, width: 1.0)
                    : BorderSide.none,
              ),
            ),
            child: Padding(
              padding: padding,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    if (column.enableRowChecked &&
                        column.rowCheckBoxGroupDepth == 0 &&
                        column.enableTitleChecked)
                      CheckboxAllSelectionWidget(stateManager: stateManager),
                    Expanded(
                      child: _ColumnTextWidget(
                        column: column,
                        stateManager: stateManager,
                        height: height,
                      ),
                    ),
                    if (showSizedBoxForIcon) SizedBox(width: style.iconSize),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CheckboxAllSelectionWidget extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  const CheckboxAllSelectionWidget({required this.stateManager, super.key});

  @override
  CheckboxAllSelectionWidgetState createState() =>
      CheckboxAllSelectionWidgetState();
}

class CheckboxAllSelectionWidgetState
    extends TrinaStateWithChange<CheckboxAllSelectionWidget> {
  bool? _checked;

  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _checked = update<bool?>(_checked, stateManager.tristateCheckedRow);
  }

  void _handleOnChanged(bool? changed) {
    if (changed == _checked) {
      return;
    }

    changed ??= false;

    if (_checked == null) changed = true;

    stateManager.toggleAllRowChecked(changed);

    if (stateManager.onRowChecked != null) {
      stateManager.onRowChecked!(
        TrinaGridOnRowCheckedAllEvent(isChecked: changed),
      );
    }

    setState(() {
      _checked = changed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TrinaScaledCheckbox(
      value: _checked,
      handleOnChanged: _handleOnChanged,
      tristate: true,
      scale: 0.86,
      unselectedColor: stateManager.configuration.style.columnUnselectedColor,
      activeColor: stateManager.configuration.style.columnActiveColor,
      checkColor: stateManager.configuration.style.columnCheckedColor,
      side: stateManager.configuration.style.columnCheckedSide,
    );
  }
}

class _ColumnTextWidget extends TrinaStatefulWidget {
  final TrinaGridStateManager stateManager;

  final TrinaColumn column;

  final double height;

  const _ColumnTextWidget({
    required this.stateManager,
    required this.column,
    required this.height,
  });

  @override
  _ColumnTextWidgetState createState() => _ColumnTextWidgetState();
}

class _ColumnTextWidgetState extends TrinaStateWithChange<_ColumnTextWidget> {
  bool _isFilteredList = false;
  bool _focusInColumn = false;
  TrinaColumnSorting _sort = const TrinaColumnSorting(
    sortOrder: TrinaColumnSort.none,
    sortPosition: null,
  );


  @override
  TrinaGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(TrinaNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(TrinaNotifierEvent event) {
    _isFilteredList = update<bool>(
      _isFilteredList,
      stateManager.isFilteredColumn(widget.column),
    );

    bool inColumn = false;
    var ci = stateManager.columnIndex(widget.column);
    var ccp = stateManager.currentCellPosition;
    if (ccp != null && ccp.columnIdx == ci){
      inColumn = true;
    }
    _focusInColumn = update<bool>(
      _focusInColumn,
      inColumn,
    );

    _sort = update<TrinaColumnSorting>(
      _sort,
      widget.column.sort,
    );
  }

  void _handleOnPressedFilter() {
    stateManager.showFilterPopup(context, calledColumn: widget.column);
  }

  String? get _title =>
      widget.column.titleSpan == null ? widget.column.title : null;

  List<InlineSpan> _children() {
    TextStyle style = _focusInColumn ? stateManager.configuration.style.columnSelectedTextStyle : stateManager.configuration.style.columnTextStyle;
    if (widget.column.highlight) {
      style = style.copyWith(fontWeight: FontWeight.bold);
    }

    return [
      if (_title != null && _title != "")
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Text(_title!, style: style,
          ),
        ),

      if (widget.column.titleSpan != null) widget.column.titleSpan!,
      if (_isFilteredList)
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: IconButton(
            icon: Icon(
              Icons.filter_alt_outlined,
              color: stateManager.configuration.style.iconColor,
              size: stateManager.configuration.style.iconSize,
            ),
            onPressed: _handleOnPressedFilter,
            constraints: BoxConstraints(
              maxHeight:
              widget.height + (TrinaGridSettings.rowBorderWidth * 2),
            ),
          ),
        ),
    ];
  }


  @override
  Widget build(BuildContext context) {
    TextStyle style = _focusInColumn ? stateManager.configuration.style.columnSelectedTextStyle : stateManager.configuration.style.columnTextStyle;
    if (widget.column.highlight) {
      style = style.copyWith(fontWeight: FontWeight.bold);
    }

    return Row(
      children: [
        if (widget.column.enableSorting)
          TrinaGridColumnIconSort(
            sort: _sort,
            color: stateManager.configuration.style.iconColor,
            ascendingIcon: stateManager.configuration.style.columnAscendingIcon,
            descendingIcon: stateManager.configuration.style.columnDescendingIcon,
          ),
        Expanded(
          child: Text.rich(
            TextSpan(
              // text: _title,
              children: _children(),
            ),
            style: style,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            maxLines: 1,
            textAlign: widget.column.titleTextAlign.value,
          ),
        )
      ],
    );
  }
}
