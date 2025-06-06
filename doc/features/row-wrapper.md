# Row Wrapper

The `rowWrapper` feature in TrinaGrid allows you to customize the rendering of each row by wrapping the default row widget with your own widget or logic. This is useful for adding custom styling, interactivity, or additional UI elements to every row in the grid.

## Overview

- **Purpose:** Customize how each row is displayed.
- **Type:**

  ```dart
  typedef RowWrapper = Widget Function(
    BuildContext context,
    Widget row,
    TrinaGridStateManager stateManager,
  );
  ```

- **Where to use:** Pass as the `rowWrapper` property to the `TrinaGrid` widget.

## Example Usage

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  rowWrapper: (context, row, stateManager) {
    // Example: Add a colored border to each row
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(4),
      ),
      child: row,
    );
  },
)
```

## Use Cases

- Add custom borders, backgrounds, or shadows to rows.
- Attach gesture detectors or context menus.
- Animate row appearance or add tooltips.

## Notes

- If `rowWrapper` is not provided, the default row widget is used.
- The wrapper receives the build context, the default row widget, and the grid state manager for maximum flexibility.
