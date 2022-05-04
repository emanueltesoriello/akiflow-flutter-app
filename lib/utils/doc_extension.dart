import 'package:intl/intl.dart';
import 'package:models/doc/doc.dart';

extension DocExt on Doc {
  String get computedIcon {
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
        // TODO icon notion svg not supported
        return "assets/images/icons/_common/info.svg";
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
      return DateFormat("dd MMM yyyy")
          .format(DateTime.parse(content!["createdAt"]!).toLocal());
    }

    return '';
  }

  String? get modifiedAtFormatted {
    if (content?["modifiedAt"] != null) {
      return DateFormat("dd MMM yyyy")
          .format(DateTime.parse(content!["modifiedAt"]!).toLocal());
    }

    return '';
  }

  String? get starredAtFormatted {
    if (content?["starredAt"] != null) {
      return DateFormat("dd MMM yyyy").format(
          DateTime.fromMillisecondsSinceEpoch(content!["starredAt"]! * 1000)
              .toLocal());
    }

    return '';
  }

  String? get dueFormatted {
    if (content?["due"] != null) {
      return DateFormat("dd MMM yyyy")
          .format(DateTime.parse(content!["due"]!).toLocal());
    }

    return '';
  }
}
