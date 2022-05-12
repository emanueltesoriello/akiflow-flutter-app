import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/features/edit_task/ui/actions/recurrence_modal.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';
import 'package:rrule/rrule.dart';
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

  static TaskStatusType? fromId(int? id) {
    switch (id) {
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
}

extension TaskExt on Task {
  bool isSameDateOf(DateTime ofDate) {
    if (datetime != null) {
      DateTime dateParsed = DateTime.parse(datetime!);
      return dateParsed.day == ofDate.day && dateParsed.month == ofDate.month && dateParsed.year == ofDate.year;
    }

    if (date != null) {
      DateTime dateParsed = DateTime.parse(date!);
      return dateParsed.day == ofDate.day && dateParsed.month == ofDate.month && dateParsed.year == ofDate.year;
    }

    return false;
  }

  bool get isToday {
    if (datetime != null) {
      DateTime dateParsed = DateTime.parse(datetime!);
      return dateParsed.day == DateTime.now().day &&
          dateParsed.month == DateTime.now().month &&
          dateParsed.year == DateTime.now().year;
    }

    if (date != null) {
      DateTime dateParsed = DateTime.parse(date!);
      return dateParsed.day == DateTime.now().day &&
          dateParsed.month == DateTime.now().month &&
          dateParsed.year == DateTime.now().year;
    }

    return false;
  }

  bool get isTomorrow {
    if (datetime != null) {
      DateTime dateParsed = DateTime.parse(datetime!);
      return dateParsed.day == DateTime.now().day + 1 &&
          dateParsed.month == DateTime.now().month &&
          dateParsed.year == DateTime.now().year;
    }

    if (date != null) {
      DateTime dateParsed = DateTime.parse(date!);
      return dateParsed.day == DateTime.now().day + 1 &&
          dateParsed.month == DateTime.now().month &&
          dateParsed.year == DateTime.now().year;
    }

    return false;
  }

  bool get isTodayOrBefore {
    if (datetime != null) {
      DateTime dateParsed = DateTime.parse(datetime!);
      return dateParsed.day <= DateTime.now().day &&
          dateParsed.month <= DateTime.now().month &&
          dateParsed.year <= DateTime.now().year;
    }

    if (date != null) {
      DateTime dateParsed = DateTime.parse(date!);
      return dateParsed.day <= DateTime.now().day &&
          dateParsed.month <= DateTime.now().month &&
          dateParsed.year <= DateTime.now().year;
    }

    return false;
  }

  DateTime? get endTime {
    try {
      return DateTime.parse(datetime!).add(Duration(seconds: duration!));
    } catch (_) {}
    return null;
  }

  bool get isPlanned {
    return status == TaskStatusType.planned.id && date != null;
  }

  bool get isOverdue {
    final DateTime now = DateTime.now();

    bool isOverdueDate = false;

    if (endTime != null) {
      DateTime endTimePlus1h = endTime!.add(const Duration(hours: 1));
      isOverdueDate = endTimePlus1h.isBefore(now);
    } else if (date != null) {
      isOverdueDate = DateTime.parse(date!).isBefore(now);
    }

    return isPlanned && !isCompletedComputed && isOverdueDate;
  }

  bool get isCompletedComputed {
    return (statusType == TaskStatusType.completed || (done ?? false) || doneAt != null);
  }

  String get shortDate {
    if (date != null) {
      DateTime dateParsed = DateTime.parse(date!);
      if (isToday) {
        return t.task.today;
      } else if (dateParsed.isBefore(DateTime.now().add(const Duration(days: 6)))) {
        return DateFormat.E().format(dateParsed.toLocal());
      } else {
        return DateFormat.MMMd().format(dateParsed.toLocal());
      }
    }

    return '';
  }

  String get createdAtFormatted {
    if (createdAt != null) {
      DateTime dateParsed = DateTime.parse(createdAt!);
      return DateFormat('dd MMM yyyy').format(dateParsed.toLocal());
    }

    return '';
  }

  String get dueDateFormatted {
    if (dueDate != null) {
      DateTime dateParsed = DateTime.parse(dueDate!);
      return DateFormat('dd MMM yyyy').format(dateParsed.toLocal());
    }

    return '';
  }

  RecurrenceModalType? get recurrenceComputed {
    if (recurrence != null) {
      try {
        List<String> parts = recurrence!.toList();

        parts.removeWhere((part) => part.startsWith('UNTIL'));
        parts.removeWhere((part) => part.startsWith('DTSTART'));

        String recurrenceString = parts.join(';');

        RecurrenceRule rule = RecurrenceRule.fromString(recurrenceString);

        if (rule.frequency == Frequency.daily) {
          return RecurrenceModalType.daily;
        } else if (rule.frequency == Frequency.weekly && rule.byWeekDays.length == 5) {
          return RecurrenceModalType.everyWeekday;
        } else if (rule.frequency == Frequency.yearly) {
          return RecurrenceModalType.everyYearOnThisDay;
        } else if (rule.frequency == Frequency.weekly) {
          return RecurrenceModalType.everyCurrentDay;
        }
      } catch (e) {
        print("Recurrence parsing error: $e");
      }
    }

    return RecurrenceModalType.none;
  }

  String get datetimeFormatted {
    String? datetimeOrDate = datetime ?? date;

    String prefix;
    String? formatted;

    if (datetimeOrDate != null) {
      formatted = DateFormat("HH:mm").format(DateTime.parse(datetimeOrDate).toLocal());
    }

    if (isToday) {
      prefix = t.task.today;
    } else if (isTomorrow) {
      prefix = t.addTask.tmw;
    } else {
      prefix = "";
    }

    if (formatted != null) {
      return "$prefix $formatted";
    } else {
      return prefix;
    }
  }

  String get doneAtFormatted {
    if (doneAt != null) {
      return timeago.format(DateTime.parse(doneAt!).toLocal());
    }

    return '';
  }

  String get overdueFormatted {
    if (isOverdue) {
      return DateFormat("EEE, d MMM").format(DateTime.parse(date!).toLocal());
    }

    return '';
  }

  bool get isDeleted {
    return status == TaskStatusType.deleted.id || deletedAt != null;
  }

  bool get isPinnedInCalendar {
    return date != null && datetime != null;
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
    tasks.removeWhere((element) => element.statusType != TaskStatusType.inbox);
    tasks.removeWhere((task) => task.isDeleted);
    return List.from(tasks);
  }

  static List<Task> filterTodayTodoTasks(List<Task> tasks) {
    List<Task> todos = tasks
        .where((element) =>
            (!element.isCompletedComputed && element.datetime == null) ||
            (element.isOverdue && element.datetime != null))
        .toList();

    return List.from(todos);
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

  static String iconAssetFromUrl(String? url) {
    if (url != null) {
      if (url.contains('asana.com') || url.startsWith('asanadesktop://')) {
        return 'assets/images/icons/asana/asana.svg';
      }
      if (url.contains('notion.so') || url.startsWith('notion://')) {
        return 'assets/images/icons/notion/notion.svg';
      }
      if (url.contains('.todoist.com') || url.startsWith('todoist://')) {
        return 'assets/images/icons/todoist/todoist.svg';
      }
      if (url.contains('.clickup.com') || url.startsWith('clickup://')) {
        return 'assets/images/icons/clickup/clickup.svg';
      }
      if (url.startsWith('superhuman://')) {
        return 'assets/images/icons/superhuman/superhuman.png';
      }
      if (url.contains('mail.google.com')) {
        return 'assets/images/icons/google/gmail.svg';
      }
      if (url.contains('docs.google.com/spreadsheets')) {
        return 'assets/images/favicons/google-spreadsheets.png';
      }
      if (url.contains('docs.google.com/presentation')) {
        return 'assets/images/favicons/google-presentation.png';
      }
      if (url.contains('docs.google.com/document')) {
        return 'assets/images/favicons/google-document.png';
      }
      if (url.contains('docs.google.com/forms')) {
        return 'assets/images/favicons/google-forms.png';
      }
      if (url.contains('google.com')) {
        return 'assets/images/icons/google/google.svg';
      }
    }

    return 'assets/images/icons/_common/circle.svg';
  }

  Task planFor({
    required DateTime? date,
    DateTime? dateTime,
    required int status,
  }) {
    return copyWith(
      date: Nullable(date?.toUtc().toIso8601String()),
      datetime: dateTime?.toUtc().toIso8601String(),
      status: status,
    );
  }

  Task markAsDone({
    TaskStatusType? lastDoneTaskStatus,
    required Function(TaskStatusType?) onDone,
  }) {
    print(isCompletedComputed);

    bool done = isCompletedComputed;

    DateTime now = DateTime.now().toUtc();

    if (lastDoneTaskStatus != null && lastDoneTaskStatus.id != TaskStatusType.completed.id) {
      lastDoneTaskStatus = TaskStatusTypeExt.fromId(lastDoneTaskStatus.id);
    }

    Task updated;

    if (!done) {
      updated = copyWith(
        done: true,
        doneAt: Nullable(now.toIso8601String()),
        updatedAt: Nullable(now.toIso8601String()),
        status: TaskStatusType.completed.id,
      );
    } else {
      updated = copyWith(
        done: false,
        doneAt: Nullable(null),
        updatedAt: Nullable(now.toIso8601String()),
        status: lastDoneTaskStatus?.id,
      );
    }

    onDone(lastDoneTaskStatus);

    return updated;
  }

  Task delete() {
    return copyWith(
      status: TaskStatusType.deleted.id,
      deletedAt: (DateTime.now().toUtc().toIso8601String()),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );
  }

  static List<Task> filterCompletedTodayOrBeforeTasks(List<Task> tasks) {
    List<Task> completed = List.from(tasks.where((element) => element.isCompletedComputed));
    return completed.where((element) => element.isTodayOrBefore).toList();
  }
}
