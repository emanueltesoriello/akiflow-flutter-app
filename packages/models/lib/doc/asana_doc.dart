import 'package:models/account/account.dart';
import 'package:models/doc/doc.dart';
import 'package:models/doc/doc_base.dart';

class AsanaDoc extends Doc implements DocBase {
  final String? title;
  AsanaDoc(Doc doc, this.title)
      : super(
          accountId: doc.accountId,
          workspaceId: doc.workspaceId,
          workspaceName: doc.workspaceName,
          projectId: doc.projectId,
          projectName: doc.projectName,
          sectionId: doc.sectionId,
          sectionName: doc.sectionName,
          assigneeId: doc.assigneeId,
          assigneeName: doc.assigneeName,
          url: doc.url,
          localUrl: doc.localUrl,
          createdAt: doc.createdAt,
          updatedAt: doc.updatedAt,
          hash: doc.hash,
        );

  @override
  String getLinkedContentSummary([Account? account]) {
    final summaryPieces = [];
    if (workspaceName != null && workspaceName != '') {
      summaryPieces.add(workspaceName);
    }
    if (projectName != null && projectName != '') {
      summaryPieces.add(projectName);
    }
    if (title != null && title != '') {
      summaryPieces.add(title);
    }
    return summaryPieces.join(' - ');
  }

  @override
  String get getSummary {
    return projectName ?? super.getSummary;
  }
}
