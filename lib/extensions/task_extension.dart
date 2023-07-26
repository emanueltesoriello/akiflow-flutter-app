import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/parser.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/utils/tz_utils.dart';
import 'package:mobile/common/utils/user_settings_utils.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/task/task_list.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_modal.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/recurring_edit_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/recurrence/recurrence_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/doc/asana_doc.dart';
import 'package:models/doc/click_up_doc.dart';
import 'package:models/doc/github_doc.dart';
import 'package:models/doc/gmail_doc.dart';
import 'package:models/doc/jira_doc.dart';
import 'package:models/doc/notion_doc.dart';
import 'package:models/doc/slack_doc.dart';
import 'package:models/doc/todoist_doc.dart';
import 'package:models/doc/trello_doc.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';
import 'package:rrule/rrule.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:audio_session/audio_session.dart';

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
  permanentlyDeleted,
  trashed, // same as above
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
      case TaskStatusType.trashed:
        return 10;
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
      case 10:
        return TaskStatusType.trashed;
      default:
        return null;
    }
  }
}

extension TaskExt on Task {
  bool isSameDateOf(DateTime ofDate) {
    ofDate = DateTime(
        ofDate.year, ofDate.month, ofDate.day, DateTime.now().hour, DateTime.now().minute, DateTime.now().second);

    if (datetime != null) {
      DateTime selectedLocalDate = ofDate;
      DateTime dateParsed = DateTime.parse(datetime!);

      return dateParsed.toLocal().day == selectedLocalDate.day &&
          dateParsed.toLocal().month == selectedLocalDate.month &&
          dateParsed.toLocal().year == selectedLocalDate.year;
    } else if (date != null) {
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

  String get internalDateFormatted {
    DateTime? internalDate;

    if (doc?.internalDate != null) {
      int internalDateAsMilliseconds = int.parse(doc!.internalDate!);
      internalDate = DateTime.fromMillisecondsSinceEpoch(internalDateAsMilliseconds).toLocal();
    }

    if (internalDate != null) {
      if (internalDate.toLocal().day == DateTime.now().day &&
          internalDate.toLocal().month == DateTime.now().month &&
          internalDate.toLocal().year == DateTime.now().year) {
        return t.task.today;
      } else {
        return DateFormat("dd MMM yyyy").format(internalDate.toLocal());
      }
    } else {
      return '';
    }
  }

  String get dueDateFormatted {
    if (dueDate != null) {
      DateTime dateParsed = DateTime.parse(dueDate!).toLocal();
      return DateFormat('dd MMM yyyy').format(dateParsed);
    }

    return '';
  }

  RecurrenceRule? get ruleFromStringList {
    if (recurrence != null) {
      try {
        List<String> parts = recurrence!.first.split(";");

        parts.removeWhere((part) => part.startsWith('DTSTART'));

        String recurrenceString = parts.join(';');
        return RecurrenceRule.fromString(recurrenceString);
      } catch (e) {
        print("Recurrence from String parsing error: $e");
      }
    }
    return null;
  }

  RecurrenceModalType? get recurrenceComputed {
    if (recurrence != null) {
      try {
        List<String> parts = recurrence!.first.split(";");

        parts.removeWhere((part) => part.startsWith('UNTIL'));
        parts.removeWhere((part) => part.startsWith('DTSTART'));

        String recurrenceString = parts.join(';');

        if (recurrenceString.isEmpty) {
          return RecurrenceModalType.none;
        }

        RecurrenceRule rule = RecurrenceRule.fromString(recurrenceString);

        if (rule.frequency == Frequency.daily && rule.interval == null) {
          return RecurrenceModalType.daily;
        } else if (rule.frequency == Frequency.weekly && rule.byWeekDays.length == 5) {
          return RecurrenceModalType.everyWeekday;
        } else if (rule.frequency == Frequency.yearly && rule.interval == null) {
          return RecurrenceModalType.everyYearOnThisDay;
        } else if (rule.frequency == Frequency.monthly && rule.interval == null && !rule.hasByMonthDays) {
          return RecurrenceModalType.everyMonthOnThisDay;
        } else if (rule.frequency == Frequency.monthly && (rule.hasByMonthDays || rule.hasBySetPositions)) {
          return RecurrenceModalType.everyLastDayOfTheMonth;
        } else if (rule.frequency == Frequency.weekly && rule.interval == null) {
          return RecurrenceModalType.everyCurrentDay;
        } else if (rule.interval != null || rule.byWeekDays.length > 1) {
          return RecurrenceModalType.custom;
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
      if (datetime != null) {
        prefix = DateFormat("dd MMM").format(DateTime.tryParse(datetime!)!.toLocal());
      } else {
        prefix = '';
      }
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
      case 10:
        return TaskStatusType.trashed;
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

  String computedIcon() {
    if (connectorId != null) {
      return iconFromConnectorId(connectorId?.value);
    }
    return '';
  }

  bool get isDailyGoal {
    try {
      return dailyGoal! == 1;
    } catch (_) {
      return false;
    }
  }

  static String iconFromConnectorId(String? connectorId) {
    switch (connectorId) {
      case "asana":
        return Assets.images.icons.asana.asanaSVG;
      case "clickup":
        return Assets.images.icons.clickup.clickupSVG;
      case "dropbox":
        return Assets.images.icons.dropbox.dropboxSVG;
      case "github":
        return Assets.images.icons.github.githubSVG;
      case "google":
        return Assets.images.icons.google.calendarSVG;
      case "gmail":
        return Assets.images.icons.google.gmailSVG;
      case "jira":
        return Assets.images.icons.jira.jiraSVG;
      case "skype":
        return Assets.images.icons.skype.skypeSVG;
      case "teams":
        return Assets.images.icons.teams.teamsSVG;
      case "notion":
        return Assets.images.icons.notion.notionSVG;
      case "slack":
        return Assets.images.icons.slack.slackSVG;
      case "superhuman":
        return Assets.images.icons.superhuman.superhumanGreyDarkSVG;
      case "todoist":
        return Assets.images.icons.todoist.todoistSVG;
      case "trello":
        return Assets.images.icons.trello.trelloSVG;
      case "twitter":
        return Assets.images.icons.twitter.twitterSVG;
      case "zapier":
        return Assets.images.icons.zapier.zapierSVG;
      case "zoom":
        return Assets.images.icons.zoom.zoomSVG;
      default:
        return Assets.images.icons.common.infoSVG;
    }
  }

  static bool hasRecurringDataChanges({required Task original, required Task updated}) {
    bool askEditThisOrFutureTasks = TaskExt.hasEditedData(original: original, updated: updated);
    bool hasEditedTimings = TaskExt.hasEditedTimings(original: original, updated: updated);
    bool hasEditedCalendar = TaskExt.hasEditedCalendar(original: original, updated: updated);
    bool hasEditedDelete = TaskExt.hasEditedDelete(original: original, updated: updated);

    if (original.recurringId == null) {
      return false;
    }
    return updated.recurringId != null &&
        (askEditThisOrFutureTasks || hasEditedTimings || hasEditedCalendar || hasEditedDelete);
  }

  static bool hasDataChanges({
    required Task original,
    required Task updated,
    bool includeListIdAndSectionId = true,
  }) {
    bool askEditThisOrFutureTasks = TaskExt.hasEditedData(
        original: original, updated: updated, includeListIdAndSectionId: includeListIdAndSectionId);
    bool hasEditedTimings = TaskExt.hasEditedTimings(original: original, updated: updated);
    bool hasEditedCalendar = TaskExt.hasEditedCalendar(original: original, updated: updated);
    bool hasEditedDelete = TaskExt.hasEditedDelete(original: original, updated: updated);

    return askEditThisOrFutureTasks || hasEditedTimings || hasEditedCalendar || hasEditedDelete;
  }

  static bool hasEditedData({required Task original, required Task updated, bool includeListIdAndSectionId = true}) {
    return original.title != updated.title ||
        original.priority != updated.priority ||
        original.dailyGoal != (updated.dailyGoal != null ? updated.dailyGoal!.toInt() : null) ||
        (original.eventLockInCalendar != updated.eventLockInCalendar) ||
        original.duration != updated.duration ||
        original.description != updated.description ||
        (original.listId != updated.listId && includeListIdAndSectionId) ||
        (original.sectionId != updated.sectionId && includeListIdAndSectionId) ||
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

  static bool hasEditedListId({required Task original, required Task updated}) {
    return original.listId != updated.listId;
  }

  static bool hasEditedSectionId({required Task original, required Task updated}) {
    return original.sectionId != updated.sectionId;
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
    url = !url!.startsWith('http://') && !url.startsWith('https://') ? 'http://$url' : url;
    return "https://favicon.akiflow.com/?url=$url";
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

  dynamic computedDoc() {
    String? connectorId = this.connectorId?.value;

    if (connectorId == null) {
      return null;
    }
    try {
      switch (connectorId) {
        case "asana":
          return AsanaDoc.fromMap(doc)..setTitle(title);
        case "clickup":
          return ClickupDoc.fromMap(doc)..setTitle(title);
        case "github":
          return GithubDoc.fromMap(doc)..setTitle(title);
        case "gmail":
          return GmailDoc.fromMap(doc)..setTitle(title);
        case "jira":
          return JiraDoc.fromMap(doc)..setTitle(title);
        case "notion":
          return NotionDoc.fromMap(doc)..setTitle(title);
        case "slack":
          return SlackDoc.fromMap(doc);
        case "todoist":
          return TodoistDoc.fromMap(doc)..setTitle(title);
        case "trello":
          return TrelloDoc.fromMap(doc)..setTitle(title);
        default:
          return null;
      }
    } catch (e) {
      locator<SentryService>()
          .addBreadcrumb(category: 'doc', message: 'Error computing doc for task: $id - message: $e');
    }
  }

  static Future<void> editTask(BuildContext context, Task task) async {
    TasksCubit tasksCubit = context.read<TasksCubit>();
    SyncCubit syncCubit = context.read<SyncCubit>();
    EditTaskCubit editTaskCubit = EditTaskCubit(tasksCubit, syncCubit)..attachTask(task);
    await showModalBottomSheet(
      elevation: 0,
      backgroundColor: ColorsExt.background(context),
      context: context,
      isScrollControlled: true,
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

    bool hasEditedListIdOrSectionId = false;

    if (hasEditedListId(original: original, updated: updated) ||
        hasEditedSectionId(original: original, updated: updated)) {
      print("hasEditedListId || hasEditedSectionId");
      hasEditedListIdOrSectionId = true;
      editTaskCubit.onListIdOrSectionIdChanges(original: original, updated: updated);
    }

    if (TaskExt.hasRecurringDataChanges(original: original, updated: updated) ||
        (hasEditedListIdOrSectionId && updated.recurringId != null)) {
      try {
        // ignore: use_build_context_synchronously
        await showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => RecurringEditModal(
                  onlyThisTap: () {
                    editTaskCubit.modalDismissed(hasEditedListIdOrSectionId: hasEditedListIdOrSectionId);
                  },
                  allTap: () {
                    editTaskCubit.modalDismissed(
                        updateAllFuture: true, hasEditedListIdOrSectionId: hasEditedListIdOrSectionId);
                  },
                ));
      } catch (e) {
        print(e);
        editTaskCubit.modalDismissed(hasEditedListIdOrSectionId: hasEditedListIdOrSectionId);
      }
    } else {
      editTaskCubit.modalDismissed();
    }

    if (updated.isCompletedComputed != original.isCompletedComputed) {
      tasksCubit.handleDocAction([updated]);
    }
  }

  Future<void> openLinkedContentUrl([dynamic doc]) async {
    String? localUrl =
        doc is GmailDoc || doc is TrelloDoc || doc is JiraDoc || doc is GithubDoc ? doc.url : doc.localUrl;

    Uri uri = Uri.parse(localUrl ?? '');

    bool opened = false;

    try {
      if (doc is SlackDoc && doc.localUrl != null) {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print(e);
    }

    if (opened == false) {
      launchUrl(Uri.parse(doc?.url ?? ''), mode: LaunchMode.externalApplication).catchError((e) {
        print(e);
        return false;
      });
    }
  }

  playTaskDoneSound() async {
    if (!(done ?? false)) {
      final AuthCubit authCubit = locator<AuthCubit>();
      bool taskCompletedSoundEnabled = authCubit.getSettingBySectionAndKey(
              sectionName: UserSettingsUtils.tasksSection, key: UserSettingsUtils.taskCompletedSoundEnabled) ??
          true;

      if (taskCompletedSoundEnabled) {
        final audioPlayer = AudioPlayer(
          handleInterruptions: false,
          androidApplyAudioAttributes: false,
          handleAudioSessionActivation: false,
        );
        await audioPlayer.setAudioSource(AudioSource.asset(Assets.sounds.taskCompletedMP3));
        AudioSession.instance.then((session) async => {
              await session.configure(const AudioSessionConfiguration(
                avAudioSessionCategory: AVAudioSessionCategory.playback,
                avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
                avAudioSessionMode: AVAudioSessionMode.defaultMode,
                avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
                avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
                androidAudioAttributes: AndroidAudioAttributes(
                  contentType: AndroidAudioContentType.music,
                  flags: AndroidAudioFlags.none,
                  usage: AndroidAudioUsage.media,
                ),
                androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
                androidWillPauseWhenDucked: true,
              )),
              await audioPlayer.setVolume(0.3),
              await audioPlayer.play(),
            });
      }
    }
  }
}
