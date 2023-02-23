import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:models/base.dart';
import 'package:models/event/event_atendee.dart';
import 'package:models/nullable.dart';

class Event extends Equatable implements Base {
  const Event({
    this.id,
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
    this.startDatetimeTz,
    this.startDate,
    this.endDate,
    this.endDatetimeTz,
    this.originUpdatedAt,
    this.etag,
    this.title,
    this.description,
    this.content,
    this.attendees,
    this.recurrence,
    this.recurrenceException,
    this.declined,
    this.readOnly,
    this.hidden,
    this.url,
    this.meetingStatus,
    this.meetingUrl,
    this.meetingIcon,
    this.meetingSolution,
    this.color,
    this.calendarColor,
    this.taskId,
    this.fingerprints,
    this.globalUpdatedAt,
    this.globalCreatedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.untilDatetime,
    this.recurrenceExceptionDelete,
    this.recurrenceSyncRetry,
    this.remoteUpdatedAt,
    this.status,
    this.oldId,
  });

  final String? id;
  final String? originId;
  final String? customOriginId;
  final String? connectorId;
  final String? accountId;
  final String? akiflowAccountId;
  final String? originAccountId;
  final String? recurringId;
  final String? originRecurringId;
  final String? calendarId;
  final String? originCalendarId;
  final String? creatorId;
  final String? organizerId;
  final String? originalStartTime;
  final String? originalStartDate;
  final String? startTime;
  final String? endTime;
  final String? startDatetimeTz;
  final String? startDate;
  final String? endDate;
  final String? endDatetimeTz;
  final String? originUpdatedAt;
  final String? etag;
  final String? title;
  final String? description;
  final dynamic content;
  final List<EventAtendee>? attendees;
  final List<String>? recurrence;
  final bool? recurrenceException;
  final bool? declined;
  final bool? readOnly;
  final bool? hidden;
  final String? url;
  final String? meetingStatus;
  final String? meetingUrl;
  final String? meetingIcon;
  final String? meetingSolution;
  final String? color;
  final String? calendarColor;
  final String? taskId;
  final dynamic fingerprints;
  final String? globalUpdatedAt;
  final String? globalCreatedAt;
  final String? createdAt;
  final String? updatedAt;
  final dynamic deletedAt;
  final String? createdBy;
  final String? untilDatetime;
  final bool? recurrenceExceptionDelete;
  final int? recurrenceSyncRetry;
  final String? remoteUpdatedAt;
  final String? status;
  final String? oldId;

