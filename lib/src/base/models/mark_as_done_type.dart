import 'package:i18n/strings.g.dart';
import 'package:models/integrations/gmail.dart';

enum MarkAsDoneType {
  unstarTheEmail('unstar'),
  markAsDone('markAsDone'),
  goTo('open'),
  doNothing('cancel'),
  askMeEveryTime(null);

  final String? key;
  const MarkAsDoneType(this.key);

  factory MarkAsDoneType.fromKey(String? key) {
    switch (key) {
      case 'unstar':
        return unstarTheEmail;
      case 'markAsDone':
        return markAsDone;
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
      case 'markAsDone':
        return t.settings.integrations.onMarkAsDone.markAsDone(tool: integrationTitle ?? t.settings.integrations.title);
      case 'open':
        return '${t.settings.integrations.onMarkAsDone.goTo} $integrationTitle';
      case 'cancel':
        return t.settings.integrations.onMarkAsDone.doNothing;
      default:
        return t.settings.integrations.onMarkAsDone.askMeEveryTime;
    }
  }
}
