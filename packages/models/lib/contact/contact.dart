import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:models/base.dart';
import 'package:models/nullable.dart';

class Contact extends Equatable implements Base {
  const Contact({
    this.id,
    this.originId,
    this.connectorId,
    this.akiflowAccountId,
    this.originAccountId,
    this.searchText,
    this.name,
    this.identifier,
    this.picture,
    this.url,
    this.localUrl,
    this.content,
    this.etag,
    this.sorting,
    this.originUpdatedAt,
    this.remoteUpdatedAt,
    this.globalUpdatedAt,
    this.globalCreatedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String? id;
  final String? originId;
  final String? connectorId;
  final String? akiflowAccountId;
  final String? originAccountId;
  final String? searchText;
  final String? name;
  final String? identifier;
  final String? picture;
  final String? url;
  final String? localUrl;
  final dynamic content;
  final String? etag;
  final String? sorting;
  final String? originUpdatedAt;
  final String? remoteUpdatedAt;
  final String? globalUpdatedAt;
  final String? globalCreatedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  Contact copyWith({
    final String? id,
    final String? originId,
    final String? connectorId,
    final String? akiflowAccountId,
    final String? originAccountId,
    final String? searchText,
    final String? name,
    final String? identifier,
    final String? picture,
    final String? url,
    final String? localUrl,
    final dynamic content,
    final String? etag,
    final String? sorting,
    final String? originUpdatedAt,
    final Nullable<String>? remoteUpdatedAt,
    final String? globalUpdatedAt,
    final String? globalCreatedAt,
    final String? createdAt,
    final Nullable<String>? updatedAt,
    final String? deletedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      originId: originId ?? this.originId,
      connectorId: connectorId ?? this.connectorId,
      akiflowAccountId: akiflowAccountId ?? this.akiflowAccountId,
      originAccountId: originAccountId ?? this.originAccountId,
      searchText: searchText ?? this.searchText,
      name: name ?? this.name,
      identifier: identifier ?? this.identifier,
      picture: picture ?? this.picture,
      url: url ?? this.url,
      localUrl: localUrl ?? this.localUrl,
      content: content ?? this.content,
      etag: etag ?? this.etag,
      sorting: sorting ?? this.sorting,
      originUpdatedAt: originUpdatedAt ?? this.originUpdatedAt,
      remoteUpdatedAt: remoteUpdatedAt == null ? this.remoteUpdatedAt : remoteUpdatedAt.value,
      globalUpdatedAt: globalUpdatedAt ?? this.globalUpdatedAt,
      globalCreatedAt: globalCreatedAt ?? this.globalCreatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory Contact.fromMap(Map<String, dynamic> map) => Contact(
        id: map['id'] as String?,
        originId: map['origin_id'] as String?,
        connectorId: map['connector_id'] as String?,
        akiflowAccountId: map['akiflow_account_id'] as String?,
        originAccountId: map['origin_account_id'] as String?,
        searchText: map['search_text'] as String?,
        name: map['name'] as String?,
        identifier: map['identifier'] as String?,
        picture: map['picture'] as String?,
        url: map['url'] as String?,
        localUrl: map['local_url'] as String?,
        content: map['content'] as dynamic,
        etag: map['etag'] as String?,
        sorting: map['sorting'] as String?,
        originUpdatedAt: map['origin_updated_at'] as String?,
        remoteUpdatedAt: map['remote_updated_at'] as String?,
        globalUpdatedAt: map['global_updated_at'] as String?,
        globalCreatedAt: map['global_created_at'] as String?,
        createdAt: map['created_at'] as String?,
        updatedAt: map['updated_at'] as String?,
        deletedAt: map['deleted_at'] as String?,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'origin_id': originId,
        'connector_id': connectorId,
        'akiflow_account_id': akiflowAccountId,
        'origin_account_id': originAccountId,
        'search_text': searchText,
        'name': name,
        'identifier': identifier,
        'picture': picture,
        'url': url,
        'local_url': localUrl,
        'content': content,
        'etag': etag,
        'sorting': sorting,
        'origin_updated_at': originUpdatedAt,
        'global_updated_at': globalUpdatedAt,
        'global_created_at': globalCreatedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
      };

  @override
  Map<String, Object?> toSql() {
    return {
      'id': id,
      'origin_id': originId,
      'connector_id': connectorId,
      'akiflow_account_id': akiflowAccountId,
      'origin_account_id': originAccountId,
      'search_text': searchText,
      'name': name,
      'identifier': identifier,
      'picture': picture,
      'url': url,
      'local_url': localUrl,
      'content': content != null ? jsonEncode(content) : null,
      'etag': etag,
      'sorting': sorting,
      'origin_updated_at': originUpdatedAt,
      'global_updated_at': globalUpdatedAt,
      'global_created_at': globalCreatedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  static Contact fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    if (data.containsKey("content") && data["content"] != null) {
      data["content"] = jsonDecode(data["content"] as String);
    }

    return Contact.fromMap(data);
  }

  @override
  List<Object?> get props {
    return [
      id,
      originId,
      connectorId,
      akiflowAccountId,
      searchText,
      name,
      identifier,
      picture,
      url,
      localUrl,
      content,
      etag,
      sorting,
      originUpdatedAt,
      remoteUpdatedAt,
      globalCreatedAt,
      globalUpdatedAt,
      createdAt,
      updatedAt,
      deletedAt
    ];
  }
}
