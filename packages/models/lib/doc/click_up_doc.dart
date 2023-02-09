import 'package:models/account/account.dart';
import 'package:models/doc/doc.dart';
import 'package:models/doc/doc_base.dart';

class ClickupDoc extends Doc implements DocBase {
  final String? title;
  ClickupDoc(Doc doc, this.title)
      : super(
          taskId: doc.taskId,
          parentTaskId: doc.parentTaskId,
          parentTaskName: doc.parentTaskName,
          teamId: doc.teamId,
          teamName: doc.teamName,
          spaceId: doc.spaceId,
          spaceName: doc.spaceName,
          folderId: doc.folderId,
          folderName: doc.folderName,
          listId: doc.listId,
          listName: doc.listName,
          url: doc.url,
          localUrl: doc.localUrl,
          createdAt: doc.createdAt,
          updatedAt: doc.updatedAt,
        );

  @override
  String getLinkedContentSummary([Account? account]) {
    final summaryPieces = [];
    if (teamName != null && teamName!.isNotEmpty) {
      summaryPieces.add(teamName);
    }
    if (spaceName != null && spaceName!.isNotEmpty) {
      summaryPieces.add(spaceName);
    }
    if (folderName != null && folderName!.isNotEmpty) {
      summaryPieces.add(folderName);
    }
    if (listName != null && listName!.isNotEmpty) {
      summaryPieces.add(listName);
    }
    if (title != null && title != '') {
      summaryPieces.add(title);
    }
    return summaryPieces.join(' - ');
  }

  @override
  String get getSummary {
    return parentTaskTitle ?? listName ?? super.getSummary;
  }
}
