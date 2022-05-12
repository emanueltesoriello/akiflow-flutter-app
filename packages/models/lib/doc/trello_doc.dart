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
  String get getLinkedContentSummary {
    final summaryPieces = [];
    if (content?["boardName"]) {
      summaryPieces.add(content?["boardName"]);
    }
    return summaryPieces.join(' - ');
  }

  @override
  String get getSummary {
    return (content?["parentTaskTitle"] ?? content?["projectName"]) ?? super.getSummary;
  }
}
