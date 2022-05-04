import 'package:models/doc/doc.dart';
import 'package:models/doc/doc_base.dart';

class ClickupDoc extends Doc implements DocBase {
  ClickupDoc(Doc doc)
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
    if (content?["teamName"]) {
      summaryPieces.add(content?["teamName"]);
    }
    if (content?["spaceName"]) {
      summaryPieces.add(content?["spaceName"]);
    }
    if (content?["folderName"]) {
      summaryPieces.add(content?["folderName"]);
    }
    if (content?["listName"]) {
      summaryPieces.add(content?["listName"]);
    }
    if (content?["parentTaskName"]) {
      summaryPieces.add(content?["parentTaskName"]);
    }
    return summaryPieces.join(' - ');
  }

  @override
  String get getSummary {
    return (content?["parentTaskTitle"] ?? content?["projectName"]) ??
        super.getSummary;
  }
}