  factory Event.fromMap(Map<String, dynamic> json) => Event(
        id: json['id'] as String?,
        originId: json['origin_id'] as String?,
        customOriginId: json['custom_origin_id'] as String?,
        accountId: json['account_id'] as String?,
        connectorId: json['connector_id'] as String?,
        akiflowAccountId: json['akiflow_account_id'] as String?,
        originAccountId: json['origin_account_id'] as String?,
        recurringId: json['recurring_id'] as String?,
        originRecurringId: json['origin_recurring_id'] as String?,
        calendarId: json['calendar_id'] as String?,
        originCalendarId: json['origin_calendar_id'] as String?,
        creatorId: json['creator_id'] as String?,
        organizerId: json['organizer_id'] as String?,
        originalStartTime: json['original_start_time'] as String?,
        originalStartDate: json['original_start_date'] as String?,
        startTime: json['start_time'] as String?,
        endTime: json['end_time'] as String?,
        startDatetimeTz: json['start_datetime_tz'] as String?,
        startDate: json['start_date'] as String?,
        endDate: json['end_date'] as String?,
        endDatetimeTz: json['end_datetime_tz'] as String?,
        originUpdatedAt: json['origin_updated_at'] as String?,
        etag: json['etag'] as String?,
        title: json['title'] as String?,
        description: json['description'] as String?,
        content: json['content'] as dynamic,
        attendees:
            json['attendees'] != null ? (json['attendees'] as List).map((i) => EventAtendee.fromMap(i)).toList() : null,
        recurrence: json['recurrence'] != null ? List<String>.from(json['recurrence'] as List<dynamic>) : null,
        recurrenceException: json['recurrence_exception'] as bool?,
        declined: json['declined'] as bool?,
        readOnly: json['read_only'] as bool?,
        hidden: json['hidden'] as bool?,
        url: json['url'] as String?,
        meetingStatus: json['meeting_status'] as String?,
        meetingUrl: json['meeting_url'] as String?,
        meetingIcon: json['meeting_icon'] as String?,
        meetingSolution: json['meeting_solution'] as String?,
        color: json['color'] as String?,
        calendarColor: json['calendar_color'] as String?,
        taskId: json['task_id'] as String?,
        fingerprints: json['fingerprints'] as dynamic,
        globalUpdatedAt: json['global_updated_at'] as String?,
        globalCreatedAt: json['global_created_at'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        deletedAt: json['deleted_at'] as String?,
        createdBy: json['created_by'] as String?,
        untilDatetime: json['until_datetime'] as String?,
        recurrenceExceptionDelete: json['recurrence_exception_delete'] as bool?,
        recurrenceSyncRetry: json['recurrence_sync_retry'] as int?,
        remoteUpdatedAt: json['remote_updated_at'] as String?,
        status: json['status'] as String?,
        oldId: json['_old_id'] as String?,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'origin_id': originId,
        'custom_origin_id': customOriginId,
        'connector_id': connectorId,
        'account_id': accountId,
        'akiflow_account_id': akiflowAccountId,
        'origin_account_id': originAccountId,
        'recurring_id': recurringId,
        'origin_recurring_id': originRecurringId,
        'calendar_id': calendarId,
        'origin_calendar_id': originCalendarId,
        'creator_id': creatorId,
        'organizer_id': organizerId,
        'original_start_time': originalStartTime,
        'original_start_date': originalStartDate,
        'start_time': startTime,
        'end_time': endTime,
        'start_datetime_tz': startDatetimeTz,
        'start_date': startDate,
        'end_date': endDate,
        'end_datetime_tz': endDatetimeTz,
        'origin_updated_at': originUpdatedAt,
        'etag': etag,
        'title': title,
        'description': description,
        //'content': content,
        //'attendees': (attendees == null || attendees!.isEmpty) ? null : List<dynamic>.from(attendees!.map((x) => x)),
        'recurrence':
            (recurrence == null || recurrence!.isEmpty) ? null : List<dynamic>.from(recurrence!.map((x) => x)),
        'recurrence_exception': recurrenceException,
        'declined': declined,
        'read_only': readOnly,
        'hidden': hidden,
        'url': url,
        'meeting_status': meetingStatus,
        'meeting_url': meetingUrl,
        'meeting_icon': meetingIcon,
        'meeting_solution': meetingSolution,
        'color': color,
        'calendar_color': calendarColor,
        'task_id': taskId,
        'fingerprints': fingerprints,
        'global_updated_at': globalUpdatedAt,
        'global_created_at': globalCreatedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'created_by': createdBy,
        'until_datetime': untilDatetime,
        'recurrence_exception_delete': recurrenceExceptionDelete,
        'recurrence_sync_retry': recurrenceSyncRetry,
        'remote_updated_at': remoteUpdatedAt,
        'status': status,
        '_old_id': oldId,
      };

  Event copyWith({
    String? id,
    Nullable<String?>? originId,
    Nullable<String?>? customOriginId,
    String? connectorId,
    String? accountId,
    String? akiflowAccountId,
    String? originAccountId,
    String? recurringId,
    String? originRecurringId,
    String? calendarId,
    String? originCalendarId,
    String? creatorId,
    String? organizerId,
    Nullable<String?>? originalStartTime,
    Nullable<String?>? originalStartDate,
    Nullable<String?>? startTime,
    Nullable<String?>? endTime,
    String? startDatetimeTz,
    Nullable<String?>? startDate,
    Nullable<String?>? endDate,
    String? endDatetimeTz,
    Nullable<String?>? originUpdatedAt,
    String? etag,
    String? title,
    String? description,
    dynamic content,
    List<EventAtendee>? attendees,
    List<String>? recurrence,
    bool? recurrenceException,
    bool? declined,
    bool? readOnly,
    bool? hidden,
    Nullable<String?>? url,
    String? meetingStatus,
    String? meetingUrl,
    String? meetingIcon,
    Nullable<String?>? meetingSolution,
    String? color,
    String? calendarColor,
    String? taskId,
    dynamic fingerprints,
    String? globalUpdatedAt,
    String? globalCreatedAt,
    String? createdAt,
    Nullable<String?>? updatedAt,
    Nullable<String?>? remoteUpdatedAt,
    String? deletedAt,
    String? createdBy,
    Nullable<String?>? untilDatetime,
    bool? recurrenceExceptionDelete,
    int? recurrenceSyncRetry,
    String? status,
  }) {
    return Event(
      id: id ?? this.id,
      originId: originId == null ? this.originId : originId.value,
      customOriginId: customOriginId == null ? this.customOriginId : customOriginId.value,
      connectorId: connectorId ?? this.connectorId,
      accountId: accountId ?? this.accountId,
      akiflowAccountId: akiflowAccountId ?? this.akiflowAccountId,
      originAccountId: originAccountId ?? this.originAccountId,
      recurringId: recurringId ?? this.recurringId,
      originRecurringId: originRecurringId ?? this.originRecurringId,
      calendarId: calendarId ?? this.calendarId,
      originCalendarId: originCalendarId ?? this.originCalendarId,
      creatorId: creatorId ?? this.creatorId,
      organizerId: organizerId ?? this.organizerId,
      originalStartTime: originalStartTime == null ? this.originalStartTime : originalStartTime.value,
      originalStartDate: originalStartDate == null ? this.originalStartDate : originalStartDate.value,
      startTime: startTime == null ? this.startTime : startTime.value,
      endTime: endTime == null ? this.endTime : endTime.value,
      startDatetimeTz: startDatetimeTz ?? this.startDatetimeTz,
      startDate: startDate == null ? this.startDate : startDate.value,
      endDate: endDate == null ? this.endDate : endDate.value,
      endDatetimeTz: endDatetimeTz ?? this.endDatetimeTz,
      originUpdatedAt: originUpdatedAt == null ? this.originUpdatedAt : originUpdatedAt.value,
      etag: etag ?? this.etag,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      attendees: attendees ?? this.attendees,
      recurrence: recurrence ?? this.recurrence,
      recurrenceException: recurrenceException ?? this.recurrenceException,
      declined: declined ?? this.declined,
      readOnly: readOnly ?? this.readOnly,
      hidden: hidden ?? this.hidden,
      url: url == null ? this.url : url.value,
      meetingStatus: meetingStatus ?? this.meetingStatus,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      meetingIcon: meetingIcon ?? this.meetingIcon,
      meetingSolution: meetingSolution == null ? this.meetingSolution : meetingSolution.value,
      color: color ?? this.color,
      calendarColor: calendarColor ?? this.calendarColor,
      taskId: taskId ?? this.taskId,
      fingerprints: fingerprints ?? this.fingerprints,
      globalUpdatedAt: globalUpdatedAt ?? this.globalUpdatedAt,
      globalCreatedAt: globalCreatedAt ?? this.globalCreatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
      remoteUpdatedAt: remoteUpdatedAt == null ? this.remoteUpdatedAt : remoteUpdatedAt.value,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      untilDatetime: untilDatetime == null ? this.untilDatetime : untilDatetime.value,
      recurrenceExceptionDelete: recurrenceExceptionDelete ?? this.recurrenceExceptionDelete,
      recurrenceSyncRetry: recurrenceSyncRetry ?? this.recurrenceSyncRetry,
      status: status ?? this.status,
    );
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
      "original_start_time": originalStartTime,
      "original_start_date": originalStartDate,
      "start_time": startTime,
      "end_time": endTime,
      "start_date": startDate,
      "end_date": endDate,
      "start_datetime_tz": startDatetimeTz,
      "end_datetime_tz": endDatetimeTz,
      "origin_updated_at": originUpdatedAt,
      "title": title,
      "description": description,
      'content': content != null ? jsonEncode(content) : null,
      'attendees': (attendees == null || attendees!.isEmpty)
          ? null
          : jsonEncode(attendees!.map((i) => i.toMap()).toList()).toString(),
      'recurrence': (recurrence == null || recurrence!.isEmpty) ? null : recurrence?.toList().join(';'),
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
      "recurrence_exception_delete": recurrenceExceptionDelete == true ? 1 : 0,
      "recurrence_sync_retry": recurrenceSyncRetry,
      "until_datetime": untilDatetime,
      "updated_at": updatedAt,
      "created_at": createdAt,
      "deleted_at": deletedAt,
      "remote_updated_at": remoteUpdatedAt,
      "status": status
    };
  }

