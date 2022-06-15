import 'package:intl/intl.dart';
import 'package:mobile/utils/task_extension.dart';
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

    return '';
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
    if (content?["starredAt"] != null) {
      return DateFormat("dd MMM yyyy")
          .format(DateTime.fromMillisecondsSinceEpoch(content!["starredAt"]! * 1000).toLocal());
    }

    return '';
  }

  String? get dueFormatted {
    if (content?["due"] != null) {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(content!["due"]!).toLocal());
    }

    return '';
  }

  static Doc? fromBuiltInDoc(Task? task) {
    if (task?.taskDoc == null) {
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
      url: task.taskDoc!.url,
      localUrl: task.taskDoc!.localUrl,
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
