import 'package:models/account/account.dart';
import 'package:models/doc/doc.dart';
import 'package:models/doc/doc_base.dart';

class SlackDoc extends Doc implements DocBase {
  SlackDoc(Doc doc)
      : super(
            url: doc.url,
            localUrl: doc.localUrl,
            type: doc.type,
            userImage: doc.userImage,
            userName: doc.userName,
            starredAt: doc.starredAt,
            channel: doc.channel,
            channelName: doc.channelName,
            messageTimestamp: doc.messageTimestamp);

  @override
  String getLinkedContentSummary([Account? account]) {
    final summaryPieces = [];

    try {
      String? workspace = getWorkspace(account);

      if (workspace != null) {
        summaryPieces.add(workspace);
      }
    } catch (_) {}

    try {
      if (channelName != null && channelName!.isNotEmpty) {
        summaryPieces.add(channelName);
      }
    } catch (_) {}

    try {
      if (userName != null && userName!.isNotEmpty) {
        summaryPieces.add(userName);
      }
    } catch (_) {}

    if (summaryPieces.isEmpty) {
      return super.getLinkedContentSummary();
    } else {
      return "Slack: ${summaryPieces.join(' - ')}";
    }
  }

  String? getWorkspace(Account? account) {
    if (account != null) {
      return account.identifier;
    }
    return null;
  }

  @override
  String get getSummary {
    return userName ?? super.getSummary;
  }
}
