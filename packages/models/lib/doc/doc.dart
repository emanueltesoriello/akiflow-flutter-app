import 'dart:convert';

import 'package:models/base.dart';
import 'package:models/doc/doc_base.dart';
import 'package:models/nullable.dart';

class Doc extends DocBase implements Base {
  Doc({
    this.id,
    this.taskId,
    this.connectorId,
    this.originId,
    this.accountId,
    this.originAccountId,
    this.title,
    this.description,
    this.searchText,
    this.icon,
    this.url,
    this.localUrl,
    this.type,
    this.content,
    this.priority,
    this.sorting,
    this.originUpdatedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.globalUpdatedAt,
    this.globalCreatedAt,
    this.remoteUpdatedAt,
    this.updated,
  });

  final String? id;
  final String? taskId;
  final String? connectorId;
  final String? originId;
  final String? accountId;
  final String? originAccountId;
  final String? title;
  final dynamic description;
  final String? searchText;
  final dynamic icon;
  final String? url;
  final String? localUrl;
  final String? type;
  final dynamic content;
  final dynamic priority;
  final int? sorting;
  final dynamic originUpdatedAt;
  final String? createdAt;
  final String? updatedAt;
  final dynamic deletedAt;
  final String? globalUpdatedAt;
  final String? globalCreatedAt;
  final String? remoteUpdatedAt;
  final bool? updated;

  factory Doc.fromMap(Map<String, dynamic> json) => Doc(
        id: json['id'] as String?,
        taskId: json['task_id'] as String?,
        connectorId: json['connector_id'] as String?,
        originId: json['origin_id'] as String?,
        accountId: json['account_id'] as String?,
        originAccountId: json['origin_account_id'] as String?,
        title: json['title'] as String?,
        description: json['description'] as dynamic,
        searchText: json['search_text'] as String?,
        icon: json['icon'] as dynamic,
        url: json['url'] as String?,
        localUrl: json['local_url'] as String?,
        type: json['type'] as String?,
        content: json['content'] as dynamic,
        priority: json['priority'] as dynamic,
        sorting: json['sorting'] as int?,
        originUpdatedAt: json['origin_updated_at'] as dynamic,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        deletedAt: json['deleted_at'] as dynamic,
        globalUpdatedAt: json['global_updated_at'] as String?,
        globalCreatedAt: json['global_created_at'] as String?,
        remoteUpdatedAt: json['remote_updated_at'] as String?,
        updated: json['updated'] as bool?,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'task_id': taskId,
        'connector_id': connectorId,
        'origin_id': originId,
        'account_id': accountId,
        'origin_account_id': originAccountId,
        'title': title,
        'description': description,
        'search_text': searchText,
        'icon': icon,
        'url': url,
        'local_url': localUrl,
        'type': type,
        'content': content,
        'priority': priority,
        'sorting': sorting,
        'origin_updated_at': originUpdatedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'global_updated_at': globalUpdatedAt,
        'global_created_at': globalCreatedAt,
        'remote_updated_at': remoteUpdatedAt,
        'updated': updated,
      };

  Doc copyWith({
    String? id,
    String? taskId,
    String? connectorId,
    String? originId,
    String? accountId,
    String? originAccountId,
    String? title,
    dynamic description,
    String? searchText,
    dynamic icon,
    String? url,
    String? localUrl,
    String? type,
    dynamic content,
    dynamic priority,
    int? sorting,
    dynamic originUpdatedAt,
    String? createdAt,
    Nullable<String?>? updatedAt,
    Nullable<String?>? remoteUpdatedAt,
    dynamic deletedAt,
    String? globalUpdatedAt,
    String? globalCreatedAt,
    bool? updated,
  }) {
    return Doc(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      connectorId: connectorId ?? this.connectorId,
      originId: originId ?? this.originId,
      accountId: accountId ?? this.accountId,
      originAccountId: originAccountId ?? this.originAccountId,
      title: title ?? this.title,
      description: description ?? this.description,
      searchText: searchText ?? this.searchText,
      icon: icon ?? this.icon,
      url: url ?? this.url,
      localUrl: localUrl ?? this.localUrl,
      type: type ?? this.type,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      sorting: sorting ?? this.sorting,
      originUpdatedAt: originUpdatedAt ?? this.originUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
      remoteUpdatedAt: remoteUpdatedAt == null
          ? this.remoteUpdatedAt
          : remoteUpdatedAt.value,
      deletedAt: deletedAt ?? this.deletedAt,
      globalUpdatedAt: globalUpdatedAt ?? this.globalUpdatedAt,
      globalCreatedAt: globalCreatedAt ?? this.globalCreatedAt,
      updated: updated ?? this.updated,
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
      "updated_at": globalUpdatedAt,
      "created_at": globalCreatedAt,
      "deleted_at": deletedAt,
      "remote_updated_at": globalUpdatedAt,
      "content": content != null ? jsonEncode(content) : null,
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
      connectorId,
      originId,
      accountId,
      originAccountId,
      title,
      description,
      searchText,
      icon,
      url,
      localUrl,
      type,
      content,
      priority,
      sorting,
      originUpdatedAt,
      createdAt,
      updatedAt,
      deletedAt,
      globalUpdatedAt,
      globalCreatedAt,
      remoteUpdatedAt,
      updated,
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
