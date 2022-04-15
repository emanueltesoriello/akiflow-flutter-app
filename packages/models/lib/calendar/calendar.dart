library calendar;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:models/base.dart';
import 'package:models/calendar/settings.dart';
import 'package:models/serializers.dart';
import 'package:models/task/content.dart';

part 'calendar.g.dart';

abstract class Calendar extends Object
    with Base
    implements Built<Calendar, CalendarBuilder> {
  @BuiltValueField(wireName: 'id')
  String? get id;
  @BuiltValueField(wireName: 'origin_id')
  String? get originId;
  @BuiltValueField(wireName: 'connector_id')
  String? get connectorId;
  @BuiltValueField(wireName: 'akiflow_account_id')
  String? get akiflowCalendarId;
  @BuiltValueField(wireName: 'origin_account_id')
  String? get originCalendarId;
  @BuiltValueField(wireName: 'etag')
  String? get etag;
  @BuiltValueField(wireName: 'title')
  String? get title;
  @BuiltValueField(wireName: 'description')
  String? get description;
  @BuiltValueField(wireName: 'akiflow_account_id')
  String? get akiflowAccountId;
  @BuiltValueField(wireName: 'origin_account_id')
  String? get originAccountId;
  @BuiltValueField(wireName: 'content', serialize: false)
  Content? get content;

  @BuiltValueField(wireName: 'primary')
  bool? get primary;
  @BuiltValueField(wireName: 'akiflow_primary')
  bool? get akiflowPrimary;
  @BuiltValueField(wireName: 'read_only')
  bool? get readOnly;

  @BuiltValueField(wireName: 'url')
  String? get url;
  @BuiltValueField(wireName: 'color')
  String? get color;
  @BuiltValueField(wireName: 'icon')
  String? get icon;
  @BuiltValueField(wireName: 'sync_status')
  String? get syncStatus;

  @BuiltValueField(wireName: 'is_akiflow_calendar')
  bool? get isAkiflowCalendar;

  @BuiltValueField(wireName: 'settings', serialize: false)
  Settings? get settings;
  @BuiltValueField(wireName: 'global_updated_at')
  DateTime? get globalUpdatedAt;
  @BuiltValueField(wireName: 'global_created_at')
  DateTime? get globalCreatedAt;
  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;
  @BuiltValueField(wireName: 'updated_at')
  DateTime? get updatedAt;
  @BuiltValueField(wireName: 'deleted_at')
  DateTime? get deletedAt;
  @BuiltValueField(wireName: 'remote_updated_at')
  DateTime? get remoteUpdatedAt;

  Calendar._();

  factory Calendar([Function(CalendarBuilder b) updates]) = _$Calendar;

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(Calendar.serializer, this)
        as Map<String, dynamic>;
  }

  static Calendar fromMap(Map<String, dynamic> json) {
    return serializers.deserializeWith(Calendar.serializer, json)!;
  }

  @override
  Map<String, Object?> toSql() {
    return {
      "id": id,
      "origin_id": originId,
      "connector_id": connectorId,
      "akiflow_account_id": akiflowAccountId,
      "origin_account_id": originAccountId,
      "etag": etag,
      "title": title,
      "description": description,
      "content": jsonEncode(content?.toMap() ?? {}),
      "primary": primary == true ? 1 : 0,
      "akiflow_primary": akiflowPrimary == true ? 1 : 0,
      "read_only": readOnly == true ? 1 : 0,
      "url": url,
      "color": color,
      "icon": icon,
      "sync_status": syncStatus,
      "is_akiflow_calendar": isAkiflowCalendar == null,
      "settings": jsonEncode(settings?.toMap() ?? {}),
      "updated_at": updatedAt?.toIso8601String(),
      "created_at": createdAt?.toIso8601String(),
      "deleted_at": deletedAt?.toIso8601String(),
      "remote_updated_at": remoteUpdatedAt?.toIso8601String(),
    };
  }

  static Calendar fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    for (var key in data.keys) {
      switch (key) {
        case "primary":
          data[key] = (data[key] == 1);
          break;
        case "akiflow_primary":
          data[key] = (data[key] == 1);
          break;
        case "read_only":
          data[key] = (data[key] == 1);
          break;
        case "is_akiflow_calendar":
          data[key] = (data[key] == 1);
          break;
        case "content":
          data[key] = data[key] is String
              ? Content.fromMap(jsonDecode(data[key] as String))
              : null;
          break;
        case "settings":
          data[key] = data[key] is String
              ? Settings.fromMap(jsonDecode(data[key] as String))
              : null;
          break;
        default:
      }
    }

    return serializers.deserializeWith(Calendar.serializer, data)!;
  }

  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<Calendar> get serializer => _$calendarSerializer;
}
