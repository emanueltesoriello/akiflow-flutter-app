import 'package:equatable/equatable.dart';
import 'package:models/base.dart';
import 'package:models/nullable.dart';

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
      this.recurringNotificationsSyncCounter,
      this.notificationsRevoked});

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
  final bool? notificationsRevoked;

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
      notificationsRevoked: json['notifications_revoked '] as bool?);

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
        "recurringNotificationsSyncCounter": recurringNotificationsSyncCounter,
        "notifications_revoked": notificationsRevoked,
      };

  Client copyWith(
      {String? id,
      int? userId,
      Nullable<String>? os,
      Nullable<String>? osVersion,
      Nullable<String>? release,
      Nullable<String>? timezoneOffset,
      Nullable<String>? timezoneName,
      Nullable<String>? lastTasksSyncStartedAt,
      Nullable<String>? unsafeLastTasksSyncEndedAt,
      Nullable<String>? lastSettingsSyncStartedAt,
      Nullable<String>? unsafeLastSettingsSyncEndedAt,
      Nullable<String>? lastAccountsSyncStartedAt,
      Nullable<String>? unsafeLastAccountsSyncEndedAt,
      Nullable<String>? lastLabelsSyncStartedAt,
      Nullable<String>? unsafeLastLabelsSyncEndedAt,
      Nullable<String>? notificationsToken,
      Nullable<String>? deviceId,
      Nullable<int>? recurringBackgroundSyncCounter,
      Nullable<int>? recurringNotificationsSyncCounter,
      Nullable<bool>? notificationsRevoked}) {
    return Client(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        lastAccountsSyncStartedAt:
            lastAccountsSyncStartedAt == null ? this.lastAccountsSyncStartedAt : lastAccountsSyncStartedAt.value,
        lastLabelsSyncStartedAt:
            lastLabelsSyncStartedAt == null ? this.lastLabelsSyncStartedAt : lastLabelsSyncStartedAt.value,
        lastSettingsSyncStartedAt:
            lastSettingsSyncStartedAt == null ? this.lastSettingsSyncStartedAt : lastSettingsSyncStartedAt.value,
        lastTasksSyncStartedAt:
            lastTasksSyncStartedAt == null ? this.lastTasksSyncStartedAt : lastTasksSyncStartedAt.value,
        os: os == null ? this.os : os.value,
        osVersion: osVersion == null ? this.osVersion : osVersion.value,
        release: release == null ? this.release : release.value,
        timezoneName: timezoneName == null ? this.timezoneName : timezoneName.value,
        timezoneOffset: timezoneOffset == null ? this.timezoneOffset : timezoneOffset.value,
        unsafeLastAccountsSyncEndedAt: unsafeLastAccountsSyncEndedAt == null
            ? this.unsafeLastAccountsSyncEndedAt
            : unsafeLastAccountsSyncEndedAt.value,
        unsafeLastLabelsSyncEndedAt:
            unsafeLastLabelsSyncEndedAt == null ? this.unsafeLastLabelsSyncEndedAt : unsafeLastLabelsSyncEndedAt.value,
        unsafeLastSettingsSyncEndedAt: unsafeLastSettingsSyncEndedAt == null
            ? this.unsafeLastSettingsSyncEndedAt
            : unsafeLastSettingsSyncEndedAt.value,
        unsafeLastTasksSyncEndedAt:
            unsafeLastTasksSyncEndedAt == null ? this.unsafeLastTasksSyncEndedAt : unsafeLastTasksSyncEndedAt.value,
        notificationsToken: notificationsToken == null ? this.notificationsToken : notificationsToken.value,
        deviceId: deviceId == null ? this.deviceId : deviceId.value,
        recurringBackgroundSyncCounter: recurringBackgroundSyncCounter == null
            ? this.recurringBackgroundSyncCounter
            : recurringBackgroundSyncCounter.value,
        recurringNotificationsSyncCounter: recurringNotificationsSyncCounter == null
            ? this.recurringNotificationsSyncCounter
            : recurringNotificationsSyncCounter.value,
        notificationsRevoked: notificationsRevoked == null ? this.notificationsRevoked : notificationsRevoked.value);
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
      recurringBackgroundSyncCounter,
      notificationsRevoked
    ];
  }
}
