import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:models/base.dart';
import 'package:models/serializers.dart';

part 'account.g.dart';

abstract class Account extends Object
    with Base
    implements Built<Account, AccountBuilder> {
  String? get id;

  @BuiltValueField(wireName: 'connector_id')
  String? get connectorId;

  @BuiltValueField(wireName: 'account_id')
  String? get accountId;

  @BuiltValueField(wireName: 'origin_account_id')
  String? get originAccountId;

  @BuiltValueField(wireName: 'short_name')
  String? get shortName;

  @BuiltValueField(wireName: 'full_name')
  String? get fullName;

  String? get picture;
  String? get identifier;

  @BuiltValueField(wireName: 'autologin_token')
  String? get autologinToken;

  @BuiltValueField(wireName: 'status')
  String? get status;

  @BuiltValueField(wireName: 'sync_status')
  String? get syncStatus;

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: 'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: 'deleted_at')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: 'global_updated_at')
  DateTime? get globalUpdatedAt;

  @BuiltValueField(wireName: 'global_created_at')
  DateTime? get globalCreatedAt;

  @BuiltValueField(wireName: 'remote_updated_at')
  DateTime? get remoteUpdatedAt;

  Account._();

  factory Account([void Function(AccountBuilder) updates]) = _$Account;

  @override
  Account rebuild(void Function(AccountBuilder) updates);

  @override
  AccountBuilder toBuilder();

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(Account.serializer, this)
        as Map<String, dynamic>;
  }

  static Account fromMap(Map<String, dynamic> json) {
    return serializers.deserializeWith(Account.serializer, json)!;
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
      "updated_at": updatedAt?.toIso8601String(),
      "created_at": createdAt?.toIso8601String(),
      "deleted_at": deletedAt?.toIso8601String(),
      "remote_updated_at": remoteUpdatedAt?.toIso8601String(),
    };
  }

  static Account fromSql(Map<String?, dynamic> json) {
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

    return serializers.deserializeWith(Account.serializer, data)!;
  }

  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<Account> get serializer => _$accountSerializer;
}
