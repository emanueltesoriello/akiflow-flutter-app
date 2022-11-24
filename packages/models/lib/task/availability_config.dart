// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';

import '../base.dart';

enum AvailabililtyConfigSlotsType { manual, recurrent }

class AvailabilityConfig extends Equatable implements Base {
  final String id;
  final int? duration;
  final String reserve_calendar_id;
  final List<dynamic>? freebusy_calendar_ids;
  final int? slots_type;
  final String? title;
  final String? description;
  final List<dynamic>? slots_configuration;
  final Map<String, dynamic>? reserved_slots;
  final String? min_start_time;
  final String? max_end_time;
  final String? timezone;
  final String? reserved_at;
  final bool? multiuse;
  final String? url_path;
  final Map<String, dynamic>? conference_settings;
  final Map<String, dynamic>? notification_settings;
  final Map<String, dynamic>? settings;
  final String global_created_at;
  final String global_updated_at;
  final String? created_at;
  final String? updated_at;
  final String? deleted_at;
  final bool? url_path_changed;

  const AvailabilityConfig(
      {required this.id,
      required this.duration,
      required this.reserve_calendar_id,
      required this.freebusy_calendar_ids,
      required this.slots_type,
      required this.title,
      required this.description,
      required this.slots_configuration,
      required this.reserved_slots,
      required this.min_start_time,
      required this.max_end_time,
      required this.timezone,
      required this.reserved_at,
      required this.multiuse,
      required this.url_path,
      required this.conference_settings,
      required this.notification_settings,
      required this.settings,
      required this.global_created_at,
      required this.global_updated_at,
      this.created_at,
      this.updated_at,
      this.deleted_at,
      this.url_path_changed});

  @override
  List<Object?> get props => [
        id,
        duration,
        reserve_calendar_id,
        freebusy_calendar_ids,
        slots_type,
        title,
        description,
        slots_configuration,
        reserved_slots,
        min_start_time,
        max_end_time,
        timezone,
        reserved_at,
        multiuse,
        url_path,
        conference_settings,
        notification_settings,
        settings,
        global_created_at,
        global_updated_at,
        created_at,
        updated_at,
        deleted_at,
        url_path_changed
      ];

  AvailabilityConfig copyWith({
    String? id,
    int? duration,
    String? reserve_calendar_id,
    List<dynamic>? freebusy_calendar_ids,
    int? slots_type,
    String? title,
    String? description,
    List<dynamic>? slots_configuration,
    Map<String, dynamic>? reserved_slots,
    String? min_start_time,
    String? max_end_time,
    String? timezone,
    String? reserved_at,
    bool? multiuse,
    String? url_path,
    Map<String, dynamic>? conference_settings,
    Map<String, dynamic>? notification_settings,
    Map<String, dynamic>? settings,
    String? global_created_at,
    String? global_updated_at,
    String? created_at,
    String? updated_at,
    String? deleted_at,
    bool? url_path_changed,
  }) {
    return AvailabilityConfig(
      id: id ?? this.id,
      duration: duration ?? this.duration,
      reserve_calendar_id: reserve_calendar_id ?? this.reserve_calendar_id,
      freebusy_calendar_ids: freebusy_calendar_ids ?? this.freebusy_calendar_ids,
      slots_type: slots_type ?? this.slots_type,
      title: title ?? this.title,
      description: description ?? this.description,
      slots_configuration: slots_configuration ?? this.slots_configuration,
      reserved_slots: reserved_slots ?? this.reserved_slots,
      min_start_time: min_start_time ?? this.min_start_time,
      max_end_time: max_end_time ?? this.max_end_time,
      timezone: timezone ?? this.timezone,
      reserved_at: reserved_at ?? this.reserved_at,
      multiuse: multiuse ?? this.multiuse,
      url_path: url_path ?? this.url_path,
      conference_settings: conference_settings ?? this.conference_settings,
      notification_settings: notification_settings ?? this.notification_settings,
      settings: settings ?? this.settings,
      global_created_at: global_created_at ?? this.global_created_at,
      global_updated_at: global_updated_at ?? this.global_updated_at,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      deleted_at: deleted_at ?? this.deleted_at,
      url_path_changed: url_path_changed ?? this.url_path_changed,
    );
  }

  factory AvailabilityConfig.fromMap(Map<String, dynamic> map) {
    return AvailabilityConfig(
        id: map['id'],
        duration: map['duration'],
        reserve_calendar_id: map['reserve_calendar_id'],
        freebusy_calendar_ids: map['freebusy_calendar_ids'],
        slots_type: map['slots_type'],
        title: map['title'],
        description: map['description'],
        slots_configuration: map['slots_configuration'],
        reserved_slots: map['reserved_slots'],
        min_start_time: map['min_start_time'],
        max_end_time: map['max_end_time'],
        timezone: map['timezone'],
        reserved_at: map['reserved_at'],
        multiuse: map['multiuse'],
        url_path: map['url_path'],
        conference_settings: map['conference_settings'],
        notification_settings: map['notification_settings'],
        settings: map['settings'],
        global_created_at: map['global_created_at'],
        global_updated_at: map['global_updated_at'],
        created_at: map['created_at'],
        updated_at: map['updated_at'],
        deleted_at: map['deleted_at'],
        url_path_changed: map['url_path_changed']);
  }

  AvailabililtyConfigSlotsType get type {
    switch (slots_type) {
      case 0:
        return AvailabililtyConfigSlotsType.manual;
      case 1:
        return AvailabililtyConfigSlotsType.recurrent;
    }
    return AvailabililtyConfigSlotsType.manual;
  }

  static AvailabilityConfig fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);
    return AvailabilityConfig.fromMap(data);
  }

  String get durationString {
    if (duration != null && duration != 0) {
      int seconds = duration!;

      double hours = seconds / 3600;
      double minutes = (hours - hours.floor()) * 60;

      if (minutes.floor() == 0) {
        return '${hours.floor()}h';
      } else if (hours.floor() == 0) {
        return '${minutes.floor()}m';
      } else {
        return '${hours.floor()}h ${minutes.floor()}m';
      }
    }
    return '';
  }

  

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'duration': duration,
      'reserve_calendar_id': reserve_calendar_id,
      'freebusy_calendar_ids': freebusy_calendar_ids,
      'slots_type': slots_type,
      'title': title,
      'description': description,
      'slots_configuration': slots_configuration,
      'reserved_slots': reserved_slots,
      'min_start_time': min_start_time,
      'max_end_time': max_end_time,
      'timezone': timezone,
      'reserved_at': reserved_at,
      'multiuse': multiuse,
      'url_path': url_path,
      'conference_settings': conference_settings,
      'notification_settings': notification_settings,
      'settings': settings,
      'global_created_at': global_created_at,
      'global_updated_at': global_updated_at,
      'created_at': created_at,
      'updated_at': updated_at,
      'deleted_at': deleted_at,
      'url_path_changed': url_path_changed,
    };
  }

  @override
  Map<String, dynamic> toSql() {
    return {
      'id': id,
      'duration': duration,
      'reserve_calendar_id': reserve_calendar_id,
      'slots_type':slots_type,
      'title': title,
      'description': description,
      'min_start_time': min_start_time,
      'max_end_time': max_end_time,
      'timezone': timezone,
      'reserved_at': reserved_at,
      'url_path': url_path,
      'global_created_at': global_created_at,
      'global_updated_at': global_updated_at,
      'created_at': created_at,
      'updated_at': updated_at,
      'deleted_at': deleted_at,
    };
  }
}
