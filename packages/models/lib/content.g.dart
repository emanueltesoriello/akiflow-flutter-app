// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Content> _$contentSerializer = new _$ContentSerializer();

class _$ContentSerializer implements StructuredSerializer<Content> {
  @override
  final Iterable<Type> types = const [Content, _$Content];
  @override
  final String wireName = 'Content';

  @override
  Iterable<Object?> serialize(Serializers serializers, Content object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.from;

    result
      ..add('from')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.internalDate;

    result
      ..add('internalDate')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.initialSyncMode;

    result
      ..add('initialSyncMode')
      ..add(serializers.serialize(value, specifiedType: const FullType(int)));

    return result;
  }

  @override
  Content deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ContentBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'from':
          result.from = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'internalDate':
          result.internalDate = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'initialSyncMode':
          result.initialSyncMode = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
      }
    }

    return result.build();
  }
}

class _$Content extends Content {
  @override
  final String? from;
  @override
  final String? internalDate;
  @override
  final int? initialSyncMode;

  factory _$Content([void Function(ContentBuilder)? updates]) =>
      (new ContentBuilder()..update(updates)).build();

  _$Content._({this.from, this.internalDate, this.initialSyncMode}) : super._();

  @override
  Content rebuild(void Function(ContentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContentBuilder toBuilder() => new ContentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Content &&
        from == other.from &&
        internalDate == other.internalDate &&
        initialSyncMode == other.initialSyncMode;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, from.hashCode), internalDate.hashCode),
        initialSyncMode.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Content')
          ..add('from', from)
          ..add('internalDate', internalDate)
          ..add('initialSyncMode', initialSyncMode))
        .toString();
  }
}

class ContentBuilder implements Builder<Content, ContentBuilder> {
  _$Content? _$v;

  String? _from;
  String? get from => _$this._from;
  set from(String? from) => _$this._from = from;

  String? _internalDate;
  String? get internalDate => _$this._internalDate;
  set internalDate(String? internalDate) => _$this._internalDate = internalDate;

  int? _initialSyncMode;
  int? get initialSyncMode => _$this._initialSyncMode;
  set initialSyncMode(int? initialSyncMode) =>
      _$this._initialSyncMode = initialSyncMode;

  ContentBuilder();

  ContentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _from = $v.from;
      _internalDate = $v.internalDate;
      _initialSyncMode = $v.initialSyncMode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Content other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Content;
  }

  @override
  void update(void Function(ContentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Content build() {
    final _$result = _$v ??
        new _$Content._(
            from: from,
            internalDate: internalDate,
            initialSyncMode: initialSyncMode);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
