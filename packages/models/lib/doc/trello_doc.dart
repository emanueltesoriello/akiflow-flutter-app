import 'package:models/account/account.dart';
import 'package:models/doc/doc.dart';
import 'package:models/doc/doc_base.dart';

class TrelloDoc extends Doc implements DocBase {
  TrelloDoc(Doc doc)
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
  @override
  String getLinkedContentSummary([Account? account]) {
    final summaryPieces = [];
    if (content?["boardName"] != null && content?["boardName"] != '') {
      summaryPieces.add(content?["boardName"]);
    }
    return summaryPieces.join(' - ');
  }

  @override
  String get getSummary {
    return content?["boardName"] ?? super.getSummary;
  }
}
