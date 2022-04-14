import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:models/base.dart';
import 'package:models/serializers.dart';

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

  // @BuiltValueField(wireName: 'start_date')
  // DateTime? get startDate;

  // @BuiltValueField(wireName: 'end_date')
  // DateTime? get endDate;

  // @BuiltValueField(wireName: 'start_date_tz')
  // DateTime? get startDateTz;

  // @BuiltValueField(wireName: 'end_date_tz')
  // DateTime? get endDateTz;

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

    return data;
  }

  static Map<String, dynamic> toMapS(data) {
    return data.toMap();
  }

  static Event fromMap(Map<String, dynamic> json) {
    return serializers.deserializeWith(Event.serializer, json)!;
  }

  @override
  Map<String, Object?> toSql() {
    Map<String?, dynamic> data = serializers.serializeWith(
        Event.serializer, this) as Map<String?, dynamic>;

    data.remove("global_created_at");
    data.remove("global_updated_at");

    for (var key in data.keys) {
      if (data[key] is bool) {
        data[key] = data[key] ? 1 : 0;
      }
    }

    return Map<String, Object?>.from(data);
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
        default:
      }
    }

    return serializers.deserializeWith(Event.serializer, data)!;
  }

  static Serializer<Event> get serializer => _$eventSerializer;
}
