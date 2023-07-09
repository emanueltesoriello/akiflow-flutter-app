import 'package:equatable/equatable.dart';
import 'package:models/base.dart';

enum NotificationType { Event, Tasks, Other }

class ScheduledNotification extends Equatable implements Base {
  const ScheduledNotification(
      {required this.notificationId,
      required this.plannedDate,
      required this.type,
      required this.payload,
      required this.notificationBody,
      required this.notificationTitle});

  final int notificationId;
  final String plannedDate;
  final NotificationType type;
  final String payload;
  final String notificationTitle;
  final String notificationBody;

  factory ScheduledNotification.fromMap(Map<String, dynamic> json) {
    NotificationType type;
    String payload;
    String notificationBody;
    String notificationTitle;

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
    return ScheduledNotification(
        notificationId: json['notification_id'] as int,
        plannedDate: json['planned_date'] as String,
        type: type,
        payload: payload,
        notificationBody: notificationBody,
        notificationTitle: notificationTitle);
  }

  @override
  Map<String, dynamic> toMap() => {
        'notification_id': notificationId,
        'planned_date': plannedDate,
        'type': type.index,
        'payload': payload,
        'notification_title': notificationTitle,
        'notification_body': notificationBody
      };

  ScheduledNotification copyWith(
      {int? notificationId,
      String? plannedDate,
      NotificationType? type,
      String? payload,
      String? notificationBody,
      String? notificationTitle}) {
    return ScheduledNotification(
        notificationId: notificationId ?? this.notificationId,
        plannedDate: plannedDate ?? this.plannedDate,
        type: type ?? this.type,
        payload: payload ?? this.payload,
        notificationBody: notificationBody ?? this.notificationBody,
        notificationTitle: notificationBody ?? this.notificationBody);
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
    ];
  }
}
