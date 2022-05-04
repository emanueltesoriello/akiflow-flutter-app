import 'package:models/doc/doc.dart';

extension DocExt on Doc {
  String get getLinkedContentSummary {
    final summaryPieces = [];
    if (content?.from != null && content!.from!.isNotEmpty) {
      // regexp ^(.*?)\s*<(.*?)>
      final matches = RegExp(r'^(.*?)\s*<(.*?)>').allMatches(content!.from!);

      String? name = matches.isEmpty ? content!.from : matches.first.group(1);
      String? email = matches.isEmpty ? content!.from! : matches.first.group(2);

      if (name != null && name.isNotEmpty) {
        summaryPieces.add(name);
      } else if (email != null && email.isNotEmpty) {
        summaryPieces.add(email);
      }
    }
    if (title != null && title!.isNotEmpty) {
      summaryPieces.add(title);
    }

    return summaryPieces.join(' - ');
  }

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
}
