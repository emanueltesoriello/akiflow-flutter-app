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

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: 'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: 'deleted_at')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: 'remote_updated_at')
  DateTime? get remoteUpdatedAt;

  @BuiltValueField(wireName: 'sorting')
  int? get sorting;

  @BuiltValueField(wireName: 'parent_id')
  String? get parentId;

  @BuiltValueField(wireName: 'system')
  String? get system;

  @BuiltValueField(wireName: 'is_folder')
  String? get isFolder;

  @BuiltValueField(wireName: 'type')
  String? get type;

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

  static Map<String, dynamic> toMapS(data) {
    return data.toMap();
  }

  static Label fromMap(Map<String, dynamic> json) {
    return serializers.deserializeWith(Label.serializer, json)!;
  }

  @override
  Map<String, Object?> toSql() {
    Map<String?, dynamic> data = serializers.serializeWith(
        Label.serializer, this) as Map<String?, dynamic>;

    data.remove("global_created_at");
    data.remove("global_updated_at");

    for (var key in data.keys) {
      if (data[key] is bool) {
        data[key] = data[key] ? 1 : 0;
      }
    }

    return Map<String, Object?>.from(data);
  }

  static Label fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    for (var key in data.keys) {
      if (key == "done" && data[key] != null) {
        data[key] = (data[key] == 1);
      }

      if ((key == "sorting" || key == "sorting_label") && data[key] != null) {
        data[key] = (int.parse(data[key] as String));
      }
    }

    return serializers.deserializeWith(Label.serializer, data)!;
  }

  static Serializer<Label> get serializer => _$labelSerializer;
}
