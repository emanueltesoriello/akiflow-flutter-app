import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:models/base.dart';
import 'package:models/serializers.dart';

part 'label.g.dart';

abstract class Label extends Object
    with Base
    implements Built<Label, LabelBuilder> {
  @BuiltValueField(wireName: 'id')
  String? get id;

  @BuiltValueField(wireName: 'title')
  String? get title;

  @BuiltValueField(wireName: 'icon')
  String? get icon;

  @BuiltValueField(wireName: 'color')
  String? get color;

  @BuiltValueField(wireName: 'type')
  String? get type;

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: 'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: 'deleted_at')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: 'remote_updated_at')
  DateTime? get remoteUpdatedAt;

  @BuiltValueField(wireName: 'global_updated_at')
  DateTime? get globalUpdatedAt;

  @BuiltValueField(wireName: 'global_created_at')
  DateTime? get globalCreatedAt;

  Label._();

  factory Label([void Function(LabelBuilder) updates]) = _$Label;

  @override
  Label rebuild(void Function(LabelBuilder) updates);

  @override
  LabelBuilder toBuilder();

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = serializers.serializeWith(
        Label.serializer, this) as Map<String, dynamic>;

    return data;
  }

  static Label fromMap(Map<String, dynamic> json) {
    return serializers.deserializeWith(Label.serializer, json)!;
  }

  @override
  Map<String, Object?> toSql() {
    return {
      "id": id,
      "title": title,
      "icon": icon,
      "color": color,
      "type": type,
      "updated_at": updatedAt?.toIso8601String(),
      "created_at": createdAt?.toIso8601String(),
      "deleted_at": deletedAt?.toIso8601String(),
      "remote_updated_at": remoteUpdatedAt?.toIso8601String()
    };
  }

  static Label fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    for (var key in data.keys) {
      if (key == "done" && data[key] != null) {
        data[key] = (data[key] == 1);
      }
    }

    return serializers.deserializeWith(Label.serializer, data)!;
  }

  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<Label> get serializer => _$labelSerializer;
}
