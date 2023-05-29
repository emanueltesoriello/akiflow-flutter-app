import 'package:i18n/strings.g.dart';
import 'package:models/integrations/gmail.dart';

enum MarkAsDoneType {
  unstarTheEmail('unstar'),
  goTo('open'),
  doNothing('cancel'),
  askMeEveryTime(null);

  final String? key;
  const MarkAsDoneType(this.key);

  factory MarkAsDoneType.fromKey(String? key) {
    switch (key) {
      case 'unstar':
        return unstarTheEmail;
      case 'open':
        return goTo;
      case 'cancel':
        return doNothing;
      default:
        return askMeEveryTime;
    }
  }

  static String titleFromKey({required String? key, GmailSyncMode? syncMode, String? integrationTitle}) {
    switch (key) {
      case 'unstar':
        if (syncMode == GmailSyncMode.useAkiflowLabel) {
          return t.settings.integrations.onMarkAsDone.unlabelTheEmail;
        } else {
          return t.settings.integrations.onMarkAsDone.unstarTheEmail;
        }
      case 'open':
        return '${t.settings.integrations.onMarkAsDone.goTo} $integrationTitle';
      case 'cancel':
        return t.settings.integrations.onMarkAsDone.doNothing;
      default:
        return t.settings.integrations.onMarkAsDone.askMeEveryTime;
    }
  }
}
