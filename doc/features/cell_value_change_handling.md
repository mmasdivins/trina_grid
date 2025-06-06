# Cell Value Change Handling in TrinaGrid

TrinaGrid provides a flexible system for handling cell value changes through callbacks at both the cell level and the grid level. This dual approach gives you fine-grained control over how changes are processed in your application.

## Overview

When a cell value changes in TrinaGrid, the following sequence occurs:

1. The cell value is updated in the data model
2. If present, the cell-level `onChanged` callback is triggered
3. If present, the grid-level `onChanged` callback is triggered
4. The UI is updated to reflect the change

This sequence allows you to implement different strategies for handling changes based on your application's architecture.

## Cell-Level onChanged Callback

The cell-level `onChanged` callback is defined directly on the `TrinaCell` object and is specific to that individual cell.

### Syntax

```dart
TrinaCell(
  value: initialValue,
  onChanged: (TrinaGridOnChangedEvent event) {
    // Handle the cell value change
  },
)
```

### When to Use Cell-Level Callbacks

Cell-level callbacks are ideal for:

- Cell-specific validation or formatting
- Triggering different actions based on which specific cell changed
- Implementing cell-specific business logic
- Creating interdependent cells (where one cell's value affects another)
- Tracking changes to specific high-importance cells

### Example: Cell-Level Validation

```dart
TrinaCell(
  value: 'Initial Value',
  onChanged: (event) {
    // Validate this specific cell's value
    if (event.value.toString().isEmpty) {
      showToast('This field cannot be empty');
      // You could also revert the change or apply a default value
    }
    
    // You can also update other UI elements based on this cell's value
    if (event.value == 'Special Value') {
      showDialog(context, 'Special value detected!');
    }
  },
)
```

## Grid-Level onChanged Callback (State Manager)

The grid-level `onChanged` callback is defined on the `TrinaGrid` widget and is triggered for any cell change in the entire grid.

### onChanged callback syntax

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onChanged: (TrinaGridOnChangedEvent event) {
    // Handle any cell value change in the grid
  },
)
```

### When to Use Grid-Level Callbacks

Grid-level callbacks are ideal for:

- Centralized handling of all changes
- Saving changes to a database
- Logging all modifications
- Implementing undo/redo functionality
- Syncing data with external systems
- Applying global validation rules

### Example: Grid-Level Change Handling

```dart
TrinaGrid(
  columns: columns,
  rows: rows,
  onChanged: (event) {
    // Log all changes
    logger.info('Cell changed: ${event.column.field} = ${event.value}');
    
    // Save changes to database
    databaseService.updateField(
      rowId: event.row.cells['id']?.value,
      field: event.column.field,
      value: event.value,
    );
    
    // Update application state
    appStateManager.notifyDataChanged();
  },
)
```

## Combined Approach

You can use both cell-level and grid-level callbacks together to create a comprehensive change handling system.

### Example: Combined Approach

```dart
// Cell-level handling for specific validation
TrinaCell(
  value: 'John',
  onChanged: (event) {
    // Cell-specific validation
    if (event.value.toString().length < 3) {
      showToast('Name must be at least 3 characters');
    }
  },
)

// Grid-level handling for global operations
TrinaGrid(
  columns: columns,
  rows: rows,
  onChanged: (event) {
    // Global handling for all cells
    saveChangesToDatabase(event.row, event.column.field, event.value);
    updateUIState();
  },
)
```

## The TrinaGridOnChangedEvent Object

Both callback types receive a `TrinaGridOnChangedEvent` object that contains information about the change:

| Property | Type | Description |
|----------|------|-------------|
| `columnIdx` | `int` | The index of the column in the current view |
| `column` | `TrinaColumn` | The column object |
| `rowIdx` | `int` | The index of the row in the current view |
| `row` | `TrinaRow` | The row object |
| `value` | `dynamic` | The new value |
| `oldValue` | `dynamic` | The previous value |

### Example: Using the Event Object

```dart
onChanged: (event) {
  print('Column: ${event.column.title}');
  print('Field: ${event.column.field}');
  print('Row index: ${event.rowIdx}');
  print('Changed from: ${event.oldValue} to ${event.value}');
  
  // Access other cells in the same row
  final otherCellValue = event.row.cells['otherField']?.value;
}
```

## Best Practices

1. **Use cell-level callbacks for cell-specific logic** and grid-level callbacks for application-wide concerns.

2. **Keep callbacks lightweight** to ensure smooth performance, especially in large grids.

3. **Consider the callback order**: cell-level callbacks are called before grid-level callbacks, so you can use this to your advantage in your application architecture.

4. **Handle errors gracefully** in both callback types to prevent UI freezes.

5. **Use the appropriate callback type** based on your needs:
   - For isolated cell behavior: use cell-level callbacks
   - For centralized data management: use grid-level callbacks
   - For comprehensive solutions: use both

## Complete Example

Here's a complete example demonstrating both callback types:

```dart
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

class CellChangeHandlingExample extends StatefulWidget {
  @override
  _CellChangeHandlingExampleState createState() => _CellChangeHandlingExampleState();
}

class _CellChangeHandlingExampleState extends State<CellChangeHandlingExample> {
  late List<TrinaColumn> columns;
  late List<TrinaRow> rows;
  late TrinaGridStateManager stateManager;
  
  // Track changes for display
  final List<String> changeLog = [];
  
  @override
  void initState() {
    super.initState();
    
    // Define columns
    columns = [
      TrinaColumn(
        title: 'Name',
        field: 'name',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: 'Age',
        field: 'age',
        type: TrinaColumnType.number(),
      ),
    ];
    
    // Create rows with cell-level callbacks
    rows = [
      TrinaRow(
        cells: {
          'name': TrinaCell(
            value: 'John',
            onChanged: (event) {
              // Cell-level handling
              _logChange('CELL-LEVEL: Name changed to ${event.value}');
              
              // Cell-specific validation
              if (event.value.toString().length < 2) {
                _logChange('VALIDATION: Name too short!');
              }
            },
          ),
          'age': TrinaCell(
            value: 30,
            onChanged: (event) {
              // Cell-level handling
              _logChange('CELL-LEVEL: Age changed to ${event.value}');
              
              // Cell-specific validation
              if (event.value < 18) {
                _logChange('VALIDATION: Must be 18 or older!');
              }
            },
          ),
        },
      ),
      // Add more rows as needed
    ];
  }
  
  void _logChange(String message) {
    setState(() {
      changeLog.add(message);
      // Keep log size manageable
      if (changeLog.length > 10) changeLog.removeAt(0);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cell Change Handling')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: TrinaGrid(
              columns: columns,
              rows: rows,
              onLoaded: (event) {
                stateManager = event.stateManager;
              },
              onChanged: (event) {
                // Grid-level handling for all cells
                _logChange('GRID-LEVEL: ${event.column.field} changed to ${event.value}');
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Change Log:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: changeLog.length,
                      itemBuilder: (context, index) {
                        return Text(changeLog[changeLog.length - 1 - index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

This example demonstrates how to use both cell-level and grid-level callbacks to handle changes in a TrinaGrid, with a visual log showing the sequence of events.
