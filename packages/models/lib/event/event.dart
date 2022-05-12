import 'package:equatable/equatable.dart';
import 'package:models/base.dart';
import 'package:models/nullable.dart';

class Event extends Equatable implements Base {
  const Event({
    this.id,
    this.userId,
    this.originId,
    this.customOriginId,
    this.connectorId,
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
  });

  final String? id;
  final int? userId;
  final String? originId;
  final String? customOriginId;
  final String? connectorId;
  final String? akiflowAccountId;
  final String? originAccountId;
  final dynamic recurringId;
  final dynamic originRecurringId;
  final String? calendarId;
  final String? originCalendarId;
  final String? creatorId;
  final String? organizerId;
  final dynamic originalStartTime;
  final dynamic originalStartDate;
  final dynamic startTime;
  final dynamic endTime;
  final dynamic startDatetimeTz;
  final String? startDate;
  final String? endDate;
  final dynamic endDatetimeTz;
  final String? originUpdatedAt;
  final String? etag;
  final String? title;
  final String? description;
  final dynamic content;
  final List<dynamic>? attendees;
  final List<dynamic>? recurrence;
  final bool? recurrenceException;
  final bool? declined;
  final bool? readOnly;
  final bool? hidden;
  final String? url;
  final dynamic meetingStatus;
  final dynamic meetingUrl;
  final dynamic meetingIcon;
  final dynamic meetingSolution;
  final dynamic color;
  final String? calendarColor;
  final dynamic taskId;
  final dynamic fingerprints;
  final String? globalUpdatedAt;
  final String? globalCreatedAt;
  final String? createdAt;
  final String? updatedAt;
  final dynamic deletedAt;
  final String? createdBy;
  final dynamic untilDatetime;
  final bool? recurrenceExceptionDelete;
  final int? recurrenceSyncRetry;
  final String? remoteUpdatedAt;

