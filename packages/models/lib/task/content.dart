import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:models/base.dart';
import 'package:models/serializers.dart';

part 'content.g.dart';

abstract class Content extends Object
    with Base
    implements Built<Content, ContentBuilder> {
  @BuiltValueField(wireName: 'eventLockInCalendar')
  String? get eventLockInCalendar;

  @BuiltValueField(wireName: 'shouldRemoveCalendarEvent')
  bool? get shouldRemoveCalendarEvent;

  @BuiltValueField(wireName: 'expiredSnooze')
  bool? get expiredSnooze;

  @BuiltValueField(wireName: 'overdue')
  bool? get overdue;

  Content._();

  factory Content([void Function(ContentBuilder) updates]) = _$Content;

  @override
  Content rebuild(void Function(ContentBuilder) updates);

  @override
  ContentBuilder toBuilder();

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(Content.serializer, this)
        as Map<String, dynamic>;
  }

  @override
  Map<String, Object?> toSql() {
    return Map<String, Object?>.from(toMap());
  }

  static Content fromMap(Map<String, dynamic> json) {
    return serializers.deserializeWith(Content.serializer, json)!;
  }

  static Serializer<Content> get serializer => _$contentSerializer;
}
