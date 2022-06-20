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
    if (content?["internalDate"] == null) {
      return null;
    }

    int millis = int.parse(content!["internalDate"]!);

    DateTime date = DateTime.fromMillisecondsSinceEpoch(millis).toLocal();

    return DateFormat("dd MMM yyyy").format(date);
  }

  String? get dueDateTimeFormatted {
    if (content?["dueDateTime"] != null) {
      return content?["dueDateTime"];
    }

    if (content?["dueDate"] != null) {
      return content?["dueDate"];
    }

    if (content?["due_date"] != null) {
      String dueDate = content!["due_date"]!;
      DateTime date = DateTime.parse(dueDate);
      return DateFormat("dd MMMM").format(date);
    }

    return null;
  }

  String? get createdAtFormatted {
    if (content?["createdAt"] != null) {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(content!["createdAt"]!).toLocal());
    }

    return '';
  }

  String? get modifiedAtFormatted {
    if (content?["modifiedAt"] != null) {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(content!["modifiedAt"]!).toLocal());
    }

    return '';
  }

  String? get starredAtFormatted {
    DateTime? starredAt;

    if (content?["starredAt"] != null) {
      starredAt = DateTime.fromMillisecondsSinceEpoch(content!["starredAt"]! * 1000).toLocal();
    } else if (content?["starred_at"] != null) {
      starredAt = DateTime.fromMillisecondsSinceEpoch(content!["starred_at"]! * 1000).toLocal();
    }

    if (starredAt != null) {
      if (starredAt.toLocal().day == DateTime.now().day &&
          starredAt.toLocal().month == DateTime.now().month &&
          starredAt.toLocal().year == DateTime.now().year) {
        return t.task.today;
      } else {
        return DateFormat("dd MMM yyyy").format(starredAt.toLocal());
      }
    } else {
      return null;
    }
  }

  String? get dueFormatted {
    if (content?["due"] != null) {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(content!["due"]!).toLocal());
    }

    return '';
  }

  static Doc? fromBuiltInDoc(Task? task) {
    if (task?.doc == null) {
      return null;
    }

    return Doc(
      id: task!.id,
      taskId: task.id,
      title: task.title,
      description: task.description,
      connectorId: task.connectorId,
      originId: task.originId,
      accountId: task.originAccountId,
      url: task.doc?['url'],
      localUrl: task.doc?['localUrl'],
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      deletedAt: task.deletedAt,
      globalUpdatedAt: task.globalUpdatedAt,
      globalCreatedAt: task.globalCreatedAt,
      remoteUpdatedAt: task.remoteUpdatedAt,
      content: task.content,
    );
  }
}