  factory Event.fromMap(Map<String, dynamic> json) => Event(
        id: json['id'] as String?,
        userId: json['user_id'] as int?,
        originId: json['origin_id'] as String?,
        customOriginId: json['custom_origin_id'] as String?,
        connectorId: json['connector_id'] as String?,
        akiflowAccountId: json['akiflow_account_id'] as String?,
        originAccountId: json['origin_account_id'] as String?,
        recurringId: json['recurring_id'] as dynamic,
        originRecurringId: json['origin_recurring_id'] as dynamic,
        calendarId: json['calendar_id'] as String?,
        originCalendarId: json['origin_calendar_id'] as String?,
        creatorId: json['creator_id'] as String?,
        organizerId: json['organizer_id'] as String?,
        originalStartTime: json['original_start_time'] as dynamic,
        originalStartDate: json['original_start_date'] as dynamic,
        startTime: json['start_time'] as dynamic,
        endTime: json['end_time'] as dynamic,
        startDatetimeTz: json['start_datetime_tz'] as dynamic,
        startDate: json['start_date'] as String?,
        endDate: json['end_date'] as String?,
        endDatetimeTz: json['end_datetime_tz'] as dynamic,
        originUpdatedAt: json['origin_updated_at'] as String?,
        etag: json['etag'] as String?,
        title: json['title'] as String?,
        description: json['description'] as String?,
        content: json['content'] as dynamic,
        attendees: json['attendees'] as List<dynamic>?,
        recurrence: json['recurrence'] as List<dynamic>?,
        recurrenceException: json['recurrence_exception'] as bool?,
        declined: json['declined'] as bool?,
        readOnly: json['read_only'] as bool?,
        hidden: json['hidden'] as bool?,
        url: json['url'] as String?,
        meetingStatus: json['meeting_status'] as dynamic,
        meetingUrl: json['meeting_url'] as dynamic,
        meetingIcon: json['meeting_icon'] as dynamic,
        meetingSolution: json['meeting_solution'] as dynamic,
        color: json['color'] as dynamic,
        calendarColor: json['calendar_color'] as String?,
        taskId: json['task_id'] as dynamic,
        fingerprints: json['fingerprints'] as dynamic,
        globalUpdatedAt: json['global_updated_at'] as String?,
        globalCreatedAt: json['global_created_at'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        deletedAt: json['deleted_at'] as dynamic,
        createdBy: json['created_by'] as String?,
        untilDatetime: json['until_datetime'] as dynamic,
        recurrenceExceptionDelete: json['recurrence_exception_delete'] as bool?,
        recurrenceSyncRetry: json['recurrence_sync_retry'] as int?,
        remoteUpdatedAt: json['remote_updated_at'] as String?,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'origin_id': originId,
        'custom_origin_id': customOriginId,
        'connector_id': connectorId,
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
        'content': content,
        'attendees': attendees,
        'recurrence': recurrence,
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
      };

  Event copyWith({
    String? id,
    int? userId,
    String? originId,
    String? customOriginId,
    String? connectorId,
    String? akiflowAccountId,
    String? originAccountId,
    dynamic recurringId,
    dynamic originRecurringId,
    String? calendarId,
    String? originCalendarId,
    String? creatorId,
    String? organizerId,
    dynamic originalStartTime,
    dynamic originalStartDate,
    dynamic startTime,
    dynamic endTime,
    dynamic startDatetimeTz,
    String? startDate,
    String? endDate,
    dynamic endDatetimeTz,
    String? originUpdatedAt,
    String? etag,
    String? title,
    String? description,
    dynamic content,
    List<dynamic>? attendees,
    List<dynamic>? recurrence,
    bool? recurrenceException,
    bool? declined,
    bool? readOnly,
    bool? hidden,
    String? url,
    dynamic meetingStatus,
    dynamic meetingUrl,
    dynamic meetingIcon,
    dynamic meetingSolution,
    dynamic color,
    String? calendarColor,
    dynamic taskId,
    dynamic fingerprints,
    String? globalUpdatedAt,
    String? globalCreatedAt,
    String? createdAt,
    Nullable<String?>? updatedAt,
    Nullable<String?>? remoteUpdatedAt,
    dynamic deletedAt,
    String? createdBy,
    dynamic untilDatetime,
    bool? recurrenceExceptionDelete,
    int? recurrenceSyncRetry,
  }) {
    return Event(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      originId: originId ?? this.originId,
      customOriginId: customOriginId ?? this.customOriginId,
      connectorId: connectorId ?? this.connectorId,
      akiflowAccountId: akiflowAccountId ?? this.akiflowAccountId,
      originAccountId: originAccountId ?? this.originAccountId,
      recurringId: recurringId ?? this.recurringId,
      originRecurringId: originRecurringId ?? this.originRecurringId,
      calendarId: calendarId ?? this.calendarId,
      originCalendarId: originCalendarId ?? this.originCalendarId,
      creatorId: creatorId ?? this.creatorId,
      organizerId: organizerId ?? this.organizerId,
      originalStartTime: originalStartTime ?? this.originalStartTime,
      originalStartDate: originalStartDate ?? this.originalStartDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startDatetimeTz: startDatetimeTz ?? this.startDatetimeTz,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      endDatetimeTz: endDatetimeTz ?? this.endDatetimeTz,
      originUpdatedAt: originUpdatedAt ?? this.originUpdatedAt,
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
      url: url ?? this.url,
      meetingStatus: meetingStatus ?? this.meetingStatus,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      meetingIcon: meetingIcon ?? this.meetingIcon,
      meetingSolution: meetingSolution ?? this.meetingSolution,
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
      untilDatetime: untilDatetime ?? this.untilDatetime,
      recurrenceExceptionDelete: recurrenceExceptionDelete ?? this.recurrenceExceptionDelete,
      recurrenceSyncRetry: recurrenceSyncRetry ?? this.recurrenceSyncRetry,
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
      "origin_updated_at": originUpdatedAt,
      "title": title,
      "description": description,
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
      "updated_at": updatedAt,
      "created_at": createdAt,
      "deleted_at": deletedAt,
      "remote_updated_at": remoteUpdatedAt,
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
        default:
      }
    }

    return Event.fromMap(data);
  }

  @override
  List<Object?> get props {
    return [
      id,
      userId,
      originId,
      customOriginId,
      connectorId,
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
    ];
  }
}
