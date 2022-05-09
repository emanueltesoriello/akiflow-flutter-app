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
  @override
  String get getLinkedContentSummary {
    final summaryPieces = [];

    // check workspace (SlackDocModel.ts)

    try {
      if (content?["channelName"]) {
        summaryPieces.add(content?["channelName"]);
      }
    } catch (_) {}

    try {
      if (content?["userName"]) {
        summaryPieces.add(content?["userName"]);
      }
    } catch (_) {}

    return summaryPieces.join(' - ');
  }

  String? getWorkspace() {
    // TODO slack workspace
    return null;
  }

  @override
  String get getSummary {
    return content?["userName"] ?? super.getSummary;
  }
}
