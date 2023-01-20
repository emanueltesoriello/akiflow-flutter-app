import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:models/base.dart';
import 'package:models/nullable.dart';

class Calendar extends Equatable implements Base {
  const Calendar({
    this.id,
    this.originId,
    this.connectorId,
    this.akiflowAccountId,
    this.originAccountId,
    this.etag,
    this.title,
    this.description,
    this.content,
    this.primary,
    this.akiflowPrimary,
    this.readOnly,
    this.url,
    this.color,
    this.icon,
    this.syncStatus,
    this.isAkiflowCalendar,
    this.settings,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.remoteUpdatedAt,
    this.globalUpdatedAt,
    this.globalCreatedAt,
    this.accountId,
    this.timezone,
    this.accountIdentifier,
    this.accountPicture,
  });

  final String? id;
  final dynamic content;
  final String? etag;
  final String? title;
  final String? description;
  final String? originId;
  final String? akiflowAccountId;
  final String? originAccountId;
  final String? accountId;
  final String? connectorId;
  final String? url;
  final String? color;
  final bool? readOnly;
  final String? icon;
  final String? syncStatus;
  final bool? primary;
  final bool? akiflowPrimary;
  final bool? isAkiflowCalendar;
  final String? timezone;
  final dynamic settings;
  final String? remoteUpdatedAt;
  final String? globalUpdatedAt;
  final String? globalCreatedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? accountIdentifier;
  final String? accountPicture;

  factory Calendar.fromMap(Map<String, dynamic> map) => Calendar(
        id: map['id'] as String?,
        content: map['content'] as dynamic,
        etag: map['etag'] as String?,
        title: map['title'] as String?,
        description: map['description'] as String?,
        originId: map['origin_id'] as String?,
        akiflowAccountId: map['akiflow_account_id'] as String?,
        originAccountId: map['origin_account_id'] as String?,
        accountId: map['account_id'] as String?,
        connectorId: map['connector_id'] as String?,
        url: map['url'] as String?,
        color: map['color'] as String?,
        readOnly: map['read_only'] as bool?,
        icon: map['icon'] as String?,
        syncStatus: map['sync_status'] as String?,
        primary: map['primary'] as bool?,
        akiflowPrimary: map['akiflow_primary'] as bool?,
        isAkiflowCalendar: map['is_akiflow_calendar'] as bool?,
        timezone: map['timezone'] as String?,
        settings: map['settings'] as dynamic,
        remoteUpdatedAt: map['remote_updated_at'] as String?,
        globalCreatedAt: map['global_created_at'] as String?,
        globalUpdatedAt: map['global_updated_at'] as String?,
        createdAt: map['created_at'] as String?,
        updatedAt: map['updated_at'] as String?,
        deletedAt: map['deleted_at'] as String?,
        accountIdentifier: map['account_identifier'] as String?,
        accountPicture: map['account_picture'] as String?,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'content': content,
        'etag': etag,
        'title': title,
        'description': description,
        'origin_id': originId,
        'akiflow_account_id': akiflowAccountId,
        'origin_account_id': originAccountId,
        'account_id': accountId,
        'connector_id': connectorId,
        'url': url,
        'color': color,
        'read_only': readOnly,
        'icon': icon,
        'sync_status': syncStatus,
        'primary': primary,
        'akiflow_primary': akiflowPrimary,
        'is_akiflow_calendar': isAkiflowCalendar,
        'timezone': timezone,
        'settings': settings,
        'remote_updated_at': remoteUpdatedAt,
        'global_created_at': globalCreatedAt,
        'global_updated_at': globalUpdatedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'account_identifier': accountIdentifier,
        'account_picture': accountPicture,
      };

