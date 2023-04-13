import 'package:equatable/equatable.dart';
import 'package:models/base.dart';

enum NotificationType { Event, Tasks, Other }

class ScheduledNotification extends Equatable implements Base {
  const ScheduledNotification({required this.notificationId, required this.plannedDate, required this.type});

  final int notificationId;
  final String plannedDate;
  final NotificationType type;

  factory ScheduledNotification.fromMap(Map<String, dynamic> json) {
    NotificationType _type;
    try {
      _type = NotificationType.values[json['type'] as int];
    } catch (_) {
      _type = NotificationType.Other;
    }
    return ScheduledNotification(
        notificationId: json['notification_id'] as int, plannedDate: json['planned_date'] as String, type: _type);
  }

  @override
  Map<String, dynamic> toMap() => {
        'notification_id': notificationId,
        'planned_date': plannedDate,
        'type': type.index,
      };

  ScheduledNotification copyWith({int? notificationId, String? plannedDate, NotificationType? type}) {
    return ScheduledNotification(
      notificationId: notificationId ?? this.notificationId,
      plannedDate: plannedDate ?? this.plannedDate,
      type: type ?? this.type,
    );
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
    return [notificationId, plannedDate, type];
  }
}
