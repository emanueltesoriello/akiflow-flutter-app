import 'package:models/doc/doc.dart';
import 'package:models/doc/doc_base.dart';

class TodoistDoc extends Doc implements DocBase {
  TodoistDoc(Doc doc)
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
  String get getSummary {
    return (content?["parentTaskTitle"] ?? content?["projectName"]) ?? super.getSummary;
  }

  @override
  String get getLinkedContentSummary {
    final summaryPieces = [];

    if (content?["projectName"] != null && content?["projectName"] != '') {
      summaryPieces.add(content?["projectName"]);
    }

    if (title != null && title != '') {
      summaryPieces.add(title);
    }

    if (content?["title"] != null && content?["title"] != '') {
      summaryPieces.add(content?["title"]);
    }

    return summaryPieces.join(' - ');
  }
}
