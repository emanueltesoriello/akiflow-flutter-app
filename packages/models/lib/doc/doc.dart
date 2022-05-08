import 'dart:convert';

import 'package:models/base.dart';
import 'package:models/doc/doc_base.dart';

class Doc extends DocBase implements Base {
  final String? id;
  final String? connectorId;
  final String? originId;
  final String? accountId;
  final String? taskId;
  final String? title;
  final String? description;
  final String? url;
  final String? localUrl;
  final String? type;
  final String? icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final DateTime? globalUpdatedAt;
  final DateTime? globalCreatedAt;
  final DateTime? remoteUpdatedAt;
  final Map<String, dynamic>? content;

  Doc({
    this.id,
    this.taskId,
    this.title,
    this.description,
    this.connectorId,
    this.originId,
    this.accountId,
    this.url,
    this.localUrl,
    this.type,
    this.icon,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.globalUpdatedAt,
    this.globalCreatedAt,
    this.remoteUpdatedAt,
    this.content,
  });

  Doc copyWith({
    String? id,
    String? taskId,
    String? title,
    String? description,
    String? connectorId,
    String? originId,
    String? accountId,
    String? url,
    String? localUrl,
    String? type,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? globalUpdatedAt,
    DateTime? globalCreatedAt,
    DateTime? remoteUpdatedAt,
    Map<String, dynamic>? content,
  }) {
    return Doc(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      connectorId: connectorId ?? this.connectorId,
      originId: originId ?? this.originId,
      accountId: accountId ?? this.accountId,
      url: url ?? this.url,
      localUrl: localUrl ?? this.localUrl,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      globalUpdatedAt: globalUpdatedAt ?? this.globalUpdatedAt,
      globalCreatedAt: globalCreatedAt ?? this.globalCreatedAt,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      content: content ?? this.content,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'task_id': taskId,
      'title': title,
      'description': description,
      'connector_id': connectorId,
      'origin_id': originId,
      'account_id': accountId,
      'url': url,
      'local_url': localUrl,
      'type': type,
      'icon': icon,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'globalUpdated_at': globalUpdatedAt?.toIso8601String(),
      'globalCreated_at': globalCreatedAt?.toIso8601String(),
      'remoteUpdated_at': remoteUpdatedAt?.toIso8601String(),
      'content': content,
    };
  }

  factory Doc.fromMap(Map<String, dynamic> map) {
    return Doc(
      id: map['id'] != null ? map['id'] as String : null,
      taskId: map['task_id'] != null ? map['task_id'] as String : null,
      title: map['title'] != null ? map['title'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      connectorId:
          map['connector_id'] != null ? map['connector_id'] as String : null,
      originId: map['origin_id'] != null ? map['origin_id'] as String : null,
      accountId: map['account_id'] != null ? map['account_id'] as String : null,
      url: map['url'] != null ? map['url'] as String : null,
      localUrl: map['local_url'] != null ? map['local_url'] as String : null,
      type: map['type'] != null ? map['type'] as String : null,
      icon: map['icon'] != null ? map['icon'] as String : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      deletedAt:
          map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
      globalUpdatedAt: map['global_updated_at'] != null
          ? DateTime.parse(map['global_updated_at'])
          : null,
      globalCreatedAt: map['global_created_at'] != null
          ? DateTime.parse(map['global_created_at'])
          : null,
      remoteUpdatedAt: map['remote_updated_at'] != null
          ? DateTime.parse(map['remote_updated_at'])
          : null,
      content: map['content'],
    );
  }

  @override
  Map<String, Object?> toSql() {
    return {
      "id": id,
      "task_id": taskId,
      "connector_id": connectorId,
      "title": title,
      "description": description,
      "origin_id": originId,
      "account_id": accountId,
      "icon": icon,
      "url": url,
      "local_url": localUrl,
      "type": type,
      "updated_at": globalUpdatedAt?.toIso8601String(),
      "created_at": globalCreatedAt?.toIso8601String(),
      "deleted_at": deletedAt?.toIso8601String(),
      "remote_updated_at": globalUpdatedAt?.toIso8601String(),
      "content": jsonEncode(content),
    };
  }

  static Doc fromSql(Map<String, dynamic> json) {
    Map<String, dynamic>? copy = Map<String, dynamic>.from(json);

    try {
      copy['content'] =
          jsonDecode(json['content'] as String) as Map<String, dynamic>;
    } catch (_) {}

    return Doc.fromMap(copy);
  }

  @override
  List<Object?> get props {
    return [
      id,
      taskId,
      title,
      description,
      connectorId,
      originId,
      accountId,
      url,
      localUrl,
      type,
      icon,
      updatedAt,
      deletedAt,
      globalUpdatedAt,
      globalCreatedAt,
      remoteUpdatedAt,
      content,
    ];
  }

  @override
  String get getSummary {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }

    return '';
  }

  @override
  String get getFinalURL {
    // TODO asana url (AsanaDocModel.ts)
    //  if (content?["localUrl"] && await AsanaConnector.getInstance().isProtocolHandled()) {
    //   return this.localUrl
    // }
    return url ?? '';
  }

  @override
  String get getLinkedContentSummary {
    return url ?? '';
  }
}
