import 'package:equatable/equatable.dart';
import 'package:models/base.dart';

enum NotificationType { Event, Tasks, Other }

class ScheduledNotification extends Equatable implements Base {
  const ScheduledNotification(
      {required this.notificationId,
      required this.plannedDate,
      required this.type,
      required this.payload,
      this.fullEventId,
      required this.notificationBody,
      required this.minutesBeforeToStart,
      required this.notificationTitle});

  final int notificationId;
  final String plannedDate;
  final NotificationType type;
  final String payload;
  final String notificationTitle;
  final String notificationBody;
  final int minutesBeforeToStart;
  final String? fullEventId;

  factory ScheduledNotification.fromMap(Map<String, dynamic> json) {
    NotificationType type;
    String payload;
    String notificationBody;
    String notificationTitle;
    String fullEventId;
    int minutesBeforeToStart;
    try {
      type = NotificationType.values[json['type'] as int];
    } catch (_) {
      type = NotificationType.Other;
    }
    try {
      payload = json['payload'] as String;
    } catch (_) {
      payload = "";
    }
    try {
      notificationBody = json['notification_body'] as String;
    } catch (_) {
      notificationBody = "";
    }
    try {
      notificationTitle = json['notification_title'] as String;
    } catch (_) {
      notificationTitle = "";
    }
    try {
      fullEventId = json['full_event_id'] as String;
    } catch (_) {
      fullEventId = "";
    }
    try {
      minutesBeforeToStart = json['minutes_before_to_start'] as int;
    } catch (_) {
      minutesBeforeToStart = 5;
    }
    return ScheduledNotification(
        notificationId: json['notification_id'] as int,
        plannedDate: json['planned_date'] as String,
        type: type,
        payload: payload,
        notificationBody: notificationBody,
        notificationTitle: notificationTitle,
        fullEventId: fullEventId,
        minutesBeforeToStart: minutesBeforeToStart);
  }

  @override
  Map<String, dynamic> toMap() => {
        'notification_id': notificationId,
        'planned_date': plannedDate,
        'type': type.index,
        'payload': payload,
        'notification_title': notificationTitle,
        'notification_body': notificationBody,
        'full_event_id': fullEventId,
        'minutes_before_to_start': minutesBeforeToStart
      };

  ScheduledNotification copyWith({
    int? notificationId,
    String? plannedDate,
    NotificationType? type,
    String? payload,
    String? notificationBody,
    String? notificationTitle,
    String? fullEventId,
    int? minutesBeforeToStart,
  }) {
    return ScheduledNotification(
        notificationId: notificationId ?? this.notificationId,
        plannedDate: plannedDate ?? this.plannedDate,
        type: type ?? this.type,
        payload: payload ?? this.payload,
        notificationBody: notificationBody ?? this.notificationBody,
        notificationTitle: notificationBody ?? this.notificationBody,
        fullEventId: fullEventId ?? this.fullEventId,
        minutesBeforeToStart: minutesBeforeToStart ?? this.minutesBeforeToStart);
  }

  @override
  Map<String, Object?> toSql() {
    return toMap();
  }

  static ScheduledNotification fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);
    return ScheduledNotification.fromMap(data);
  }

  @override
  List<Object?> get props {
    return [
      notificationId,
      plannedDate,
      type,
      payload,
      notificationBody,
      notificationTitle,
      fullEventId,
      minutesBeforeToStart,
    ];
  }
}
