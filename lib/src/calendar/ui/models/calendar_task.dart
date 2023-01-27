import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/label/ui/cubit/labels_cubit.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:collection/collection.dart';

class CalendarTask extends Appointment {
  bool done;
  String? listId;
  Label? label;
  CalendarTask(
      {required super.startTime,
      required super.endTime,
      super.color,
      super.endTimeZone,
      super.id,
      super.isAllDay,
      super.location,
      super.notes,
      super.recurrenceExceptionDates,
      super.recurrenceId,
      super.recurrenceRule,
      super.resourceIds,
      super.startTimeZone,
      super.subject,
      this.done = false,
      this.listId,
      this.label});

  static CalendarTask taskToCalendarTask(BuildContext context, Task task) {
    DateTime startTime = DateTime.parse(task.datetime!);
    DateTime endTime = DateTime.parse(task.datetime!).add(Duration(seconds: task.duration!));
    return CalendarTask(
        startTime: startTime,
        endTime: endTime,
        subject: task.title!,
        done: task.done!,
        id: task.id,
        listId: task.listId,
        label: _getLabel(context, task));
  }

  static Label? _getLabel(BuildContext context, Task task) {
    if (task.listId == null || task.listId!.isEmpty) {
      return null;
    }

    List<Label> labels = context.read<LabelsCubit>().state.labels;

    Label? label = labels.firstWhereOrNull(
      (label) => task.listId!.contains(label.id!),
    );

    if (label == null || label.deletedAt != null) {
      return null;
    }

    return label;
  }
}