  static Event fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    for (var key in data.keys) {
      switch (key) {
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

    List<String>? recurrenceList = [];
    if (data.containsKey("recurrence") && data["recurrence"] != null) {
      String object = data["recurrence"] as String;
      recurrenceList = [object];
      data.remove("recurrence");
    }

    if (data.containsKey("attendees") && data["attendees"] != null) {
      String object = data["attendees"] as String;
      data["attendees"] = jsonDecode(object);
    }

    if (data.containsKey("content") && data["content"] != null) {
      data["content"] = jsonDecode(data["content"] as String);
    }

    Event event = Event.fromMap(data);

    event = event.copyWith(recurrence: recurrenceList);

    return event;
  }

  @override
  List<Object?> get props {
    return [
      id,
      originId,
      customOriginId,
      connectorId,
      accountId,
      akiflowAccountId,
      originAccountId,
      recurringId,
      originRecurringId,
      calendarId,
      originCalendarId,
      creatorId,
      organizerId,
      originalStartTime,
      originalStartDate,
      startTime,
      endTime,
      startDatetimeTz,
      startDate,
      endDate,
      endDatetimeTz,
      originUpdatedAt,
      etag,
      title,
      description,
      content,
      attendees,
      recurrence,
      recurrenceException,
      declined,
      readOnly,
      hidden,
      url,
      meetingStatus,
      meetingUrl,
      meetingIcon,
      meetingSolution,
      color,
      calendarColor,
      taskId,
      fingerprints,
      globalUpdatedAt,
      globalCreatedAt,
      createdAt,
      updatedAt,
      deletedAt,
      createdBy,
      untilDatetime,
      recurrenceExceptionDelete,
      recurrenceSyncRetry,
      remoteUpdatedAt,
      status,
      oldId,
    ];
  }
}
