import 'package:models/account/account.dart';
import 'package:models/doc/doc.dart';
import 'package:models/doc/doc_base.dart';

class TrelloDoc extends Doc implements DocBase {
  final String? title;
  TrelloDoc(Doc doc, this.title)
      : super(
            id: doc.id,
            listId: doc.listId,
            listName: doc.listName,
            desc: doc.desc,
            url: doc.url,
            dateLastActivity: doc.dateLastActivity,
            dueComplete: doc.dueComplete,
            boardId: doc.boardId,
            boardName: doc.boardName,
            due: doc.due);
  @override
  String getLinkedContentSummary([Account? account]) {
    final summaryPieces = [];
    if (boardName != null && boardName!.isNotEmpty) {
      summaryPieces.add(boardName);
    }
    return summaryPieces.join(' - ');
  }

  @override
  String get getSummary {
    return boardName ?? super.getSummary;
  }
}
