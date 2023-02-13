import 'package:models/account/account.dart';
import 'package:models/doc/doc_base.dart';

class ClickupDoc extends DocBase {
  late final String? title;
  final String? taskId;
  final String? parentTaskId;
  final String? parentTaskName;
  final String? teamId;
  final String? teamName;
  final String? spaceId;
  final String? spaceName;
  final String? folderId;
  final String? folderName;
  final String? listId;
  final String? listName;
  final String? url;
  final String? localUrl;
  final String? createdAt;
  final String? updatedAt;
  final String? hash;

  ClickupDoc({
    this.taskId,
    this.parentTaskId,
    this.parentTaskName,
    this.teamId,
    this.teamName,
    this.spaceId,
    this.spaceName,
    this.folderId,
    this.folderName,
    this.listId,
    this.listName,
    this.url,
    this.localUrl,
    this.createdAt,
    this.updatedAt,
    this.hash,
  });

  setTitle(String? title) {
    this.title = title;
  }

  factory ClickupDoc.fromMap(Map<String, dynamic> json) => ClickupDoc(
        taskId: json['task_id'] as String?,
        parentTaskId: json['parent_task_id'] as String?,
        parentTaskName: json['parent_task_name'] as String?,
        teamId: json['team_id'] as String?,
        teamName: json['team_name'] as String?,
        spaceId: json['space_id'] as String?,
        spaceName: json['space_name'] as String?,
        folderId: json['folder_id'] as String?,
        folderName: json['folder_name'] as String?,
        listId: json['list_id'] as String?,
        listName: json['list_name'] as String?,
        url: json['url'] as String?,
        localUrl: json['local_url'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        hash: json['hash'] as String?,
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
    if (title != null && title!.isNotEmpty) {
      summaryPieces.add(title);
    }
    return summaryPieces.join(' - ');
  }

  @override
  String get getSummary {
    return parentTaskName ?? listName ?? url ?? '';
  }

  @override
  List<Object?> get props {
    return [
      url,
      taskId,
      parentTaskId,
      parentTaskName,
      teamId,
      teamName,
      spaceId,
      spaceName,
      folderId,
      folderName,
      listId,
      listName,
      url,
      localUrl,
      createdAt,
      createdAt,
      hash,
    ];
  }
}