  Calendar copyWith({
    final String? id,
    final dynamic content,
    final String? etag,
    final String? title,
    final String? description,
    final String? originId,
    final String? akiflowAccountId,
    final String? originAccountId,
    final String? accountId,
    final String? connectorId,
    final String? url,
    final String? color,
    final bool? readOnly,
    final String? icon,
    final String? syncStatus,
    final bool? primary,
    final bool? akiflowPrimary,
    final bool? isAkiflowCalendar,
    final String? timezone,
    final dynamic settings,
    final Nullable<String?>? remoteUpdatedAt,
    final String? globalUpdatedAt,
    final String? globalCreatedAt,
    final String? createdAt,
    final Nullable<String?>? updatedAt,
    final String? deletedAt,
    final String? accountIdentifier,
    final String? accountPicture,
  }) {
    return Calendar(
        id: id ?? this.id,
        content: content ?? this.content,
        etag: etag ?? this.etag,
        title: title ?? this.title,
        description: description ?? this.description,
        originId: originId ?? this.originId,
        akiflowAccountId: akiflowAccountId ?? this.akiflowAccountId,
        originAccountId: originAccountId ?? this.originAccountId,
        accountId: accountId ?? this.accountId,
        connectorId: connectorId ?? this.connectorId,
        url: url ?? this.url,
        color: color ?? this.color,
        readOnly: readOnly ?? this.readOnly,
        icon: icon ?? this.icon,
        syncStatus: syncStatus ?? this.syncStatus,
        primary: primary ?? this.primary,
        akiflowPrimary: akiflowPrimary ?? this.akiflowPrimary,
        isAkiflowCalendar: isAkiflowCalendar ?? this.isAkiflowCalendar,
        timezone: timezone ?? this.timezone,
        settings: settings ?? this.settings,
        remoteUpdatedAt: remoteUpdatedAt == null ? this.remoteUpdatedAt : remoteUpdatedAt.value,
        globalCreatedAt: globalCreatedAt ?? this.globalCreatedAt,
        globalUpdatedAt: globalUpdatedAt ?? this.globalUpdatedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
        deletedAt: deletedAt ?? this.deletedAt,
        accountIdentifier: accountIdentifier ?? this.accountIdentifier,
        accountPicture: accountPicture ?? this.accountPicture);
  }

  @override
  Map<String, Object?> toSql() {
    return {
      "id": id,
      "content": content != null ? jsonEncode(color) : null,
      "etag": etag,
      "title": title,
      "description": description,
      "origin_id": originId,
      "akiflow_account_id": akiflowAccountId,
      "origin_account_id": originAccountId,
      "account_id": accountId,
      "connector_id": connectorId,
      "url": url,
      "color": color,
      "read_only": readOnly == true ? 1 : 0,
      "icon": icon,
      "sync_status": syncStatus,
      "primary": primary == true ? 1 : 0,
      "akiflow_primary": akiflowPrimary == true ? 1 : 0,
      "is_akiflow_calendar": isAkiflowCalendar == true ? 1 : 0,
      "timezone": timezone,
      "settings": settings != null ? jsonEncode(settings) : null,
      "remote_updated_at": remoteUpdatedAt,
      "updated_at": updatedAt,
      "created_at": createdAt,
      "deleted_at": deletedAt,
      "account_identifier": accountIdentifier,
      "account_picture": accountPicture,
    };
  }

  static Calendar fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    for (var key in data.keys) {
      switch (key) {
        case "primary":
          data[key] = (data[key] == 1);
          break;
        case "akiflow_primary":
          data[key] = (data[key] == 1);
          break;
        case "read_only":
          data[key] = (data[key] == 1);
          break;
        case "is_akiflow_calendar":
          data[key] = (data[key] == 1);
          break;
        default:
      }
    }

    if (data.containsKey("content") && data["content"] != null) {
      data["content"] = jsonDecode(data["content"] as String);
    }

    if (data.containsKey("settings") && data["settings"] != null) {
      data["settings"] = jsonDecode(data["settings"] as String);
    }

    return Calendar.fromMap(data);
  }

  @override
  List<Object?> get props {
    return [
      id,
      content,
      etag,
      title,
      description,
      originId,
      akiflowAccountId,
      originAccountId,
      accountId,
      connectorId,
      url,
      color,
      readOnly,
      icon,
      syncStatus,
      primary,
      akiflowPrimary,
      isAkiflowCalendar,
      timezone,
      settings,
      remoteUpdatedAt,
      globalCreatedAt,
      globalUpdatedAt,
      createdAt,
      updatedAt,
      deletedAt,
      accountIdentifier,
      accountPicture,
    ];
  }
}
