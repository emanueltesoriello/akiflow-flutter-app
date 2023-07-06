import 'package:models/account/account.dart';
import 'package:models/doc/doc_base.dart';

class NotionDoc extends DocBase {
  late final String? title;
  final String? url;
  final String? localUrl;
  final String? workspaceId;
  final String? workspaceName;
  final String? createdAt;
  final String? updatedAt;

  NotionDoc({
    this.url,
    this.localUrl,
    this.workspaceId,
    this.workspaceName,
    this.createdAt,
    this.updatedAt,
  });

  factory NotionDoc.fromMap(Map<String, dynamic> json) => NotionDoc(
        url: json['url'] as String?,
        localUrl: json['local_url'] as String?,
        workspaceId: json['workspaceID'] as String?,
        workspaceName: json['workspace_name'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  setTitle(String? title) {
    this.title = title;
  }

  @override
  String getLinkedContentSummary([Account? account]) {
    return workspaceName ?? '';
  }

  @override
  String get getSummary {
    return workspaceName ?? url ?? '';
  }

  @override
  List<Object?> get props {
    return [
      title,
      url,
      workspaceId,
      workspaceName,
      localUrl,
      createdAt,
      updatedAt,
    ];
  }
}
