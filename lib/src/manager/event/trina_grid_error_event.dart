import 'package:trina_grid/src/manager/event/trina_grid_event.dart';

abstract class TrinaGridErrorEvent extends TrinaGridEvent {
  TrinaGridErrorEvent({
    super.type,
    super.duration,
  });
}