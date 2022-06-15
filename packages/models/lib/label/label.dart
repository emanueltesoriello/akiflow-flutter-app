import 'package:equatable/equatable.dart';
import 'package:models/base.dart';
import 'package:models/nullable.dart';

class Label extends Equatable implements Base {
  const Label({
    this.id,
    this.userId,
    this.title,
    this.icon,
    this.color,
    this.sorting,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.globalUpdatedAt,
    this.parentId,
    this.globalCreatedAt,
    this.system,
    this.type,
    this.remoteUpdatedAt,
  });

  final String? id;
  final int? userId;
  final String? title;
  final dynamic icon;
  final dynamic color;
  final int? sorting;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? globalUpdatedAt;
  final String? parentId;
  final String? globalCreatedAt;
  final dynamic system;
  final String? type;
  final String? remoteUpdatedAt;

  factory Label.fromMap(Map<String, dynamic> json) => Label(
        id: json['id'] as String?,
        userId: json['user_id'] as int?,
        title: json['title'] as String?,
        icon: json['icon'] as dynamic,
        color: json['color'] as dynamic,
        sorting: json['sorting'] as int?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        deletedAt: json['deleted_at'] as String?,
        globalUpdatedAt: json['global_updated_at'] as String?,
        parentId: json['parent_id'] as String?,
        globalCreatedAt: json['global_created_at'] as String?,
        system: json['system'] as dynamic,
        type: json['type'] as String?,
        remoteUpdatedAt: json['remote_updated_at'] as String?,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'icon': icon,
        'color': color,
        'sorting': sorting,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'global_updated_at': globalUpdatedAt,
        'parent_id': parentId,
        'global_created_at': globalCreatedAt,
        'system': system,
        'type': type,
        'remote_updated_at': remoteUpdatedAt,
      };

  Label copyWith({
    String? id,
    int? userId,
    String? title,
    dynamic icon,
    dynamic color,
    int? sorting,
    String? createdAt,
    String? deletedAt,
    String? globalUpdatedAt,
    Nullable<String?>? parentId,
    String? globalCreatedAt,
    dynamic system,
    String? type,
    Nullable<String?>? updatedAt,
    Nullable<String?>? remoteUpdatedAt,
  }) {
    return Label(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sorting: sorting ?? this.sorting,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      globalUpdatedAt: globalUpdatedAt ?? this.globalUpdatedAt,
      parentId: parentId == null ? this.parentId : parentId.value,
      globalCreatedAt: globalCreatedAt ?? this.globalCreatedAt,
      system: system ?? this.system,
      type: type ?? this.type,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
      remoteUpdatedAt: remoteUpdatedAt == null
          ? this.remoteUpdatedAt
          : remoteUpdatedAt.value,
    );
  }

  @override
  Map<String, Object?> toSql() {
    return {
      "id": id,
      "title": title,
      "icon": icon,
      "color": color,
      "type": type,
      "parent_id": parentId,
      "user_id": userId,
      "sorting": sorting,
      "updated_at": updatedAt,
      "created_at": createdAt,
      "deleted_at": deletedAt,
      "remote_updated_at": remoteUpdatedAt,
    };
  }

  static Label fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    for (var key in data.keys) {
      if (key == "done" && data[key] != null) {
        data[key] = (data[key] == 1);
      }
    }

    return Label.fromMap(data);
  }

  @override
  List<Object?> get props {
    return [
      id,
      userId,
      title,
      icon,
      color,
      sorting,
      createdAt,
      updatedAt,
      deletedAt,
      globalUpdatedAt,
      parentId,
      globalCreatedAt,
      system,
      type,
      remoteUpdatedAt,
    ];
  }
}
