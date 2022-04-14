// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Label> _$labelSerializer = new _$LabelSerializer();

class _$LabelSerializer implements StructuredSerializer<Label> {
  @override
  final Iterable<Type> types = const [Label, _$Label];
  @override
  final String wireName = 'Label';

  @override
  Iterable<Object?> serialize(Serializers serializers, Label object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.id;
    if (value != null) {
      result
        ..add('id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.title;
    if (value != null) {
      result
        ..add('title')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.icon;
    if (value != null) {
      result
        ..add('icon')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.color;
    if (value != null) {
      result
        ..add('color')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.createdAt;
    if (value != null) {
      result
        ..add('created_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.updatedAt;
    if (value != null) {
      result
        ..add('updated_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.deletedAt;
    if (value != null) {
      result
        ..add('deleted_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.remoteUpdatedAt;
    if (value != null) {
      result
        ..add('remote_updated_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.sorting;
    if (value != null) {
      result
        ..add('sorting')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.parentId;
    if (value != null) {
      result
        ..add('parent_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.system;
    if (value != null) {
      result
        ..add('system')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.isFolder;
    if (value != null) {
      result
        ..add('is_folder')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.type;
    if (value != null) {
      result
        ..add('type')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.globalUpdatedAt;
    if (value != null) {
      result
        ..add('global_updated_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.globalCreatedAt;
    if (value != null) {
      result
        ..add('global_created_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    return result;
  }

  @override
  Label deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new LabelBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'icon':
          result.icon = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'color':
          result.color = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'created_at':
          result.createdAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'updated_at':
          result.updatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'deleted_at':
          result.deletedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'remote_updated_at':
          result.remoteUpdatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'sorting':
          result.sorting = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'parent_id':
          result.parentId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'system':
          result.system = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'is_folder':
          result.isFolder = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'type':
          result.type = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'global_updated_at':
          result.globalUpdatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'global_created_at':
          result.globalCreatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
      }
    }

    return result.build();
  }
}

class _$Label extends Label {
  @override
  final String? id;
  @override
  final String? title;
  @override
  final String? icon;
  @override
  final String? color;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final DateTime? remoteUpdatedAt;
  @override
  final int? sorting;
  @override
  final String? parentId;
  @override
  final String? system;
  @override
  final String? isFolder;
  @override
  final String? type;
  @override
  final DateTime? globalUpdatedAt;
  @override
  final DateTime? globalCreatedAt;

  factory _$Label([void Function(LabelBuilder)? updates]) =>
      (new LabelBuilder()..update(updates)).build();

  _$Label._(
      {this.id,
      this.title,
      this.icon,
      this.color,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.remoteUpdatedAt,
      this.sorting,
      this.parentId,
      this.system,
      this.isFolder,
      this.type,
      this.globalUpdatedAt,
      this.globalCreatedAt})
      : super._();

  @override
  Label rebuild(void Function(LabelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LabelBuilder toBuilder() => new LabelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Label &&
        id == other.id &&
        title == other.title &&
        icon == other.icon &&
        color == other.color &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        remoteUpdatedAt == other.remoteUpdatedAt &&
        sorting == other.sorting &&
        parentId == other.parentId &&
        system == other.system &&
        isFolder == other.isFolder &&
        type == other.type &&
        globalUpdatedAt == other.globalUpdatedAt &&
        globalCreatedAt == other.globalCreatedAt;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc(
                                                $jc(
                                                    $jc(
                                                        $jc($jc(0, id.hashCode),
                                                            title.hashCode),
                                                        icon.hashCode),
                                                    color.hashCode),
                                                createdAt.hashCode),
                                            updatedAt.hashCode),
                                        deletedAt.hashCode),
                                    remoteUpdatedAt.hashCode),
                                sorting.hashCode),
                            parentId.hashCode),
                        system.hashCode),
                    isFolder.hashCode),
                type.hashCode),
            globalUpdatedAt.hashCode),
        globalCreatedAt.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Label')
          ..add('id', id)
          ..add('title', title)
          ..add('icon', icon)
          ..add('color', color)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt)
          ..add('remoteUpdatedAt', remoteUpdatedAt)
          ..add('sorting', sorting)
          ..add('parentId', parentId)
          ..add('system', system)
          ..add('isFolder', isFolder)
          ..add('type', type)
          ..add('globalUpdatedAt', globalUpdatedAt)
          ..add('globalCreatedAt', globalCreatedAt))
        .toString();
  }
}

class LabelBuilder implements Builder<Label, LabelBuilder> {
  _$Label? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _icon;
  String? get icon => _$this._icon;
  set icon(String? icon) => _$this._icon = icon;

  String? _color;
  String? get color => _$this._color;
  set color(String? color) => _$this._color = color;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  DateTime? _remoteUpdatedAt;
  DateTime? get remoteUpdatedAt => _$this._remoteUpdatedAt;
  set remoteUpdatedAt(DateTime? remoteUpdatedAt) =>
      _$this._remoteUpdatedAt = remoteUpdatedAt;

  int? _sorting;
  int? get sorting => _$this._sorting;
  set sorting(int? sorting) => _$this._sorting = sorting;

  String? _parentId;
  String? get parentId => _$this._parentId;
  set parentId(String? parentId) => _$this._parentId = parentId;

  String? _system;
  String? get system => _$this._system;
  set system(String? system) => _$this._system = system;

  String? _isFolder;
  String? get isFolder => _$this._isFolder;
  set isFolder(String? isFolder) => _$this._isFolder = isFolder;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  DateTime? _globalUpdatedAt;
  DateTime? get globalUpdatedAt => _$this._globalUpdatedAt;
  set globalUpdatedAt(DateTime? globalUpdatedAt) =>
      _$this._globalUpdatedAt = globalUpdatedAt;

  DateTime? _globalCreatedAt;
  DateTime? get globalCreatedAt => _$this._globalCreatedAt;
  set globalCreatedAt(DateTime? globalCreatedAt) =>
      _$this._globalCreatedAt = globalCreatedAt;

  LabelBuilder();

  LabelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _icon = $v.icon;
      _color = $v.color;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _remoteUpdatedAt = $v.remoteUpdatedAt;
      _sorting = $v.sorting;
      _parentId = $v.parentId;
      _system = $v.system;
      _isFolder = $v.isFolder;
      _type = $v.type;
      _globalUpdatedAt = $v.globalUpdatedAt;
      _globalCreatedAt = $v.globalCreatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Label other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Label;
  }

  @override
  void update(void Function(LabelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Label build() {
    final _$result = _$v ??
        new _$Label._(
            id: id,
            title: title,
            icon: icon,
            color: color,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            remoteUpdatedAt: remoteUpdatedAt,
            sorting: sorting,
            parentId: parentId,
            system: system,
            isFolder: isFolder,
            type: type,
            globalUpdatedAt: globalUpdatedAt,
            globalCreatedAt: globalCreatedAt);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
