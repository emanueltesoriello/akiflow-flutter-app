import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:models/base.dart';
import 'package:models/content.dart';
import 'package:models/serializers.dart';

part 'doc.g.dart';

abstract class Doc extends Object with Base implements Built<Doc, DocBuilder> {
  @BuiltValueField(wireName: 'id')
  String? get id;

  @BuiltValueField(wireName: 'task_id')
  String? get taskId;

  @BuiltValueField(wireName: 'title')
  String? get title;

  @BuiltValueField(wireName: 'connector_id')
  String? get connectorId;

  @BuiltValueField(wireName: 'origin_id')
  String? get originId;

  @BuiltValueField(wireName: 'account_id')
  String? get accountId;

  @BuiltValueField(wireName: 'url')
  String? get url;

  @BuiltValueField(wireName: 'local_url')
  String? get localUrl;

  @BuiltValueField(wireName: 'type')
  String? get type;

  @BuiltValueField(wireName: 'icon')
  String? get icon;

  @BuiltValueField(wireName: 'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: 'deleted_at')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: 'global_updated_at')
  DateTime? get globalUpdatedAt;

  @BuiltValueField(wireName: 'global_created_at')
  DateTime? get globalCreatedAt;

  @BuiltValueField(wireName: 'remote_updated_at')
  DateTime? get remoteUpdatedAt;

  @BuiltValueField(wireName: 'content')
  Content? get content;

  Doc._();

  factory Doc([void Function(DocBuilder) updates]) = _$Doc;

  @override
  Doc rebuild(void Function(DocBuilder) updates);

  @override
  DocBuilder toBuilder();

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> data =
        serializers.serializeWith(Doc.serializer, this) as Map<String, dynamic>;

    return data;
  }

  static Doc fromMap(Map<String, dynamic> json) {
    return serializers.deserializeWith(Doc.serializer, json)!;
  }

  @override
  Map<String, Object?> toSql() {
    return {
      "id": id,
      "task_id": taskId,
      "connector_id": connectorId,
      "origin_id": originId,
      "account_id": accountId,
      "icon": icon,
      "url": url,
      "local_url": localUrl,
      "type": type,
      "updated_at": globalUpdatedAt?.toIso8601String(),
      "created_at": globalCreatedAt?.toIso8601String(),
      "deleted_at": deletedAt?.toIso8601String(),
      "remote_updated_at": globalUpdatedAt?.toIso8601String(),
      "from": content?.from,
      "internalDate": content?.internalDate,
      "initialSyncMode": content?.initialSyncMode,
    };
  }

  static Doc fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    Content content = Content.fromSql(data);

    Doc doc = serializers.deserializeWith(Doc.serializer, data)!;

    doc = doc.rebuild((d) => d..content = content.toBuilder());

    return doc;
  }

  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<Doc> get serializer => _$docSerializer;
}
