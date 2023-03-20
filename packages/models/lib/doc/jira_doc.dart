import 'package:models/account/account.dart';
import 'package:models/doc/doc_base.dart';

class JiraDoc extends DocBase {
  late final String? title;
  final String? url;
  final String? teamId;
  final String? teamName;
  final String? projectId;
  final String? projectName;
  final String? issueTypeName;
  final String? createdAt;
  final String? updatedAt;

  JiraDoc({
    this.url,
    this.teamId,
    this.teamName,
    this.projectId,
    this.projectName,
    this.issueTypeName,
    this.createdAt,
    this.updatedAt,
  });

  factory JiraDoc.fromMap(Map<String, dynamic> json) => JiraDoc(
        url: json['url'] as String?,
        teamId: json['team_id'] as String?,
        teamName: json['team_name'] as String?,
        projectId: json['project_id'] as String?,
        projectName: json['project_name'] as String?,
        issueTypeName: json['issue_type_name'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  setTitle(String? title) {
    this.title = title;
  }

  @override
  String getLinkedContentSummary([Account? account]) {
    final summaryPieces = [];
    if (projectName != null && projectName!.isNotEmpty) {
      summaryPieces.add(projectName);
    }
    if (issueTypeName != null && issueTypeName!.isNotEmpty) {
      summaryPieces.add(issueTypeName);
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
      url,
      teamId,
      teamName,
      projectId,
      projectName,
      issueTypeName,
      createdAt,
      updatedAt,
    ];
  }
}
