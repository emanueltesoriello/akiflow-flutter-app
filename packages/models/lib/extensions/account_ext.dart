import 'package:models/account/account.dart';
import 'package:models/integrations/gmail.dart';

extension AccountExt on Account {
  static const List<String> acceptedAccountsOrigin = [
    "akiflow",
    "google",
    "slack",
    "gmail",
    "notion",
    "todoist",
    "asana",
    "clickup",
    "jira",
    "github",
    "trello",
    "zoom",
  ];

  static const List<String> settingsEnabled = [
    "notion",
    "todoist",
    "asana",
    "clickup",
    "jira",
    "github",
    "trello",
  ];

  static const List<String> v3Accounts = ["gmail"];

  GmailSyncMode get gmailSyncMode {
    try {
      return details?['syncMode'] == 1 ? GmailSyncMode.useAkiflowLabel : GmailSyncMode.useStarToImport;
    } catch (e) {
      return GmailSyncMode.doNothing;
    }
  }
}
