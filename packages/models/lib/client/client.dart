import 'package:equatable/equatable.dart';
import 'package:models/base.dart';

class Client extends Equatable implements Base {
  const Client(
      {required this.id,
      required this.userId,
      this.os,
      this.osVersion,
      this.release,
      this.timezoneOffset,
      this.timezoneName,
      this.lastTasksSyncStartedAt,
      this.unsafeLastTasksSyncEndedAt,
      this.lastSettingsSyncStartedAt,
      this.unsafeLastSettingsSyncEndedAt,
      this.lastAccountsSyncStartedAt,
      this.unsafeLastAccountsSyncEndedAt,
      this.lastLabelsSyncStartedAt,
      this.unsafeLastLabelsSyncEndedAt,
      this.notificationsToken,
      this.deviceId,
      this.recurringBackgroundSyncCounter,
      this.recurringNotificationsSyncCounter});

  final String id;
  final int userId;
  final String? os;
  final String? osVersion;
  final String? release;
  final String? timezoneOffset;
  final String? timezoneName;
  final String? lastTasksSyncStartedAt;
  final String? unsafeLastTasksSyncEndedAt;
  final String? lastSettingsSyncStartedAt;
  final String? unsafeLastSettingsSyncEndedAt;
  final String? lastAccountsSyncStartedAt;
  final String? unsafeLastAccountsSyncEndedAt;
  final String? lastLabelsSyncStartedAt;
  final String? unsafeLastLabelsSyncEndedAt;
  final String? notificationsToken;
  final String? deviceId;
  final int? recurringBackgroundSyncCounter;
  final int? recurringNotificationsSyncCounter;

  factory Client.fromMap(Map<String, dynamic> json) => Client(
        id: json['id'] as String,
        userId: json['user_id'] as int,
        lastAccountsSyncStartedAt: json['last_accounts_sync_started_at'] as String?,
        lastLabelsSyncStartedAt: json['last_labels_sync_started_at'] as String?,
        lastSettingsSyncStartedAt: json['last_settings_sync_started_at'] as String?,
        lastTasksSyncStartedAt: json['last_tasks_sync_started_at'] as String?,
        os: json['os'] as String?,
        osVersion: json['os_version'] as String?,
        release: json['release'] as String?,
        timezoneName: json['timezone_name'] as String?,
        timezoneOffset: json['timezone_offset'] as String?,
        unsafeLastAccountsSyncEndedAt: json['unsafe_last_accounts_sync_ended_at'] as String?,
        unsafeLastLabelsSyncEndedAt: json['unsafe_last_labels_sync_ended_at'] as String?,
        unsafeLastSettingsSyncEndedAt: json['unsafe_last_settings_sync_ended_at'] as String?,
        unsafeLastTasksSyncEndedAt: json['unsafe_last_tasks_sync_ended_at'] as String?,
        notificationsToken: json['notifications_token'] as String?,
        deviceId: json['device_id'] as String?,
        recurringBackgroundSyncCounter: json['recurring_background_sync_counter'] as int?,
        recurringNotificationsSyncCounter: json['recurring_notifications_sync_counter'] as int?,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'last_accounts_sync_started_at': lastAccountsSyncStartedAt,
        'last_labels_sync_started_at': lastLabelsSyncStartedAt,
        'last_settings_sync_started_at': lastSettingsSyncStartedAt,
        'last_tasks_sync_started_at': lastTasksSyncStartedAt,
        'os': os,
        'os_version': osVersion,
        'release': release,
        'timezone_name': timezoneName,
        'timezone_offset': timezoneOffset,
        'unsafe_last_accounts_sync_ended_at': unsafeLastAccountsSyncEndedAt,
        'unsafe_last_labels_sync_ended_at': unsafeLastLabelsSyncEndedAt,
        'unsafe_last_settings_sync_ended_at': unsafeLastSettingsSyncEndedAt,
        'unsafe_last_tasks_sync_ended_at': unsafeLastTasksSyncEndedAt,
        'notifications_token': notificationsToken,
        'device_id': deviceId,
        "recurring_background_sync_counter": recurringBackgroundSyncCounter,
        "recurringNotificationsSyncCounter": recurringNotificationsSyncCounter
      };

  Client copyWith({
    String? id,
    int? userId,
    String? os,
    String? osVersion,
    String? release,
    String? timezoneOffset,
    String? timezoneName,
    String? lastTasksSyncStartedAt,
    String? unsafeLastTasksSyncEndedAt,
    String? lastSettingsSyncStartedAt,
    String? unsafeLastSettingsSyncEndedAt,
    String? lastAccountsSyncStartedAt,
    String? unsafeLastAccountsSyncEndedAt,
    String? lastLabelsSyncStartedAt,
    String? unsafeLastLabelsSyncEndedAt,
    String? notificationsToken,
    String? deviceId,
    int? recurringBackgroundSyncCounter,
    int? recurringNotificationsSyncCounter,
  }) {
    return Client(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lastAccountsSyncStartedAt: lastAccountsSyncStartedAt ?? this.lastAccountsSyncStartedAt,
      lastLabelsSyncStartedAt: lastLabelsSyncStartedAt ?? this.lastLabelsSyncStartedAt,
      lastSettingsSyncStartedAt: lastSettingsSyncStartedAt ?? this.lastSettingsSyncStartedAt,
      lastTasksSyncStartedAt: lastTasksSyncStartedAt ?? this.lastTasksSyncStartedAt,
      os: os ?? this.os,
      osVersion: osVersion ?? this.osVersion,
      release: release ?? this.release,
      timezoneName: timezoneName ?? this.timezoneName,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
      unsafeLastAccountsSyncEndedAt: unsafeLastAccountsSyncEndedAt ?? this.unsafeLastAccountsSyncEndedAt,
      unsafeLastLabelsSyncEndedAt: unsafeLastLabelsSyncEndedAt ?? this.unsafeLastLabelsSyncEndedAt,
      unsafeLastSettingsSyncEndedAt: unsafeLastSettingsSyncEndedAt ?? this.unsafeLastSettingsSyncEndedAt,
      unsafeLastTasksSyncEndedAt: unsafeLastTasksSyncEndedAt ?? this.unsafeLastTasksSyncEndedAt,
      notificationsToken: notificationsToken ?? this.notificationsToken,
      deviceId: deviceId ?? this.deviceId,
      recurringBackgroundSyncCounter: recurringBackgroundSyncCounter ?? this.recurringBackgroundSyncCounter,
      recurringNotificationsSyncCounter: recurringNotificationsSyncCounter ?? this.recurringNotificationsSyncCounter,
    );
  }

  @override
  Map<String, Object?> toSql() {
    return toMap();
  }

  static Client fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);
    return Client.fromMap(data);
  }

  @override
  List<Object?> get props {
    return [
      id,
      userId,
      os,
      osVersion,
      release,
      timezoneOffset,
      timezoneName,
      lastTasksSyncStartedAt,
      unsafeLastTasksSyncEndedAt,
      lastSettingsSyncStartedAt,
      unsafeLastSettingsSyncEndedAt,
      lastAccountsSyncStartedAt,
      unsafeLastAccountsSyncEndedAt,
      lastLabelsSyncStartedAt,
      unsafeLastLabelsSyncEndedAt,
      notificationsToken,
      deviceId,
      recurringNotificationsSyncCounter,
      recurringBackgroundSyncCounter
    ];
  }
}
