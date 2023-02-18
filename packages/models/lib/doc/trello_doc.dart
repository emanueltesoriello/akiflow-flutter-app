import 'package:models/account/account.dart';
import 'package:models/doc/doc_base.dart';

class TrelloDoc extends DocBase {
  late final String? title;
  final String? id;
  final String? listId;
  final String? listName;
  final String? desc;
  final String? url;
  final String? dateLastActivity;
  final String? dueComplete;
  final String? boardId;
  final String? boardName;
  final String? due;

  TrelloDoc({
    this.id,
    this.listId,
    this.listName,
    this.desc,
    this.url,
    this.dateLastActivity,
    this.dueComplete,
    this.boardId,
    this.boardName,
    this.due,
  });

  factory TrelloDoc.fromMap(Map<String, dynamic> json) => TrelloDoc(
        id: json['id'] as String?,
        listId: json['list_id'] as String?,
        listName: json['list_name'] as String?,
        desc: json['desc'] as String?,
        url: json['url'] as String?,
        dateLastActivity: json['date_last_activity'] as String?,
        dueComplete: json['due_complete'] as String?,
        boardId: json['board_id'] as String?,
        boardName: json['board_name'] as String?,
        due: json['due'] as String?,
      );

  setTitle(String? title) {
    this.title = title;
  }

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
    return boardName ?? url ?? '';
  }

  @override
  List<Object?> get props {
    return [
      title,
      url,
      listId,
      listName,
      id,
      desc,
      dateLastActivity,
      dueComplete,
      due,
      boardId,
      boardName,
    ];
  }
}
