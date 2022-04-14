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

  @BuiltValueField(wireName: 'first_time_sync_executed')
  bool? get firstTimeSyncExecuted;

  @BuiltValueField(wireName: 'last_accounts_sync_at')
  DateTime? get lastAccountsSyncAt;

  @BuiltValueField(wireName: 'last_labels_sync_at')
  DateTime? get lastLabelsSyncAt;

  @BuiltValueField(wireName: 'last_tasks_sync_at')
  DateTime? get lastTasksSyncAt;

  @BuiltValueField(wireName: 'last_calendars_sync_at')
  DateTime? get lastCalendarsSyncAt;

  @BuiltValueField(wireName: 'last_events_sync_at')
  DateTime? get lastEventsSyncAt;

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
    Map<String?, dynamic> data = serializers.serializeWith(
        Account.serializer, this) as Map<String?, dynamic>;

    data.remove("global_created_at");
    data.remove("global_updated_at");

    for (var key in data.keys) {
      if (data[key] is bool) {
        data[key] = data[key] ? 1 : 0;
      }

      if (key == "local_details" && data[key] != null) {
        data[key] = jsonEncode(Map.from(data[key]));
      }
    }

    return Map<String, Object?>.from(data);
  }

  static Account fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    // print("local_details raw: ${data["local_details"]}");

    if (data["local_details"] != null) {
      data["local_details"] =
          jsonDecode(data["local_details"] as String? ?? "");
    }

    Account account = serializers.deserializeWith(Account.serializer, data)!;

    // print("parsed: ${account.localDetails}");

    return account;
  }

  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<Account> get serializer => _$accountSerializer;
}
