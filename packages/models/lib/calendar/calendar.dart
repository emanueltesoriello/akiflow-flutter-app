import 'package:equatable/equatable.dart';
import 'package:models/base.dart';
import 'package:models/nullable.dart';

class Calendar extends Equatable implements Base {
  const Calendar({
    this.id,
    this.userId,
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
    this.webhookId,
    this.webhookResourceId,
    this.globalUpdatedAt,
    this.globalCreatedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.remoteUpdatedAt,
  });

  final String? id;
  final int? userId;
  final String? originId;
  final String? connectorId;
  final String? akiflowAccountId;
  final String? originAccountId;
  final String? etag;
  final String? title;
  final String? description;
  final dynamic content;
  final bool? primary;
  final bool? akiflowPrimary;
  final bool? readOnly;
  final String? url;
  final String? color;
  final dynamic icon;
  final dynamic syncStatus;
  final bool? isAkiflowCalendar;
  final dynamic settings;
  final dynamic webhookId;
  final String? webhookResourceId;
  final String? globalUpdatedAt;
  final String? globalCreatedAt;
  final String? createdAt;
  final String? updatedAt;
  final dynamic deletedAt;
  final String? remoteUpdatedAt;

  factory Calendar.fromMap(Map<String, dynamic> json) => Calendar(
        id: json['id'] as String?,
        userId: json['user_id'] as int?,
        originId: json['origin_id'] as String?,
        connectorId: json['connector_id'] as String?,
        akiflowAccountId: json['akiflow_account_id'] as String?,
        originAccountId: json['origin_account_id'] as String?,
        etag: json['etag'] as String?,
        title: json['title'] as String?,
        description: json['description'] as String?,
        content: json['content'] as dynamic,
        primary: json['primary'] as bool?,
        akiflowPrimary: json['akiflow_primary'] as bool?,
        readOnly: json['read_only'] as bool?,
        url: json['url'] as String?,
        color: json['color'] as String?,
        icon: json['icon'] as dynamic,
        syncStatus: json['sync_status'] as dynamic,
        isAkiflowCalendar: json['is_akiflow_calendar'] as bool?,
        settings: json['settings'] as dynamic,
        webhookId: json['webhook_id'] as dynamic,
        webhookResourceId: json['webhook_resource_id'] as String?,
        globalUpdatedAt: json['global_updated_at'] as String?,
        globalCreatedAt: json['global_created_at'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        deletedAt: json['deleted_at'] as dynamic,
        remoteUpdatedAt: json['remote_updated_at'] as String?,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'origin_id': originId,
        'connector_id': connectorId,
        'akiflow_account_id': akiflowAccountId,
        'origin_account_id': originAccountId,
        'etag': etag,
        'title': title,
        'description': description,
        'content': content,
        'primary': primary,
        'akiflow_primary': akiflowPrimary,
        'read_only': readOnly,
        'url': url,
        'color': color,
        'icon': icon,
        'sync_status': syncStatus,
        'is_akiflow_calendar': isAkiflowCalendar,
        'settings': settings?.toMap(),
        'webhook_id': webhookId,
        'webhook_resource_id': webhookResourceId,
        'global_updated_at': globalUpdatedAt,
        'global_created_at': globalCreatedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'remote_updated_at': remoteUpdatedAt,
      };

  Calendar copyWith({
    String? id,
    int? userId,
    String? originId,
    String? connectorId,
    String? akiflowAccountId,
    String? originAccountId,
    String? etag,
    String? title,
    String? description,
    dynamic content,
    bool? primary,
    bool? akiflowPrimary,
    bool? readOnly,
    String? url,
    String? color,
    dynamic icon,
    dynamic syncStatus,
    bool? isAkiflowCalendar,
    dynamic settings,
    dynamic webhookId,
    String? webhookResourceId,
    String? globalUpdatedAt,
    String? globalCreatedAt,
    String? createdAt,
    Nullable<String?>? updatedAt,
    Nullable<String?>? remoteUpdatedAt,
    dynamic deletedAt,
  }) {
    return Calendar(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      originId: originId ?? this.originId,
      connectorId: connectorId ?? this.connectorId,
      akiflowAccountId: akiflowAccountId ?? this.akiflowAccountId,
      originAccountId: originAccountId ?? this.originAccountId,
      etag: etag ?? this.etag,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      primary: primary ?? this.primary,
      akiflowPrimary: akiflowPrimary ?? this.akiflowPrimary,
      readOnly: readOnly ?? this.readOnly,
      url: url ?? this.url,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      syncStatus: syncStatus ?? this.syncStatus,
      isAkiflowCalendar: isAkiflowCalendar ?? this.isAkiflowCalendar,
      settings: settings ?? this.settings,
      webhookId: webhookId ?? this.webhookId,
      webhookResourceId: webhookResourceId ?? this.webhookResourceId,
      globalUpdatedAt: globalUpdatedAt ?? this.globalUpdatedAt,
      globalCreatedAt: globalCreatedAt ?? this.globalCreatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
      remoteUpdatedAt: remoteUpdatedAt == null ? this.remoteUpdatedAt : remoteUpdatedAt.value,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Object?> toSql() {
    return {
      "id": id,
      "origin_id": originId,
      "connector_id": connectorId,
      "akiflow_account_id": akiflowAccountId,
      "origin_account_id": originAccountId,
      "title": title,
      "description": description,
      "primary": primary == true ? 1 : 0,
      "akiflow_primary": akiflowPrimary == true ? 1 : 0,
      "read_only": readOnly == true ? 1 : 0,
      "url": url,
      "color": color,
      "icon": icon,
      "is_akiflow_calendar": isAkiflowCalendar == null,
      "updated_at": updatedAt,
      "created_at": createdAt,
      "deleted_at": deletedAt,
      "remote_updated_at": remoteUpdatedAt,
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

    return Calendar.fromMap(data);
  }

  @override
  List<Object?> get props {
    return [
      id,
      userId,
      originId,
      connectorId,
      akiflowAccountId,
      originAccountId,
      etag,
      title,
      description,
      content,
      primary,
      akiflowPrimary,
      readOnly,
      url,
      color,
      icon,
      syncStatus,
      isAkiflowCalendar,
      settings,
      webhookId,
      webhookResourceId,
      globalUpdatedAt,
      globalCreatedAt,
      createdAt,
      updatedAt,
      deletedAt,
      remoteUpdatedAt,
    ];
  }
}
