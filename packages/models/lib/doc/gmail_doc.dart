import 'package:models/doc/doc.dart';
import 'package:models/doc/doc_base.dart';

class GmailDoc extends Doc implements DocBase {
  GmailDoc(Doc doc)
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
    if (content?["from"] != null && content!["from"].isNotEmpty) {
      final matches = RegExp(r'^(.*?)\s*<(.*?)>').allMatches(content!["from"]);

      String? name =
          matches.isEmpty ? content!["from"] : matches.first.group(1);
      String? email =
          matches.isEmpty ? content!["from"] : matches.first.group(2);

      if (name != null && name.isNotEmpty) {
        summaryPieces.add(name);
      } else if (email != null && email.isNotEmpty) {
        summaryPieces.add(email);
      }
    }
    if (title != null && title!.isNotEmpty) {
      summaryPieces.add(title);
    }

    return summaryPieces.join(' - ');
  }

  @override
  String get getSummary {
    return content?["from"] ?? super.getSummary;
  }
}
