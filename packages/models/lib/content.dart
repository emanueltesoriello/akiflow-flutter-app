import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:models/base.dart';
import 'package:models/serializers.dart';

part 'content.g.dart';

abstract class Content extends Object
    with Base
    implements Built<Content, ContentBuilder> {
  String? get from;

  @BuiltValueField(wireName: 'internalDate')
  String? get internalDate;

  @BuiltValueField(wireName: 'initialSyncMode')
  int? get initialSyncMode;

  Content._();

  factory Content([void Function(ContentBuilder) updates]) = _$Content;

  @override
  Content rebuild(void Function(ContentBuilder) updates);

  @override
  ContentBuilder toBuilder();

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = serializers.serializeWith(
        Content.serializer, this) as Map<String, dynamic>;

    return data;
  }

  static Content fromMap(Map<String, dynamic> json) {
    return serializers.deserializeWith(Content.serializer, json)!;
  }

  @override
  Map<String, Object?> toSql() {
    return {
      'from': from,
      'internalDate': internalDate,
      'initialSyncMode': initialSyncMode,
    };
  }

  static Content fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    return serializers.deserializeWith(Content.serializer, data)!;
  }

  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<Content> get serializer => _$contentSerializer;
}
