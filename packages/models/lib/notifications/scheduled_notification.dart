import 'package:equatable/equatable.dart';
import 'package:models/base.dart';

class ScheduledNotification extends Equatable implements Base {
  const ScheduledNotification({required this.notificationId, required this.plannedDate});

  final int notificationId;
  final String plannedDate;

  factory ScheduledNotification.fromMap(Map<String, dynamic> json) => ScheduledNotification(
      notificationId: json['notification_id'] as int, plannedDate: json['planned_date'] as String);

  @override
  Map<String, dynamic> toMap() => {
        'notification_id': notificationId,
        'planned_date': plannedDate,
      };

  ScheduledNotification copyWith({int? notificationId, String? plannedDate}) {
    return ScheduledNotification(
      notificationId: notificationId ?? this.notificationId,
      plannedDate: plannedDate ?? this.plannedDate,
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
    return [notificationId, plannedDate];
  }
}
