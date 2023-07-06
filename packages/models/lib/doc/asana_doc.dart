import 'package:models/account/account.dart';
import 'package:models/doc/doc_base.dart';

class AsanaDoc extends DocBase {
  late final String? title;
  final String? accountId;
  final String? workspaceId;
  final String? workspaceName;
  final String? projectId;
  final String? projectName;
  final String? sectionId;
  final String? sectionName;
  final String? assigneeId;
  final String? assigneeName;
  final String? url;
  final String? localUrl;
  final String? createdAt;
  final String? updatedAt;
  final String? hash;

  AsanaDoc({
    this.accountId,
    this.workspaceId,
    this.workspaceName,
    this.projectId,
    this.projectName,
    this.sectionId,
    this.sectionName,
    this.assigneeId,
    this.assigneeName,
    this.url,
    this.localUrl,
    this.createdAt,
    this.updatedAt,
    this.hash,
  });

  factory AsanaDoc.fromMap(Map<String, dynamic> json) => AsanaDoc(
        accountId: json['account_id'] as String?,
        workspaceId: json['workspaceID'] as String?,
        workspaceName: json['workspace_name'] as String?,
        projectId: json['project_id'] as String?,
        projectName: json['project_name'] as String?,
        sectionId: json['section_id'] as String?,
        sectionName: json['section_name'] as String?,
        assigneeId: json['assignee_id'] as String?,
        assigneeName: json['assignee_name'] as String?,
        url: json['url'] as String?,
        localUrl: json['local_url'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        hash: json['hash'] as String?,
      );

  setTitle(String? title) {
    this.title = title;
  }

  @override
  String getLinkedContentSummary([Account? account]) {
    final summaryPieces = [];
    if (workspaceName != null && workspaceName!.isNotEmpty) {
      summaryPieces.add(workspaceName);
    }
    if (projectName != null && projectName!.isNotEmpty) {
      summaryPieces.add(projectName);
    }
    if (title != null && title!.isNotEmpty) {
      summaryPieces.add(title);
    }
    return summaryPieces.join(' - ');
  }

  @override
  String get getSummary {
    return projectName ?? url ?? '';
  }

  @override
  List<Object?> get props {
    return [
      title,
      accountId,
      workspaceId,
      workspaceName,
      projectId,
      projectName,
      sectionId,
      sectionName,
      assigneeId,
      assigneeName,
      url,
      localUrl,
      createdAt,
      updatedAt,
    ];
  }
}
