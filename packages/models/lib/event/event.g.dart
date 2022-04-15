// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Event> _$eventSerializer = new _$EventSerializer();

class _$EventSerializer implements StructuredSerializer<Event> {
  @override
  final Iterable<Type> types = const [Event, _$Event];
  @override
  final String wireName = 'Event';

  @override
  Iterable<Object?> serialize(Serializers serializers, Event object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.id;
    if (value != null) {
      result
        ..add('id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.originId;
    if (value != null) {
      result
        ..add('origin_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.customOriginId;
    if (value != null) {
      result
        ..add('custom_origin_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.connectorId;
    if (value != null) {
      result
        ..add('connector_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.accountId;
    if (value != null) {
      result
        ..add('account_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.akiflowAccountId;
    if (value != null) {
      result
        ..add('akiflow_account_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.originAccountId;
    if (value != null) {
      result
        ..add('origin_account_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.recurringId;
    if (value != null) {
      result
        ..add('recurring_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.originRecurringId;
    if (value != null) {
      result
        ..add('origin_recurring_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.calendarId;
    if (value != null) {
      result
        ..add('calendar_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.originCalendarId;
    if (value != null) {
      result
        ..add('origin_calendar_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.creatorId;
    if (value != null) {
      result
        ..add('creator_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.organizerId;
    if (value != null) {
      result
        ..add('organizer_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.originalStartTime;
    if (value != null) {
      result
        ..add('original_start_time')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.originalStartDate;
    if (value != null) {
      result
        ..add('original_start_date')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.startTime;
    if (value != null) {
      result
        ..add('start_time')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.endTime;
    if (value != null) {
      result
        ..add('end_time')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.originUpdatedAt;
    if (value != null) {
      result
        ..add('origin_updated_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.etag;
    if (value != null) {
      result
        ..add('etag')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.title;
    if (value != null) {
      result
        ..add('title')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.description;
    if (value != null) {
      result
        ..add('description')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.recurrenceException;
    if (value != null) {
      result
        ..add('recurrence_exception')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.declined;
    if (value != null) {
      result
        ..add('declined')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.readOnly;
    if (value != null) {
      result
        ..add('read_only')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.hidden;
    if (value != null) {
      result
        ..add('hidden')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.recurrenceExceptionDelete;
    if (value != null) {
      result
        ..add('recurrence_exception_delete')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.url;
    if (value != null) {
      result
        ..add('url')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.meetingStatus;
    if (value != null) {
      result
        ..add('meeting_status')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.meetingUrl;
    if (value != null) {
      result
        ..add('meeting_url')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.meetingIcon;
    if (value != null) {
      result
        ..add('meeting_icon')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.meetingSolution;
    if (value != null) {
      result
        ..add('meeting_solution')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.color;
    if (value != null) {
      result
        ..add('color')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.calendarColor;
    if (value != null) {
      result
        ..add('calendar_color')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.taskId;
    if (value != null) {
      result
        ..add('task_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.content;
    if (value != null) {
      result
        ..add('content')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(Content)));
    }
    value = object.attendees;
    if (value != null) {
      result
        ..add('attendees')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(ListJsonObject)));
    }
    value = object.recurrence;
    if (value != null) {
      result
        ..add('recurrence')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(List, const [const FullType(String)])));
    }
    value = object.fingerprints;
    if (value != null) {
      result
        ..add('fingerprints')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(JsonObject)));
    }
    value = object.startDate;
    if (value != null) {
      result
        ..add('start_date')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.endDate;
    if (value != null) {
      result
        ..add('end_date')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.startDateTimeTz;
    if (value != null) {
      result
        ..add('start_date_time_tz')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.endDateTimeTz;
    if (value != null) {
      result
        ..add('end_date_time_tz')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.remoteUpdatedAt;
    if (value != null) {
      result
        ..add('remote_updated_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.createdAt;
    if (value != null) {
      result
        ..add('created_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.updatedAt;
    if (value != null) {
      result
        ..add('updated_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.deletedAt;
    if (value != null) {
      result
        ..add('deleted_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.untilDateTime;
    if (value != null) {
      result
        ..add('until_date_time')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.recurrenceSyncRetry;
    if (value != null) {
      result
        ..add('recurrence_sync_retry')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.globalUpdatedAt;
    if (value != null) {
      result
        ..add('global_updated_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.globalCreatedAt;
    if (value != null) {
      result
        ..add('global_created_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    return result;
  }

  @override
  Event deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new EventBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'origin_id':
          result.originId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'custom_origin_id':
          result.customOriginId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'connector_id':
          result.connectorId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'account_id':
          result.accountId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'akiflow_account_id':
          result.akiflowAccountId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'origin_account_id':
          result.originAccountId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'recurring_id':
          result.recurringId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'origin_recurring_id':
          result.originRecurringId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'calendar_id':
          result.calendarId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'origin_calendar_id':
          result.originCalendarId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'creator_id':
          result.creatorId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'organizer_id':
          result.organizerId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'original_start_time':
          result.originalStartTime = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'original_start_date':
          result.originalStartDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'start_time':
          result.startTime = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'end_time':
          result.endTime = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'origin_updated_at':
          result.originUpdatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'etag':
          result.etag = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'description':
          result.description = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'recurrence_exception':
          result.recurrenceException = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'declined':
          result.declined = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'read_only':
          result.readOnly = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'hidden':
          result.hidden = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'recurrence_exception_delete':
          result.recurrenceExceptionDelete = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'url':
          result.url = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'meeting_status':
          result.meetingStatus = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'meeting_url':
          result.meetingUrl = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'meeting_icon':
          result.meetingIcon = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'meeting_solution':
          result.meetingSolution = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'color':
          result.color = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'calendar_color':
          result.calendarColor = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'task_id':
          result.taskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'content':
          result.content.replace(serializers.deserialize(value,
              specifiedType: const FullType(Content))! as Content);
          break;
        case 'attendees':
          result.attendees = serializers.deserialize(value,
              specifiedType: const FullType(ListJsonObject)) as ListJsonObject?;
          break;
        case 'recurrence':
          result.recurrence = serializers.deserialize(value,
                  specifiedType:
                      const FullType(List, const [const FullType(String)]))
              as List<String>?;
          break;
        case 'fingerprints':
          result.fingerprints = serializers.deserialize(value,
              specifiedType: const FullType(JsonObject)) as JsonObject?;
          break;
        case 'start_date':
          result.startDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'end_date':
          result.endDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'start_date_time_tz':
          result.startDateTimeTz = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'end_date_time_tz':
          result.endDateTimeTz = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'remote_updated_at':
          result.remoteUpdatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'created_at':
          result.createdAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'updated_at':
          result.updatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'deleted_at':
          result.deletedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'until_date_time':
          result.untilDateTime = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'recurrence_sync_retry':
          result.recurrenceSyncRetry = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'global_updated_at':
          result.globalUpdatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'global_created_at':
          result.globalCreatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
      }
    }

    return result.build();
  }
}

class _$Event extends Event {
  @override
  final String? id;
  @override
  final String? originId;
  @override
  final String? customOriginId;
  @override
  final String? connectorId;
  @override
  final String? accountId;
  @override
  final String? akiflowAccountId;
  @override
  final String? originAccountId;
  @override
  final String? recurringId;
  @override
  final String? originRecurringId;
  @override
  final String? calendarId;
  @override
  final String? originCalendarId;
  @override
  final String? creatorId;
  @override
  final String? organizerId;
  @override
  final DateTime? originalStartTime;
  @override
  final DateTime? originalStartDate;
  @override
  final DateTime? startTime;
  @override
  final DateTime? endTime;
  @override
  final DateTime? originUpdatedAt;
  @override
  final String? etag;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final bool? recurrenceException;
  @override
  final bool? declined;
  @override
  final bool? readOnly;
  @override
  final bool? hidden;
  @override
  final bool? recurrenceExceptionDelete;
  @override
  final String? url;
  @override
  final String? meetingStatus;
  @override
  final String? meetingUrl;
  @override
  final String? meetingIcon;
  @override
  final String? meetingSolution;
  @override
  final String? color;
  @override
  final String? calendarColor;
  @override
  final String? taskId;
  @override
  final Content? content;
  @override
  final ListJsonObject? attendees;
  @override
  final List<String>? recurrence;
  @override
  final JsonObject? fingerprints;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  final DateTime? startDateTimeTz;
  @override
  final DateTime? endDateTimeTz;
  @override
  final DateTime? remoteUpdatedAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final DateTime? untilDateTime;
  @override
  final DateTime? recurrenceSyncRetry;
  @override
  final DateTime? globalUpdatedAt;
  @override
  final DateTime? globalCreatedAt;

  factory _$Event([void Function(EventBuilder)? updates]) =>
      (new EventBuilder()..update(updates)).build();

  _$Event._(
      {this.id,
      this.originId,
      this.customOriginId,
      this.connectorId,
      this.accountId,
      this.akiflowAccountId,
      this.originAccountId,
      this.recurringId,
      this.originRecurringId,
      this.calendarId,
      this.originCalendarId,
      this.creatorId,
      this.organizerId,
      this.originalStartTime,
      this.originalStartDate,
      this.startTime,
      this.endTime,
      this.originUpdatedAt,
      this.etag,
      this.title,
      this.description,
      this.recurrenceException,
      this.declined,
      this.readOnly,
      this.hidden,
      this.recurrenceExceptionDelete,
      this.url,
      this.meetingStatus,
      this.meetingUrl,
      this.meetingIcon,
      this.meetingSolution,
      this.color,
      this.calendarColor,
      this.taskId,
      this.content,
      this.attendees,
      this.recurrence,
      this.fingerprints,
      this.startDate,
      this.endDate,
      this.startDateTimeTz,
      this.endDateTimeTz,
      this.remoteUpdatedAt,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.untilDateTime,
      this.recurrenceSyncRetry,
      this.globalUpdatedAt,
      this.globalCreatedAt})
      : super._();

  @override
  Event rebuild(void Function(EventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EventBuilder toBuilder() => new EventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Event &&
        id == other.id &&
        originId == other.originId &&
        customOriginId == other.customOriginId &&
        connectorId == other.connectorId &&
        accountId == other.accountId &&
        akiflowAccountId == other.akiflowAccountId &&
        originAccountId == other.originAccountId &&
        recurringId == other.recurringId &&
        originRecurringId == other.originRecurringId &&
        calendarId == other.calendarId &&
        originCalendarId == other.originCalendarId &&
        creatorId == other.creatorId &&
        organizerId == other.organizerId &&
        originalStartTime == other.originalStartTime &&
        originalStartDate == other.originalStartDate &&
        startTime == other.startTime &&
        endTime == other.endTime &&
        originUpdatedAt == other.originUpdatedAt &&
        etag == other.etag &&
        title == other.title &&
        description == other.description &&
        recurrenceException == other.recurrenceException &&
        declined == other.declined &&
        readOnly == other.readOnly &&
        hidden == other.hidden &&
        recurrenceExceptionDelete == other.recurrenceExceptionDelete &&
        url == other.url &&
        meetingStatus == other.meetingStatus &&
        meetingUrl == other.meetingUrl &&
        meetingIcon == other.meetingIcon &&
        meetingSolution == other.meetingSolution &&
        color == other.color &&
        calendarColor == other.calendarColor &&
        taskId == other.taskId &&
        content == other.content &&
        attendees == other.attendees &&
        recurrence == other.recurrence &&
        fingerprints == other.fingerprints &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        startDateTimeTz == other.startDateTimeTz &&
        endDateTimeTz == other.endDateTimeTz &&
        remoteUpdatedAt == other.remoteUpdatedAt &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        untilDateTime == other.untilDateTime &&
        recurrenceSyncRetry == other.recurrenceSyncRetry &&
        globalUpdatedAt == other.globalUpdatedAt &&
        globalCreatedAt == other.globalCreatedAt;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc(
                                                $jc(
                                                    $jc(
                                                        $jc(
                                                            $jc(
                                                                $jc(
                                                                    $jc(
                                                                        $jc(
                                                                            $jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc($jc(0, id.hashCode), originId.hashCode), customOriginId.hashCode), connectorId.hashCode), accountId.hashCode), akiflowAccountId.hashCode), originAccountId.hashCode), recurringId.hashCode), originRecurringId.hashCode), calendarId.hashCode), originCalendarId.hashCode), creatorId.hashCode), organizerId.hashCode), originalStartTime.hashCode), originalStartDate.hashCode), startTime.hashCode), endTime.hashCode), originUpdatedAt.hashCode), etag.hashCode), title.hashCode), description.hashCode), recurrenceException.hashCode), declined.hashCode), readOnly.hashCode), hidden.hashCode), recurrenceExceptionDelete.hashCode), url.hashCode), meetingStatus.hashCode), meetingUrl.hashCode), meetingIcon.hashCode), meetingSolution.hashCode),
                                                                                color.hashCode),
                                                                            calendarColor.hashCode),
                                                                        taskId.hashCode),
                                                                    content.hashCode),
                                                                attendees.hashCode),
                                                            recurrence.hashCode),
                                                        fingerprints.hashCode),
                                                    startDate.hashCode),
                                                endDate.hashCode),
                                            startDateTimeTz.hashCode),
                                        endDateTimeTz.hashCode),
                                    remoteUpdatedAt.hashCode),
                                createdAt.hashCode),
                            updatedAt.hashCode),
                        deletedAt.hashCode),
                    untilDateTime.hashCode),
                recurrenceSyncRetry.hashCode),
            globalUpdatedAt.hashCode),
        globalCreatedAt.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Event')
          ..add('id', id)
          ..add('originId', originId)
          ..add('customOriginId', customOriginId)
          ..add('connectorId', connectorId)
          ..add('accountId', accountId)
          ..add('akiflowAccountId', akiflowAccountId)
          ..add('originAccountId', originAccountId)
          ..add('recurringId', recurringId)
          ..add('originRecurringId', originRecurringId)
          ..add('calendarId', calendarId)
          ..add('originCalendarId', originCalendarId)
          ..add('creatorId', creatorId)
          ..add('organizerId', organizerId)
          ..add('originalStartTime', originalStartTime)
          ..add('originalStartDate', originalStartDate)
          ..add('startTime', startTime)
          ..add('endTime', endTime)
          ..add('originUpdatedAt', originUpdatedAt)
          ..add('etag', etag)
          ..add('title', title)
          ..add('description', description)
          ..add('recurrenceException', recurrenceException)
          ..add('declined', declined)
          ..add('readOnly', readOnly)
          ..add('hidden', hidden)
          ..add('recurrenceExceptionDelete', recurrenceExceptionDelete)
          ..add('url', url)
          ..add('meetingStatus', meetingStatus)
          ..add('meetingUrl', meetingUrl)
          ..add('meetingIcon', meetingIcon)
          ..add('meetingSolution', meetingSolution)
          ..add('color', color)
          ..add('calendarColor', calendarColor)
          ..add('taskId', taskId)
          ..add('content', content)
          ..add('attendees', attendees)
          ..add('recurrence', recurrence)
          ..add('fingerprints', fingerprints)
          ..add('startDate', startDate)
          ..add('endDate', endDate)
          ..add('startDateTimeTz', startDateTimeTz)
          ..add('endDateTimeTz', endDateTimeTz)
          ..add('remoteUpdatedAt', remoteUpdatedAt)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt)
          ..add('untilDateTime', untilDateTime)
          ..add('recurrenceSyncRetry', recurrenceSyncRetry)
          ..add('globalUpdatedAt', globalUpdatedAt)
          ..add('globalCreatedAt', globalCreatedAt))
        .toString();
  }
}

class EventBuilder implements Builder<Event, EventBuilder> {
  _$Event? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _originId;
  String? get originId => _$this._originId;
  set originId(String? originId) => _$this._originId = originId;

  String? _customOriginId;
  String? get customOriginId => _$this._customOriginId;
  set customOriginId(String? customOriginId) =>
      _$this._customOriginId = customOriginId;

  String? _connectorId;
  String? get connectorId => _$this._connectorId;
  set connectorId(String? connectorId) => _$this._connectorId = connectorId;

  String? _accountId;
  String? get accountId => _$this._accountId;
  set accountId(String? accountId) => _$this._accountId = accountId;

  String? _akiflowAccountId;
  String? get akiflowAccountId => _$this._akiflowAccountId;
  set akiflowAccountId(String? akiflowAccountId) =>
      _$this._akiflowAccountId = akiflowAccountId;

  String? _originAccountId;
  String? get originAccountId => _$this._originAccountId;
  set originAccountId(String? originAccountId) =>
      _$this._originAccountId = originAccountId;

  String? _recurringId;
  String? get recurringId => _$this._recurringId;
  set recurringId(String? recurringId) => _$this._recurringId = recurringId;

  String? _originRecurringId;
  String? get originRecurringId => _$this._originRecurringId;
  set originRecurringId(String? originRecurringId) =>
      _$this._originRecurringId = originRecurringId;

  String? _calendarId;
  String? get calendarId => _$this._calendarId;
  set calendarId(String? calendarId) => _$this._calendarId = calendarId;

  String? _originCalendarId;
  String? get originCalendarId => _$this._originCalendarId;
  set originCalendarId(String? originCalendarId) =>
      _$this._originCalendarId = originCalendarId;

  String? _creatorId;
  String? get creatorId => _$this._creatorId;
  set creatorId(String? creatorId) => _$this._creatorId = creatorId;

  String? _organizerId;
  String? get organizerId => _$this._organizerId;
  set organizerId(String? organizerId) => _$this._organizerId = organizerId;

  DateTime? _originalStartTime;
  DateTime? get originalStartTime => _$this._originalStartTime;
  set originalStartTime(DateTime? originalStartTime) =>
      _$this._originalStartTime = originalStartTime;

  DateTime? _originalStartDate;
  DateTime? get originalStartDate => _$this._originalStartDate;
  set originalStartDate(DateTime? originalStartDate) =>
      _$this._originalStartDate = originalStartDate;

  DateTime? _startTime;
  DateTime? get startTime => _$this._startTime;
  set startTime(DateTime? startTime) => _$this._startTime = startTime;

  DateTime? _endTime;
  DateTime? get endTime => _$this._endTime;
  set endTime(DateTime? endTime) => _$this._endTime = endTime;

  DateTime? _originUpdatedAt;
  DateTime? get originUpdatedAt => _$this._originUpdatedAt;
  set originUpdatedAt(DateTime? originUpdatedAt) =>
      _$this._originUpdatedAt = originUpdatedAt;

  String? _etag;
  String? get etag => _$this._etag;
  set etag(String? etag) => _$this._etag = etag;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  bool? _recurrenceException;
  bool? get recurrenceException => _$this._recurrenceException;
  set recurrenceException(bool? recurrenceException) =>
      _$this._recurrenceException = recurrenceException;

  bool? _declined;
  bool? get declined => _$this._declined;
  set declined(bool? declined) => _$this._declined = declined;

  bool? _readOnly;
  bool? get readOnly => _$this._readOnly;
  set readOnly(bool? readOnly) => _$this._readOnly = readOnly;

  bool? _hidden;
  bool? get hidden => _$this._hidden;
  set hidden(bool? hidden) => _$this._hidden = hidden;

  bool? _recurrenceExceptionDelete;
  bool? get recurrenceExceptionDelete => _$this._recurrenceExceptionDelete;
  set recurrenceExceptionDelete(bool? recurrenceExceptionDelete) =>
      _$this._recurrenceExceptionDelete = recurrenceExceptionDelete;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _meetingStatus;
  String? get meetingStatus => _$this._meetingStatus;
  set meetingStatus(String? meetingStatus) =>
      _$this._meetingStatus = meetingStatus;

  String? _meetingUrl;
  String? get meetingUrl => _$this._meetingUrl;
  set meetingUrl(String? meetingUrl) => _$this._meetingUrl = meetingUrl;

  String? _meetingIcon;
  String? get meetingIcon => _$this._meetingIcon;
  set meetingIcon(String? meetingIcon) => _$this._meetingIcon = meetingIcon;

  String? _meetingSolution;
  String? get meetingSolution => _$this._meetingSolution;
  set meetingSolution(String? meetingSolution) =>
      _$this._meetingSolution = meetingSolution;

  String? _color;
  String? get color => _$this._color;
  set color(String? color) => _$this._color = color;

  String? _calendarColor;
  String? get calendarColor => _$this._calendarColor;
  set calendarColor(String? calendarColor) =>
      _$this._calendarColor = calendarColor;

  String? _taskId;
  String? get taskId => _$this._taskId;
  set taskId(String? taskId) => _$this._taskId = taskId;

  ContentBuilder? _content;
  ContentBuilder get content => _$this._content ??= new ContentBuilder();
  set content(ContentBuilder? content) => _$this._content = content;

  ListJsonObject? _attendees;
  ListJsonObject? get attendees => _$this._attendees;
  set attendees(ListJsonObject? attendees) => _$this._attendees = attendees;

  List<String>? _recurrence;
  List<String>? get recurrence => _$this._recurrence;
  set recurrence(List<String>? recurrence) => _$this._recurrence = recurrence;

  JsonObject? _fingerprints;
  JsonObject? get fingerprints => _$this._fingerprints;
  set fingerprints(JsonObject? fingerprints) =>
      _$this._fingerprints = fingerprints;

  DateTime? _startDate;
  DateTime? get startDate => _$this._startDate;
  set startDate(DateTime? startDate) => _$this._startDate = startDate;

  DateTime? _endDate;
  DateTime? get endDate => _$this._endDate;
  set endDate(DateTime? endDate) => _$this._endDate = endDate;

  DateTime? _startDateTimeTz;
  DateTime? get startDateTimeTz => _$this._startDateTimeTz;
  set startDateTimeTz(DateTime? startDateTimeTz) =>
      _$this._startDateTimeTz = startDateTimeTz;

  DateTime? _endDateTimeTz;
  DateTime? get endDateTimeTz => _$this._endDateTimeTz;
  set endDateTimeTz(DateTime? endDateTimeTz) =>
      _$this._endDateTimeTz = endDateTimeTz;

  DateTime? _remoteUpdatedAt;
  DateTime? get remoteUpdatedAt => _$this._remoteUpdatedAt;
  set remoteUpdatedAt(DateTime? remoteUpdatedAt) =>
      _$this._remoteUpdatedAt = remoteUpdatedAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  DateTime? _untilDateTime;
  DateTime? get untilDateTime => _$this._untilDateTime;
  set untilDateTime(DateTime? untilDateTime) =>
      _$this._untilDateTime = untilDateTime;

  DateTime? _recurrenceSyncRetry;
  DateTime? get recurrenceSyncRetry => _$this._recurrenceSyncRetry;
  set recurrenceSyncRetry(DateTime? recurrenceSyncRetry) =>
      _$this._recurrenceSyncRetry = recurrenceSyncRetry;

  DateTime? _globalUpdatedAt;
  DateTime? get globalUpdatedAt => _$this._globalUpdatedAt;
  set globalUpdatedAt(DateTime? globalUpdatedAt) =>
      _$this._globalUpdatedAt = globalUpdatedAt;

  DateTime? _globalCreatedAt;
  DateTime? get globalCreatedAt => _$this._globalCreatedAt;
  set globalCreatedAt(DateTime? globalCreatedAt) =>
      _$this._globalCreatedAt = globalCreatedAt;

  EventBuilder();

  EventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _originId = $v.originId;
      _customOriginId = $v.customOriginId;
      _connectorId = $v.connectorId;
      _accountId = $v.accountId;
      _akiflowAccountId = $v.akiflowAccountId;
      _originAccountId = $v.originAccountId;
      _recurringId = $v.recurringId;
      _originRecurringId = $v.originRecurringId;
      _calendarId = $v.calendarId;
      _originCalendarId = $v.originCalendarId;
      _creatorId = $v.creatorId;
      _organizerId = $v.organizerId;
      _originalStartTime = $v.originalStartTime;
      _originalStartDate = $v.originalStartDate;
      _startTime = $v.startTime;
      _endTime = $v.endTime;
      _originUpdatedAt = $v.originUpdatedAt;
      _etag = $v.etag;
      _title = $v.title;
      _description = $v.description;
      _recurrenceException = $v.recurrenceException;
      _declined = $v.declined;
      _readOnly = $v.readOnly;
      _hidden = $v.hidden;
      _recurrenceExceptionDelete = $v.recurrenceExceptionDelete;
      _url = $v.url;
      _meetingStatus = $v.meetingStatus;
      _meetingUrl = $v.meetingUrl;
      _meetingIcon = $v.meetingIcon;
      _meetingSolution = $v.meetingSolution;
      _color = $v.color;
      _calendarColor = $v.calendarColor;
      _taskId = $v.taskId;
      _content = $v.content?.toBuilder();
      _attendees = $v.attendees;
      _recurrence = $v.recurrence;
      _fingerprints = $v.fingerprints;
      _startDate = $v.startDate;
      _endDate = $v.endDate;
      _startDateTimeTz = $v.startDateTimeTz;
      _endDateTimeTz = $v.endDateTimeTz;
      _remoteUpdatedAt = $v.remoteUpdatedAt;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _untilDateTime = $v.untilDateTime;
      _recurrenceSyncRetry = $v.recurrenceSyncRetry;
      _globalUpdatedAt = $v.globalUpdatedAt;
      _globalCreatedAt = $v.globalCreatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Event other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Event;
  }

  @override
  void update(void Function(EventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Event build() {
    _$Event _$result;
    try {
      _$result = _$v ??
          new _$Event._(
              id: id,
              originId: originId,
              customOriginId: customOriginId,
              connectorId: connectorId,
              accountId: accountId,
              akiflowAccountId: akiflowAccountId,
              originAccountId: originAccountId,
              recurringId: recurringId,
              originRecurringId: originRecurringId,
              calendarId: calendarId,
              originCalendarId: originCalendarId,
              creatorId: creatorId,
              organizerId: organizerId,
              originalStartTime: originalStartTime,
              originalStartDate: originalStartDate,
              startTime: startTime,
              endTime: endTime,
              originUpdatedAt: originUpdatedAt,
              etag: etag,
              title: title,
              description: description,
              recurrenceException: recurrenceException,
              declined: declined,
              readOnly: readOnly,
              hidden: hidden,
              recurrenceExceptionDelete: recurrenceExceptionDelete,
              url: url,
              meetingStatus: meetingStatus,
              meetingUrl: meetingUrl,
              meetingIcon: meetingIcon,
              meetingSolution: meetingSolution,
              color: color,
              calendarColor: calendarColor,
              taskId: taskId,
              content: _content?.build(),
              attendees: attendees,
              recurrence: recurrence,
              fingerprints: fingerprints,
              startDate: startDate,
              endDate: endDate,
              startDateTimeTz: startDateTimeTz,
              endDateTimeTz: endDateTimeTz,
              remoteUpdatedAt: remoteUpdatedAt,
              createdAt: createdAt,
              updatedAt: updatedAt,
              deletedAt: deletedAt,
              untilDateTime: untilDateTime,
              recurrenceSyncRetry: recurrenceSyncRetry,
              globalUpdatedAt: globalUpdatedAt,
              globalCreatedAt: globalCreatedAt);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        _content?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Event', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
