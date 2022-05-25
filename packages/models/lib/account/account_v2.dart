import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:models/base.dart';
import 'package:models/nullable.dart';

class AccountV2 extends Equatable implements Base {
  final int? id;
  final int? userId;
  final String? connectorId;
  final String? accountId;
  final String? originAccountId;
  final String? shortName;
  final String? fullName;
  final String? picture;
  final String? identifier;
  final dynamic details;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? globalUpdatedAt;
  final String? globalCreatedAt;
  final String? remoteUpdatedAt;
  final bool? updated;

  const AccountV2({
    this.id,
    this.userId,
    this.connectorId,
    this.accountId,
    this.originAccountId,
    this.shortName,
    this.fullName,
    this.picture,
    this.identifier,
    this.details,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.globalUpdatedAt,
    this.globalCreatedAt,
    this.remoteUpdatedAt,
    this.updated,
  });

  AccountV2 copyWith({
    int? id,
    int? userId,
    String? connectorId,
    String? accountId,
    String? originAccountId,
    String? shortName,
    String? fullName,
    String? picture,
    String? identifier,
    dynamic? details,
    String? createdAt,
    Nullable<String?>? updatedAt,
    String? deletedAt,
    String? globalUpdatedAt,
    String? globalCreatedAt,
    Nullable<String?>? remoteUpdatedAt,
    bool? updated,
  }) {
    return AccountV2(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      connectorId: connectorId ?? this.connectorId,
      accountId: accountId ?? this.accountId,
      originAccountId: originAccountId ?? this.originAccountId,
      shortName: shortName ?? this.shortName,
      fullName: fullName ?? this.fullName,
      picture: picture ?? this.picture,
      identifier: identifier ?? this.identifier,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
      deletedAt: deletedAt ?? this.deletedAt,
      globalUpdatedAt: globalUpdatedAt ?? this.globalUpdatedAt,
      globalCreatedAt: globalCreatedAt ?? this.globalCreatedAt,
      remoteUpdatedAt: remoteUpdatedAt == null
          ? this.remoteUpdatedAt
          : remoteUpdatedAt.value,
      updated: updated ?? this.updated,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'connector_id': connectorId,
      'account_id': accountId,
      'origin_account_id': originAccountId,
      'short_name': shortName,
      'full_name': fullName,
      'picture': picture,
      'identifier': identifier,
      'details': details.toMap(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'global_updated_at': globalUpdatedAt,
      'global_created_at': globalCreatedAt,
      'remote_updated_at': remoteUpdatedAt,
      'updated': updated,
    };
  }

  factory AccountV2.fromMap(Map<String, dynamic> map) {
    return AccountV2(
      id: map['id'].toInt() as int?,
      userId: map['user_id'].toInt() as int?,
      connectorId: map['connector_id'] as String?,
      accountId: map['account_id'] as String?,
      originAccountId: map['origin_account_id'] as String?,
      shortName: map['short_name'] as String?,
      fullName: map['full_name'] as String?,
      picture: map['picture'] as String?,
      identifier: map['identifier'] as String,
      details: map['details'] as dynamic,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      deletedAt: map['deleted_at'] as String?,
      globalUpdatedAt: map['global_updated_at'] as String?,
      globalCreatedAt: map['global_created_at'] as String?,
      remoteUpdatedAt: map['remote_updated_at'] as String?,
      updated: map['updated'] as bool?,
    );
  }

  @override
  Map<String, Object?> toSql() {
    return {
      "id": id?.toString(),
      "account_id": accountId,
      "connector_id": connectorId,
      "origin_account_id": originAccountId,
      "short_name": shortName,
      "full_name": fullName,
      "picture": picture,
      "identifier": identifier,
      "updated_at": updatedAt,
      "created_at": createdAt,
      "deleted_at": deletedAt,
      "remote_updated_at": remoteUpdatedAt,
    };
  }

  static AccountV2 fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    for (var key in data.keys) {
      switch (key) {
        case "details":
          data[key] =
              data[key] is String ? (jsonDecode(data[key] as String)) : null;
          break;
        default:
      }
    }

    return AccountV2.fromMap(data);
  }

  @override
  List<Object?> get props {
    return [
      id,
      userId,
      connectorId,
      accountId,
      originAccountId,
      shortName,
      fullName,
      picture,
      identifier,
      details,
      createdAt,
      updatedAt,
      deletedAt,
      globalUpdatedAt,
      globalCreatedAt,
      remoteUpdatedAt,
      updated,
    ];
  }
}
