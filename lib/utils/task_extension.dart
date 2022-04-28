import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:models/task/task.dart';
import 'package:timeago/timeago.dart' as timeago;

enum TaskStatusType {
  inbox, // default - not anything else
  planned, // has `date` or `dateTime`
  /// @deprecated */
  completed, // done === 1 && !dateTime; if dateTime, then it's always PLANNED
  snoozed, // has `date` or `dateTime` and user has snoozed it
  archived, // the user has archived it (all other fields dont' matter)
  deleted, // deletedAt !== null
  someday, // has NOT `date` or `dateTime` and user has set it as `someday`
  hidden, // the user has set it as `hidden` (all other fields dont' matter)
  permanentlyDeleted, // same as above
}

extension TaskStatusTypeExt on TaskStatusType {
  int get id {
    switch (this) {
      case TaskStatusType.inbox:
        return 1;
      case TaskStatusType.planned:
        return 2;
      case TaskStatusType.completed:
        return 3;
      case TaskStatusType.snoozed:
        return 4;
      case TaskStatusType.archived:
        return 5;
      case TaskStatusType.deleted:
        return 6;
      case TaskStatusType.someday:
        return 7;
      case TaskStatusType.hidden:
        return 8;
      case TaskStatusType.permanentlyDeleted:
        return 9;
    }
  }
}

extension TaskExt on Task {
  bool get isToday {
    if (date != null) {
      return date!.day == DateTime.now().day &&
          date!.month == DateTime.now().month &&
          date!.year == DateTime.now().year;
    }

    return false;
  }

  bool get isTomorrow {
    if (date != null) {
      return date!.day == DateTime.now().day + 1 &&
          date!.month == DateTime.now().month &&
          date!.year == DateTime.now().year;
    }

    return false;
  }

  bool get isTodayOrBefore {
    if (date != null) {
      return date!.day <= DateTime.now().day &&
          date!.month <= DateTime.now().month &&
          date!.year <= DateTime.now().year;
    }

    return false;
  }

  bool get isOverdue {
    if (date != null) {
      return date!.day < DateTime.now().day;
    }

    return false;
  }

  bool get isCompletedComputed {
    return (statusType == TaskStatusType.completed ||
        (done ?? false) ||
        doneAt != null);
  }

  String get shortDate {
    if (date != null) {
      if (isToday) {
        return t.task.today;
      } else if (date!.isBefore(DateTime.now().add(const Duration(days: 6)))) {
        return DateFormat.E().format(date!.toLocal());
      } else {
        return DateFormat.MMMd().format(date!.toLocal());
      }
    }

    return '';
  }

  String get datetimeFormatted {
    if (datetime != null) {
      return DateFormat("EEE hh:mm").format(datetime!.toLocal());
    }

    return '';
  }

  String get doneAtFormatted {
    if (doneAt != null) {
      return timeago.format(doneAt!.toLocal());
    }

    return '';
  }

  TaskStatusType? get statusType {
    switch (status) {
      case 1:
        return TaskStatusType.inbox;
      case 2:
        return TaskStatusType.planned;
      case 3:
        return TaskStatusType.completed;
      case 4:
        return TaskStatusType.snoozed;
      case 5:
        return TaskStatusType.archived;
      case 6:
        return TaskStatusType.deleted;
      case 7:
        return TaskStatusType.someday;
      case 8:
        return TaskStatusType.hidden;
      case 9:
        return TaskStatusType.permanentlyDeleted;
      default:
        return null;
    }
  }

  static List<Task> filterInboxTasks(List<Task> tasks) {
    tasks.removeWhere((task) => task.deletedAt != null);

    tasks.removeWhere((element) => element.done == true);

    tasks.removeWhere((element) => element.doneAt != null);

    tasks.removeWhere((element) => element.statusType != TaskStatusType.inbox);

    return tasks;
  }

  static List<Task> filterTodayTasks(List<Task> tasks) {
    tasks.removeWhere((task) => task.deletedAt != null);

    tasks.removeWhere((task) => task.status == TaskStatusType.deleted.id);

    tasks.removeWhere((element) => element.done == true);

    tasks.removeWhere((element) => element.doneAt != null);

    tasks.removeWhere((task) => !task.isTodayOrBefore);

    return tasks;
  }

  static List<Task> sort(
    List<Task> tasks, {
    required TaskListSorting? sorting,
  }) {
    tasks.sort((a, b) {
      try {
        if (sorting == TaskListSorting.ascending) {
          return a.sorting! < b.sorting! ? 1 : -1;
        } else {
          return a.sorting! > b.sorting! ? 1 : -1;
        }
      } catch (_) {
        return 0;
      }
    });

    return tasks;
  }
}
