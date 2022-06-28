import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/actions/recurrence_modal.dart';
import 'package:mobile/features/edit_task/ui/edit_task_modal.dart';
import 'package:mobile/features/edit_task/ui/recurring_edit_dialog.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/utils/tz_utils.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/doc/asana_doc.dart';
import 'package:models/doc/click_up_doc.dart';
import 'package:models/doc/doc.dart';
import 'package:models/doc/gmail_doc.dart';
import 'package:models/doc/notion_doc.dart';
import 'package:models/doc/slack_doc.dart';
import 'package:models/doc/todoist_doc.dart';
import 'package:models/doc/trello_doc.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';
import 'package:rrule/rrule.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

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
    if (date != null) {
      DateTime dateParsed = DateTime.parse(date!);
      return dateParsed.day == ofDate.day && dateParsed.month == ofDate.month && dateParsed.year == ofDate.year;
    }

    return false;
  }

  bool get isToday {
    DateTime now = DateTime.now();

    bool isDateToday = false;
    bool isDatetimeToday = false;

    if (date != null) {
      DateTime dateParsed = DateTime.parse(date!);
      isDateToday = dateParsed.day == now.day && dateParsed.month == now.month && dateParsed.year == now.year;
    }

    if (datetime != null) {
      DateTime dateParsed = DateTime.parse(datetime!).toLocal();
      isDatetimeToday = dateParsed.day == now.day && dateParsed.month == now.month && dateParsed.year == now.year;
    }

    return isDateToday || isDatetimeToday;
  }

  bool get isTomorrow {
    if (datetime != null) {
      DateTime dateParsed = DateTime.parse(datetime!).toLocal();
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

  bool get isYesterday {
    if (datetime != null) {
      DateTime dateParsed = DateTime.parse(datetime!).toLocal();
      return dateParsed.day == DateTime.now().day - 1 &&
          dateParsed.month == DateTime.now().month &&
          dateParsed.year == DateTime.now().year;
    }

    if (date != null) {
      DateTime dateParsed = DateTime.parse(date!);
      return dateParsed.day == DateTime.now().day - 1 &&
          dateParsed.month == DateTime.now().month &&
          dateParsed.year == DateTime.now().year;
    }

    return false;
  }

  bool get isTodayOrBefore {
    if (isToday) return true;

    DateTime now = DateTime.now();

    bool isDateBefore = false;
    bool isDatetimeBefore = false;

    if (date != null) {
      DateTime dateParsed = DateTime.parse(date!);
      isDateBefore = dateParsed.isBefore(now);
    }

    if (datetime != null) {
      DateTime dateParsed = DateTime.parse(datetime!).toLocal();
      isDatetimeBefore = dateParsed.isBefore(now);
    }

    return isDateBefore || isDatetimeBefore;
  }

  DateTime? get endTime {
    try {
      return DateTime.parse(datetime!).toLocal().add(Duration(seconds: duration!));
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
      isOverdueDate = endTimePlus1h.toLocal().isBefore(now);
    } else if (date != null && !isToday) {
      isOverdueDate = DateTime.parse(date!).isBefore(now);
    }

    return isPlanned && !isCompletedComputed && isOverdueDate;
  }

  bool get isCompletedComputed {
    return ((done ?? false) == true);
  }

  String get createdAtFormatted {
    if (createdAt != null) {
      DateTime dateParsed = DateTime.parse(createdAt!).toLocal();
      return DateFormat('dd MMM yyyy').format(dateParsed);
    }

    return '';
  }

  String get dueDateFormatted {
    if (dueDate != null) {
      DateTime dateParsed = DateTime.parse(dueDate!).toLocal();
      return DateFormat('dd MMM yyyy').format(dateParsed);
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

        if (recurrenceString.isEmpty) {
          return RecurrenceModalType.none;
        }

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

  String get timeFormatted {
    if (datetime != null) {
      DateTime dateParsed = DateTime.parse(datetime!).toLocal();

      if (isToday) {
        return DateFormat.Hm().format(dateParsed);
      } else if (isTomorrow) {
        return DateFormat.Hm().format(dateParsed);
      } else {
        return DateFormat.Hm().format(dateParsed);
      }
    }

    return '';
  }

  String get datetimeFormatted {
    String prefix;
    String? formatted;

    if (datetime != null) {
      prefix = "";
      formatted = DateFormat("HH:mm").format(DateTime.parse(datetime!).toLocal());
    } else if (date != null) {
      prefix = "";
      formatted = t.task.today;
    }

    if (isToday) {
      prefix = t.addTask.today;
    } else if (isTomorrow) {
      prefix = t.addTask.tmw;
    } else {
      prefix = DateFormat("dd MMM").format(DateTime.parse(datetime!).toLocal());
    }

    if (formatted != null) {
      return "$prefix${prefix.isNotEmpty ? ' ' : ''}$formatted";
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
      return DateFormat("EEE, d MMM").format(DateTime.parse(date!));
    }

    return '';
  }

  bool get isDeleted {
    return status == TaskStatusType.deleted.id || deletedAt != null;
  }

  bool get isPinnedInCalendar {
    return datetime != null && !isOverdue;
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

  bool get isSnoozed {
    return status == TaskStatusType.snoozed.id;
  }

  bool get isSomeday {
    return status == TaskStatusType.someday.id;
  }

  String get eventLockInCalendar {
    return content?["eventLockInCalendar"] != null ? content["eventLockInCalendar"] : "private";
  }

  DateTime? get dateParsed {
    if (date != null) {
      return DateTime.parse(date!);
    }

    return null;
  }

  DateTime? get sortingParsed {
    if (sorting != null) {
      return DateTime.fromMillisecondsSinceEpoch(sorting!).toLocal();
    }

    return null;
  }

  DateTime? get sortingLabelParsed {
    if (sortingLabel != null) {
      return DateTime.fromMillisecondsSinceEpoch(sortingLabel!).toLocal();
    }

    return null;
  }

  String computedIcon(Doc? doc) {
    if (connectorId != null) {
      return iconFromConnectorId(connectorId);
    } else {
      return iconFromConnectorId(doc?.connectorId);
    }
  }

  static String iconFromConnectorId(String? connectorId) {
    switch (connectorId) {
      case "asana":
        return "assets/images/icons/asana/asana.svg";
      case "clickup":
        return "assets/images/icons/clickup/clickup.svg";
      case "dropbox":
        return "assets/images/icons/dropbox/dropbox.svg";
      case "google":
        return "assets/images/icons/google/google.svg";
      case "gmail":
        return "assets/images/icons/google/gmail.svg";
      case "jira":
        return "assets/images/icons/jira/jira.svg";
      case "skype":
        return "assets/images/icons/skype/skype.svg";
      case "teams":
        return "assets/images/icons/teams/teams.svg";
      case "notion":
        return "assets/images/icons/notion/notion.svg";
      case "slack":
        return "assets/images/icons/slack/slack.svg";
      case "superhuman":
        return "assets/images/icons/superhuman/superhuman-grey-dark.svg";
      case "todoist":
        return "assets/images/icons/todoist/todoist.svg";
      case "trello":
        return "assets/images/icons/trello/trello.svg";
      case "twitter":
        return "assets/images/icons/twitter/twitter.svg";
      case "zapier":
        return "assets/images/icons/zapier/zapier.svg";
      case "zoom":
        return "assets/images/icons/zoom/zoom.svg";
      default:
        return "assets/images/icons/_common/info.svg";
    }
  }

  static bool hasRecurringDataChanges({required Task original, required Task updated}) {
    bool askEditThisOrFutureTasks = TaskExt.hasEditedData(original: original, updated: updated);
    bool hasEditedTimings = TaskExt.hasEditedTimings(original: original, updated: updated);
    bool hasEditedCalendar = TaskExt.hasEditedCalendar(original: original, updated: updated);
    bool hasEditedDelete = TaskExt.hasEditedDelete(original: original, updated: updated);

    return updated.recurringId != null &&
        (askEditThisOrFutureTasks || hasEditedTimings || hasEditedCalendar || hasEditedDelete);
  }

  static bool hasDataChanges({required Task original, required Task updated}) {
    bool askEditThisOrFutureTasks = TaskExt.hasEditedData(original: original, updated: updated);
    bool hasEditedTimings = TaskExt.hasEditedTimings(original: original, updated: updated);
    bool hasEditedCalendar = TaskExt.hasEditedCalendar(original: original, updated: updated);
    bool hasEditedDelete = TaskExt.hasEditedDelete(original: original, updated: updated);

    return askEditThisOrFutureTasks || hasEditedTimings || hasEditedCalendar || hasEditedDelete;
  }

  static bool hasEditedData({required Task original, required Task updated}) {
    return original.title != updated.title ||
        original.priority != updated.priority ||
        original.dailyGoal != (updated.dailyGoal != null ? updated.dailyGoal!.toInt() : null) ||
        (original.eventLockInCalendar != updated.eventLockInCalendar) ||
        original.duration != updated.duration ||
        original.description != updated.description ||
        original.listId != updated.listId ||
        original.sectionId != updated.sectionId ||
        original.dueDate != updated.dueDate ||
        ((original.links ?? []).length != (updated.links ?? []).length ||
            (original.links ?? []).any((element) => !(updated.links ?? []).contains(element)));
  }

  static bool hasEditedTimings({required Task original, required Task updated}) {
    bool hasEditedDate = original.status == TaskStatusType.planned.id && original.date != updated.date;
    bool hasEditedDateTime = original.status == TaskStatusType.planned.id && original.datetime != updated.datetime;

    return hasEditedDate || hasEditedDateTime;
  }

  static bool hasEditedRepetition({required Task original, required Task updated}) {
    return original.recurrence != updated.recurrence;
  }

  static bool hasEditedDelete({required Task original, required Task updated}) {
    return original.deletedAt != updated.deletedAt;
  }

  static bool hasEditedCalendar({required Task original, required Task updated}) {
    return original.content?["calendarUniqueId"] != updated.content?["calendarUniqueId"];
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
    required TaskListSorting sorting,
  }) {
    if (sorting == TaskListSorting.none) {
      return tasks;
    }

    tasks.sort((a, b) {
      try {
        switch (sorting) {
          case TaskListSorting.sortingAscending:
            return a.sortingParsed!.compareTo(b.sortingParsed!);
          case TaskListSorting.sortingDescending:
            return a.sortingParsed!.compareTo(b.sortingParsed!) * -1;
          case TaskListSorting.sortingLabelAscending:
            return a.sortingLabelParsed!.compareTo(b.sortingLabelParsed!);
          case TaskListSorting.dateAscending:
            return a.dateParsed!.compareTo(b.dateParsed!);
          case TaskListSorting.doneAtDescending:
            return a.doneAt!.compareTo(b.doneAt!) * -1;
          case TaskListSorting.none:
            return 0;
        }
      } catch (_) {
        return 0;
      }
    });

    return tasks;
  }

  static String? iconNetworkFromUrl(String? url) {
    try {
      url = !url!.startsWith('http://') && !url.startsWith('https://') ? 'http://$url' : url;
      Uri origin = Uri.parse(url);
      return "https://www.google.com/s2/favicons?sz=24&domain=$origin";
    } catch (_) {}

    return null;
  }

  static String? iconAssetFromUrl(String? url) {
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

    return null;
  }

  Task markAsDone(Task originalTask) {
    bool done = isCompletedComputed;

    String? now = TzUtils.toUtcStringIfNotNull(DateTime.now());

    Task updated = copyWith();

    if (!done) {
      updated = updated.copyWith(
        done: true,
        doneAt: Nullable(now),
      );

      if (status == TaskStatusType.inbox.id ||
          status == TaskStatusType.snoozed.id ||
          status == TaskStatusType.someday.id) {
        updated = updated.copyWith(
          date: Nullable(now),
          datetime: Nullable(null),
          status: Nullable(TaskStatusType.planned.id),
        );
      }
    } else {
      updated = updated.copyWith(
        done: false,
        doneAt: Nullable(null),
        date: Nullable(originalTask.date),
        datetime: Nullable(originalTask.datetime),
        status: Nullable(originalTask.status),
      );
    }

    if (readAt == null) {
      updated = updated.copyWith(readAt: now);
    }

    updated = updated.copyWith(updatedAt: Nullable(now));

    return updated;
  }

  TaskStatusType get statusBasedOnValue {
    if (date != null || datetime != null) {
      return TaskStatusType.planned;
    } else {
      return TaskStatusType.inbox;
    }
  }

  String get descriptionParsed {
    try {
      var document = parse(description);

      return (document.body?.nodes ?? []).map((node) => node.text).join(' ').trim();
    } catch (_) {}

    return '';
  }

  static List<Task> filterCompletedTodayOrBeforeTasks(List<Task> tasks) {
    List<Task> completed = List.from(tasks.where((element) => element.isCompletedComputed));
    return completed.where((element) => element.isTodayOrBefore).toList();
  }

  static int countTasksSelected(TasksCubitState state) {
    int selectedInbox = state.inboxTasks.where((element) => element.selected ?? false).toList().length;

    List<Task> selectedDayTasks = state.selectedDayTasks.where((element) => element.selected ?? false).toList();
    int selectedDayCount = selectedDayTasks.where((element) => !state.labelTasks.contains(element)).toList().length;

    List<Task> labelTasks = state.labelTasks.where((element) => element.selected ?? false).toList();
    int selectedLabelCount = labelTasks.where((element) => !state.inboxTasks.contains(element)).toList().length;

    return selectedInbox + selectedDayCount + selectedLabelCount;
  }

  static bool isSelectMode(TasksCubitState state) {
    return countTasksSelected(state) != 0;
  }

  static bool hasData(Task updatedTask) {
    return updatedTask.title != null ||
        updatedTask.description != null ||
        updatedTask.date != null ||
        updatedTask.datetime != null ||
        updatedTask.status != 1 ||
        updatedTask.duration != null ||
        updatedTask.listId != null;
  }

  static Doc _fromBuiltinDoc(Task task) {
    return Doc(
      taskId: task.id,
      title: task.title,
      description: task.description,
      connectorId: task.connectorId,
      originId: task.originId,
      accountId: task.originAccountId,
      url: task.doc?['url'],
      localUrl: task.doc?['local_url'],
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      deletedAt: task.deletedAt,
      globalUpdatedAt: task.globalUpdatedAt,
      globalCreatedAt: task.globalCreatedAt,
      remoteUpdatedAt: task.remoteUpdatedAt,
      content: task.doc,
    );
  }

  Doc? computedDoc(Doc? doc) {
    String? connectorId = doc?.connectorId ?? this.connectorId;

    if (connectorId == null) {
      return null;
    }

    doc = doc ?? _fromBuiltinDoc(this);

    switch (connectorId) {
      case "asana":
        return AsanaDoc(doc);
      case "clickup":
        return ClickupDoc(doc);
      case "gmail":
        return GmailDoc(doc);
      case "notion":
        return NotionDoc(doc);
      case "slack":
        if (this.doc != null) {
          return SlackDoc(_fromBuiltinDoc(this));
        } else {
          return SlackDoc(doc);
        }
      case "todoist":
        if (this.doc != null) {
          return TodoistDoc(_fromBuiltinDoc(this));
        } else {
          return TodoistDoc(doc);
        }
      case "trello":
        return TrelloDoc(doc);
      default:
        return null;
    }
  }

  static Future<void> editTask(BuildContext context, Task task) async {
    TasksCubit tasksCubit = context.read<TasksCubit>();
    SyncCubit syncCubit = context.read<SyncCubit>();

    EditTaskCubit editTaskCubit = EditTaskCubit(tasksCubit, syncCubit)..attachTask(task);

    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => editTaskCubit,
        child: const EditTaskModal(),
      ),
    );

    Task updated = editTaskCubit.state.updatedTask;
    Task original = editTaskCubit.state.originalTask;

    if (updated == original) {
      return;
    }

    if (TaskExt.hasRecurringDataChanges(original: original, updated: updated)) {
      showDialog(
          context: context,
          builder: (context) => RecurringEditDialog(
                onlyThisTap: () {
                  editTaskCubit.modalDismissed();
                },
                allTap: () {
                  editTaskCubit.modalDismissed(updateAllFuture: true);
                },
              ));
    } else {
      editTaskCubit.modalDismissed();
    }

    if (updated.isCompletedComputed != original.isCompletedComputed) {
      tasksCubit.handleDocAction([updated]);
    }
  }

  Future<void> openLinkedContentUrl([Doc? doc]) async {
    String? localUrl = doc?.localUrl ?? doc?.content?["local_url"] ?? content?["local_url"];

    if (localUrl == null || localUrl.isEmpty) {
      localUrl = doc?.url ?? '';
    }

    Uri uri = Uri.parse(localUrl);

    bool opened;

    if (uri.host == "mail.google.com") {
      opened = await launchUrl(Uri.parse("googlegmail://"), mode: LaunchMode.externalApplication);
    } else {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    if (opened == false) {
      launchUrl(Uri.parse(doc?.url ?? ''), mode: LaunchMode.externalApplication);
    }
  }
}
