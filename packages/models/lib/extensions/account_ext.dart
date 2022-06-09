import 'package:models/account/account.dart';
import 'package:models/integrations/gmail.dart';

extension AccountExt on Account {
  GmailSyncMode get gmailSyncMode {
    try {
      return details?['syncMode'] == 1
          ? GmailSyncMode.useAkiflowLabel
          : GmailSyncMode.useStarToImport;
    } catch (e) {
      return GmailSyncMode.doNothing;
    }
  }
}
