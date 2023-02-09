import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';

extension DocExt on Doc {
  String get connectorTitle {
    return titleFromConnectorId(connectorId);
  }

  static String titleFromConnectorId(String? connectorId) {
    switch (connectorId) {
      case "asana":
        return "Asana";
      case "clickup":
        return "ClickUp";
      case "dropbox":
        return "Dropbox";
      case "google":
        return "Google";
      case "gmail":
        return "Gmail";
      case "jira":
        return "Jira";
      case "skype":
        return "Skype";
      case "teams":
        return "Teams";
      case "notion":
        return "Notion";
      case "slack":
        return "Slack";
      case "superhuman":
        return "Superhuman";
      case "todoist":
        return "Todoist";
      case "trello":
        return "Trello";
      case "twitter":
        return "Twitter";
      case "zapier":
        return "Zapier";
      case "zoom":
        return "Zoom";
      default:
        return connectorId ?? "";
    }
  }

  String? get internalDateFormatted {
    if (internalDate == null) {
      return null;
    }

    int millis = int.parse(internalDate!);

    DateTime date = DateTime.fromMillisecondsSinceEpoch(millis).toLocal();

    return DateFormat("dd MMM yyyy").format(date);
  }

  String? get dueDateTimeFormatted {
    if (dueDateTime != null) {
      return dueDateTime;
    }

    if (dueDate != null) {
      DateTime date = DateTime.parse(dueDate!);
      return DateFormat("dd MMMM").format(date);
    }

    return null;
  }

  String? get createdAtFormatted {
    if (createdAt != null) {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(createdAt!).toLocal());
    }

    return '';
  }

  String? get modifiedAtFormatted {
    if (updatedAt != null) {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(updatedAt!).toLocal());
    }

    return '';
  }

  String? get starredAtFormatted {
    DateTime? starredAtDate;

    if (starredAt != null) {
      starredAtDate = DateTime.fromMillisecondsSinceEpoch(starredAt! * 1000).toLocal();
    }

    if (starredAtDate != null) {
      if (starredAtDate.toLocal().day == DateTime.now().day &&
          starredAtDate.toLocal().month == DateTime.now().month &&
          starredAtDate.toLocal().year == DateTime.now().year) {
        return t.task.today;
      } else {
        return DateFormat("dd MMM yyyy").format(starredAtDate.toLocal());
      }
    } else {
      return null;
    }
  }

  String? get dueFormatted {
    if (due != null) {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(due!).toLocal());
    }

    return '';
  }
}
