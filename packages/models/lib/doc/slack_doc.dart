import 'package:models/account/account.dart';
import 'package:models/doc/doc.dart';
import 'package:models/doc/doc_base.dart';

class SlackDoc extends Doc implements DocBase {
  SlackDoc(Doc doc)
      : super(
          id: doc.id,
          taskId: doc.taskId,
          title: doc.title,
          description: doc.description,
          connectorId: doc.connectorId,
          originId: doc.originId,
          accountId: doc.accountId,
          url: doc.url,
          localUrl: doc.localUrl,
          type: doc.type,
          icon: doc.icon,
          createdAt: doc.createdAt,
          updatedAt: doc.updatedAt,
          deletedAt: doc.deletedAt,
          globalUpdatedAt: doc.globalUpdatedAt,
          globalCreatedAt: doc.globalCreatedAt,
          remoteUpdatedAt: doc.remoteUpdatedAt,
          content: doc.content,
        );

  String getLinkedContentSummaryWithAccount(Account? account) {
    final summaryPieces = [];

    try {
      summaryPieces.add(getWorkspace(account));
    } catch (_) {}

    try {
      if (content?["channelName"] != null) {
        summaryPieces.add(content?["channelName"]);
      }
    } catch (_) {}

    try {
      if (content?["userName"] != null) {
        summaryPieces.add(content?["userName"]);
      } else if (content?["user_name"] != null) {
        summaryPieces.add(content?["user_name"]);
      }
    } catch (_) {}

    if (summaryPieces.isEmpty) {
      return super.getLinkedContentSummary;
    } else {
      return "Slack: ${summaryPieces.join(' - ')}";
    }
  }

  String? getWorkspace(Account? account) {
    if (account != null) {
      return account.identifier;
    }
    return '';
  }

  @override
  String get getSummary {
    return content?["userName"] ?? content?["user_name"] ?? super.getSummary;
  }
}
