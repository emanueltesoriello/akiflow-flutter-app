import 'package:i18n/strings.g.dart';
import 'package:models/integrations/gmail.dart';

enum GmailMarkAsDoneType {
  unstarTheEmail('unstar'),
  goToGmail('open'),
  doNothing('cancel'),
  askMeEveryTime(null);

  final String? key;
  const GmailMarkAsDoneType(this.key);

  factory GmailMarkAsDoneType.fromKey(String? key) {
    switch (key) {
      case 'unstar':
        return unstarTheEmail;
      case 'open':
        return goToGmail;
      case 'cancel':
        return doNothing;
      default:
        return askMeEveryTime;
    }
  }

  static String titleFromKey(String? key, GmailSyncMode syncMode) {
    switch (key) {
      case 'unstar':
        if (syncMode == GmailSyncMode.useAkiflowLabel) {
          return t.settings.integrations.gmail.onMarkAsDone.unlabelTheEmail;
        } else {
          return t.settings.integrations.gmail.onMarkAsDone.unstarTheEmail;
        }
      case 'open':
        return t.settings.integrations.gmail.onMarkAsDone.goToGmail;
      case 'cancel':
        return t.settings.integrations.gmail.onMarkAsDone.doNothing;
      default:
        return t.settings.integrations.gmail.onMarkAsDone.askMeEveryTime;
    }
  }
}
