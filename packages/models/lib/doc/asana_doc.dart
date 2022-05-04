import 'package:models/doc/doc.dart';
import 'package:models/doc/doc_base.dart';

class AsanaDoc extends Doc implements DocBase {
  AsanaDoc(Doc doc)
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
    if (content?["workspaceName"]) {
      summaryPieces.add(content?["workspaceName"]);
    }
    if (content?["projectName"]) {
      summaryPieces.add(content?["projectName"]);
    }
    if (content?["parentTaskTitle"]) {
      summaryPieces.add(content?["parentTaskTitle"]);
    }
    return summaryPieces.join(' - ');
  }

  // TODO getFinalURL

  @override
  String get getSummary {
    return (content?["parentTaskTitle"] ?? content?["projectName"]) ??
        super.getSummary;
  }
}
