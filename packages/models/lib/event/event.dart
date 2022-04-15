import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:intl/intl.dart';
import 'package:models/base.dart';
import 'package:models/serializers.dart';
import 'package:models/task/content.dart';

part 'event.g.dart';

abstract class Event extends Object
    with Base
    implements Built<Event, EventBuilder> {
  @BuiltValueField(wireName: 'id')
  String? get id;

  @BuiltValueField(wireName: 'origin_id')
  String? get originId;

  @BuiltValueField(wireName: 'custom_origin_id')
  String? get customOriginId;

  @BuiltValueField(wireName: 'connector_id')
  String? get connectorId;

  @BuiltValueField(wireName: 'account_id')
  String? get accountId;

  @BuiltValueField(wireName: 'akiflow_account_id')
  String? get akiflowAccountId;

  @BuiltValueField(wireName: 'origin_account_id')
  String? get originAccountId;

  @BuiltValueField(wireName: 'recurring_id')
  String? get recurringId;

  @BuiltValueField(wireName: 'origin_recurring_id')
  String? get originRecurringId;

  @BuiltValueField(wireName: 'calendar_id')
  String? get calendarId;

  @BuiltValueField(wireName: 'origin_calendar_id')
  String? get originCalendarId;

  @BuiltValueField(wireName: 'creator_id')
  String? get creatorId;

  @BuiltValueField(wireName: 'organizer_id')
  String? get organizerId;

  @BuiltValueField(wireName: 'original_start_time')
  DateTime? get originalStartTime;

  @BuiltValueField(wireName: 'original_start_date')
  DateTime? get originalStartDate;

  @BuiltValueField(wireName: 'start_time')
  DateTime? get startTime;

  @BuiltValueField(wireName: 'end_time')
  DateTime? get endTime;

  @BuiltValueField(wireName: 'origin_updated_at')
  DateTime? get originUpdatedAt;

  @BuiltValueField(wireName: 'etag')
  String? get etag;

  @BuiltValueField(wireName: 'title')
  String? get title;

  @BuiltValueField(wireName: 'description')
  String? get description;

  @BuiltValueField(wireName: 'recurrence_exception')
  bool? get recurrenceException;

  @BuiltValueField(wireName: 'declined')
  bool? get declined;

  @BuiltValueField(wireName: 'read_only')
  bool? get readOnly;

  @BuiltValueField(wireName: 'hidden')
  bool? get hidden;

  @BuiltValueField(wireName: 'recurrence_exception_delete')
  bool? get recurrenceExceptionDelete;

  @BuiltValueField(wireName: 'url')
  String? get url;

  @BuiltValueField(wireName: 'meeting_status')
  String? get meetingStatus;

  @BuiltValueField(wireName: 'meeting_url')
  String? get meetingUrl;

  @BuiltValueField(wireName: 'meeting_icon')
  String? get meetingIcon;

  @BuiltValueField(wireName: 'meeting_solution')
  String? get meetingSolution;

  @BuiltValueField(wireName: 'color')
  String? get color;

  @BuiltValueField(wireName: 'calendar_color')
  String? get calendarColor;

  @BuiltValueField(wireName: 'task_id')
  String? get taskId;

  @BuiltValueField(wireName: 'content', serialize: false)
  Content? get content;

  @BuiltValueField(wireName: 'attendees')
  ListJsonObject? get attendees;

  @BuiltValueField(wireName: 'recurrence')
  ListJsonObject? get recurrence;

  @BuiltValueField(wireName: 'fingerprints')
  JsonObject? get fingerprints;

  @BuiltValueField(wireName: 'start_date')
  DateTime? get startDate;

  @BuiltValueField(wireName: 'end_date')
  DateTime? get endDate;

  @BuiltValueField(wireName: 'start_date_time_tz')
  DateTime? get startDateTimeTz;

  @BuiltValueField(wireName: 'end_date_time_tz')
  DateTime? get endDateTimeTz;

  @BuiltValueField(wireName: 'remote_updated_at')
  DateTime? get remoteUpdatedAt;

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: 'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: 'deleted_at')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: 'until_date_time')
  DateTime? get untilDateTime;

  @BuiltValueField(wireName: 'recurrence_sync_retry')
  DateTime? get recurrenceSyncRetry;

  @BuiltValueField(wireName: 'global_updated_at')
  DateTime? get globalUpdatedAt;

  @BuiltValueField(wireName: 'global_created_at')
  DateTime? get globalCreatedAt;

  Event._();

  factory Event([void Function(EventBuilder) updates]) = _$Event;

  @override
  Event rebuild(void Function(EventBuilder) updates);

  @override
  EventBuilder toBuilder();

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = serializers.serializeWith(
        Event.serializer, this) as Map<String, dynamic>;

    if (startDate != null) {
      data['start_date'] = DateFormat('yyyy-MM-dd').format(startDate!);
    }
    if (endDate != null) {
      data['end_date'] = DateFormat('yyyy-MM-dd').format(endDate!);
    }

    return data;
  }

  static Event fromMap(Map<String, dynamic> json) {
    return serializers.deserializeWith(Event.serializer, json)!;
  }

  @override
  Map<String, Object?> toSql() {
    return {
      "id": id,
      "origin_id": originId,
      "custom_origin_id": customOriginId,
      "connector_id": connectorId,
      "akiflow_account_id": akiflowAccountId,
      "origin_account_id": originAccountId,
      "recurring_id": recurringId,
      "origin_recurring_id": originRecurringId,
      "calendar_id": calendarId,
      "origin_calendar_id": originCalendarId,
      "creator_id": creatorId,
      "organizer_id": organizerId,
      "original_start_time": originalStartTime?.toIso8601String(),
      "original_start_date": originalStartDate?.toIso8601String(),
      "start_time": startTime?.toIso8601String(),
      "end_time": endTime?.toIso8601String(),
      "start_date": startDate?.toIso8601String(),
      "end_date": endDate?.toIso8601String(),
      "start_date_time_tz": startDateTimeTz?.toIso8601String(),
      "end_date_time_tz": endDateTimeTz?.toIso8601String(),
      "origin_updated_at": originUpdatedAt?.toIso8601String(),
      "etag": etag,
      "title": title,
      "description": description,
      "content": jsonEncode(content?.toMap() ?? {}),
      "attendees": jsonEncode(attendees?.value ?? []),
      "recurrence": jsonEncode(recurrence?.value ?? []),
      "recurrence_exception": recurrenceException == true ? 1 : 0,
      "declined": declined == true ? 1 : 0,
      "read_only": readOnly == true ? 1 : 0,
      "hidden": hidden == true ? 1 : 0,
      "url": url,
      "meeting_status": meetingStatus,
      "meeting_url": meetingUrl,
      "meeting_icon": meetingIcon,
      "meeting_solution": meetingSolution,
      "color": color,
      "calendar_color": calendarColor,
      "task_id": taskId,
      "fingerprints": jsonEncode(fingerprints?.value ?? {}),
      "until_date_time": untilDateTime?.toIso8601String(),
      "recurrence_exception_delete": recurrenceExceptionDelete == true ? 1 : 0,
      "recurrence_sync_retry": recurrenceSyncRetry?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
      "created_at": createdAt?.toIso8601String(),
      "deleted_at": deletedAt?.toIso8601String(),
      "remote_updated_at": remoteUpdatedAt?.toIso8601String(),
    };
  }

  static Event fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    for (var key in data.keys) {
      switch (key) {
        case "done":
          data[key] = (data[key] == 1);
          break;
        case "recurrence_exception":
          data[key] = (data[key] == 1);
          break;
        case "declined":
          data[key] = (data[key] == 1);
          break;
        case "read_only":
          data[key] = (data[key] == 1);
          break;
        case "hidden":
          data[key] = (data[key] == 1);
          break;
        case "recurrence_exception_delete":
          data[key] = (data[key] == 1);
          break;
        case "content":
          data[key] = data[key] is String
              ? Content.fromMap(jsonDecode(data[key] as String))
              : null;
          break;
        case "attendees":
        case "recurrence":
        case "fingerprints":
          data[key] =
              data[key] is String ? (jsonDecode(data[key] as String)) : null;
          break;
        default:
      }
    }

    return serializers.deserializeWith(Event.serializer, data)!;
  }

  static Serializer<Event> get serializer => _$eventSerializer;
}
