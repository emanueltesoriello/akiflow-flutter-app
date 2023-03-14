import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:models/base.dart';
import 'package:models/nullable.dart';

class EventModifier extends Equatable implements Base {
  const EventModifier({
    this.id,
    this.akiflowAccountId,
    this.eventId,
    this.calendarId,
    this.action,
    this.content,
    this.processedAt,
    this.failedAt,
    this.result,
    this.attempts,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.remoteUpdatedAt,
    this.globalUpdatedAt,
    this.globalCreatedAt,
  });

  final String? id;
  final String? akiflowAccountId;
  final String? eventId;
  final String? calendarId;
  final String? action;
  final dynamic content;
  final String? processedAt;
  final String? failedAt;
  final dynamic result;
  final int? attempts;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? remoteUpdatedAt;
  final String? globalUpdatedAt;
  final String? globalCreatedAt;

  EventModifier copyWith({
    final String? id,
    final String? akiflowAccountId,
    final String? eventId,
    final String? calendarId,
    final String? action,
    final dynamic content,
    final String? processedAt,
    final String? failedAt,
    final dynamic result,
    final int? attempts,
    final String? createdAt,
    final Nullable<String?>? updatedAt,
    final String? deletedAt,
    final Nullable<String?>? remoteUpdatedAt,
    final String? globalUpdatedAt,
    final String? globalCreatedAt,
  }) {
    return EventModifier(
      id: id ?? this.id,
      akiflowAccountId: akiflowAccountId ?? this.akiflowAccountId,
      eventId: eventId ?? this.eventId,
      calendarId: calendarId ?? this.calendarId,
      action: action ?? this.action,
      content: content ?? this.content,
      processedAt: processedAt ?? this.processedAt,
      failedAt: failedAt ?? this.failedAt,
      result: result ?? this.result,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value,
      deletedAt: deletedAt ?? this.deletedAt,
      remoteUpdatedAt: remoteUpdatedAt == null ? this.remoteUpdatedAt : remoteUpdatedAt.value,
      globalUpdatedAt: globalUpdatedAt ?? this.globalUpdatedAt,
      globalCreatedAt: globalCreatedAt ?? this.globalCreatedAt,
    );
  }

  factory EventModifier.fromMap(Map<String, dynamic> map) => EventModifier(
        id: map['id'] as String?,
        akiflowAccountId: map['akiflow_account_id'] as String?,
        eventId: map['event_id'] as String?,
        calendarId: map['calendar_id'] as String?,
        action: map['action'] as String?,
        content: map['content'] as dynamic,
        processedAt: map['processed_at'] as String?,
        failedAt: map['failed_at'] as String?,
        result: map['result'] as dynamic,
        attempts: map['attempts'] as int?,
        globalUpdatedAt: map['global_updated_at'] as String?,
        globalCreatedAt: map['global_created_at'] as String?,
        remoteUpdatedAt: map['remote_updated_at'] as String?,
        createdAt: map['created_at'] as String?,
        updatedAt: map['updated_at'] as String?,
        deletedAt: map['deleted_at'] as String?,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'akiflow_account_id': akiflowAccountId,
        'event_id': eventId,
        'calendar_id': calendarId,
        'action': action,
        'content': content,
        'global_updated_at': globalUpdatedAt,
        'global_created_at': globalCreatedAt,
        "remote_updated_at": remoteUpdatedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        //'processed_at': processedAt,
        //'failed_at': failedAt,
        //'result': result,
        //'attempts': attempts,
        //'deleted_at': deletedAt, //user not allowed to modify these fields cliend-side
      };

  @override
  Map<String, Object?> toSql() {
    return {
      "id": id,
      "akiflow_account_id": akiflowAccountId,
      "event_id": eventId,
      "calendar_id": calendarId,
      "action": action,
      "content": content != null ? jsonEncode(content) : null,
      "processed_at": processedAt,
      "failed_at": failedAt,
      "result": result != null ? jsonEncode(result) : null,
      "attempts": attempts,
      "remote_updated_at": remoteUpdatedAt,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "deleted_at": deletedAt,
    };
  }

  static EventModifier fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    if (data.containsKey("content") && data["content"] != null) {
      data["content"] = jsonDecode(data["content"] as String);
    }

    if (data.containsKey("result") && data["result"] != null) {
      data["result"] = jsonDecode(data["result"] as String);
    }

    return EventModifier.fromMap(data);
  }

  @override
  List<Object?> get props {
    return [
      id,
      akiflowAccountId,
      eventId,
      calendarId,
      action,
      content,
      processedAt,
      failedAt,
      result,
      attempts,
      globalCreatedAt,
      globalUpdatedAt,
      remoteUpdatedAt,
      createdAt,
      updatedAt,
      deletedAt
    ];
  }
}
