import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:models/base.dart';
import 'package:models/nullable.dart';

class Account extends Equatable implements Base {
  const Account({
    this.id,
    this.userId,
    this.connectorId,
    this.accountId,
    this.originAccountId,
    this.shortName,
    this.fullName,
    this.picture,
    this.identifier,
    this.syncStatus,
    this.status,
    this.details,
    this.autologinToken,
    this.globalCreatedAt,
    this.globalUpdatedAt,
    this.createdAt,
    this.updatedAt,
    this.remoteUpdatedAt,
    this.deletedAt,
    this.updated,
  });

  final String? id;
  final int? userId;
  final String? connectorId;
  final String? accountId;
  final String? originAccountId;
  final String? shortName;
  final String? fullName;
  final String? picture;
  final String? identifier;
  final dynamic syncStatus;
  final String? status;
  final Map<String, dynamic>? details;
  final dynamic autologinToken;
  final String? globalCreatedAt;
  final String? globalUpdatedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? remoteUpdatedAt;
  final dynamic deletedAt;
  final bool? updated;

  factory Account.fromMap(Map<String, dynamic> map) => Account(
        id: map['id'] as String?,
        userId: map['user_id'] as int?,
        connectorId: map['connector_id'] as String?,
        accountId: map['account_id'] as String?,
        originAccountId: map['origin_account_id'] as String?,
        shortName: map['short_name'] as String?,
        fullName: map['full_name'] as String?,
        picture: map['picture'] as String?,
        identifier: map['identifier'] as String?,
        syncStatus: map['sync_status'] as dynamic,
        status: map['status'] as String?,
        details: () {
          try {
            return map['details'] as Map<String, dynamic>?;
          } catch (_) {
            return null;
          }
        }(),
        autologinToken: map['autologin_token'] as dynamic,
        globalCreatedAt: map['global_created_at'] as String?,
        globalUpdatedAt: map['global_updated_at'] as String?,
        createdAt: map['created_at'] as String?,
        updatedAt: map['updated_at'] as String?,
        remoteUpdatedAt: map['remote_updated_at'] as String?,
        deletedAt: map['deleted_at'] as dynamic,
        updated: map['updated'] as bool?,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        //'user_id': userId,
        'connector_id': connectorId,
        'account_id': accountId,
        'origin_account_id': originAccountId,
        'short_name': shortName,
        'full_name': fullName,
        'picture': picture,
        'identifier': identifier,
        'sync_status': syncStatus,
        'status': status,
        'details': details,
        'autologin_token': autologinToken,
        'global_created_at': globalCreatedAt,
        'global_updated_at': globalUpdatedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'remote_updated_at': remoteUpdatedAt,
        'deleted_at': deletedAt,
        'updated': updated,
      };

  Account copyWith({
    String? id,
    int? userId,
    String? connectorId,
    String? accountId,
    String? originAccountId,
    String? shortName,
    String? fullName,
    String? picture,
    String? identifier,
    dynamic syncStatus,
    String? status,
    Map<String, dynamic>? details,
    dynamic autologinToken,
    String? globalCreatedAt,
    String? globalUpdatedAt,
    String? createdAt,
    Nullable<String?>? updatedAt,
    Nullable<String?>? remoteUpdatedAt,
    dynamic deletedAt,
    bool? updated,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      connectorId: connectorId ?? this.connectorId,
      accountId: accountId ?? this.accountId,
      originAccountId: originAccountId ?? this.originAccountId,
      shortName: shortName ?? this.shortName,
      fullName: fullName ?? this.fullName,
      picture: picture ?? this.picture,
      identifier: identifier ?? this.identifier,
      syncStatus: syncStatus ?? this.syncStatus,
      status: status ?? this.status,
      details: details ?? this.details,
      autologinToken: autologinToken ?? this.autologinToken,
      globalCreatedAt: globalCreatedAt ?? this.globalCreatedAt,
      globalUpdatedAt: globalUpdatedAt ?? this.globalUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
      remoteUpdatedAt: remoteUpdatedAt == null ? this.remoteUpdatedAt : remoteUpdatedAt.value,
      deletedAt: deletedAt ?? this.deletedAt,
      updated: updated ?? this.updated,
    );
  }

  @override
  Map<String, Object?> toSql() {
    return {
      "id": id,
      "account_id": accountId,
      "connector_id": connectorId,
      "origin_account_id": originAccountId,
      "short_name": shortName,
      "full_name": fullName,
      "picture": picture,
      "identifier": identifier,
      "autologin_token": autologinToken,
      "status": status,
      "sync_status": syncStatus,
      "updated_at": updatedAt,
      "created_at": createdAt,
      "deleted_at": deletedAt,
      "remote_updated_at": remoteUpdatedAt,
      "details": jsonEncode(details),
    };
  }

  static Account fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    data['details'] = jsonDecode(data['details'] as String? ?? '{}');

    // Account v2 model parse
    if (data['id'] is int) {
      data['id'] = data['id'].toString();
    }

    return Account.fromMap(data);
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
      syncStatus,
      status,
      details,
      autologinToken,
      globalCreatedAt,
      globalUpdatedAt,
      createdAt,
      updatedAt,
      deletedAt,
      updated,
    ];
  }
}
