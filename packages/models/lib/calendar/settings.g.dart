// GENERATED CODE - DO NOT MODIFY BY HAND

part of settings;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Settings> _$settingsSerializer = new _$SettingsSerializer();

class _$SettingsSerializer implements StructuredSerializer<Settings> {
  @override
  final Iterable<Type> types = const [Settings, _$Settings];
  @override
  final String wireName = 'Settings';

  @override
  Iterable<Object?> serialize(Serializers serializers, Settings object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.visible;
    if (value != null) {
      result
        ..add('visible')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.notificationsEnabled;
    if (value != null) {
      result
        ..add('notifications_enabled')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    return result;
  }

  @override
  Settings deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new SettingsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'visible':
          result.visible = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'notifications_enabled':
          result.notificationsEnabled = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
      }
    }

    return result.build();
  }
}

class _$Settings extends Settings {
  @override
  final bool? visible;
  @override
  final bool? notificationsEnabled;

  factory _$Settings([void Function(SettingsBuilder)? updates]) =>
      (new SettingsBuilder()..update(updates)).build();

  _$Settings._({this.visible, this.notificationsEnabled}) : super._();

  @override
  Settings rebuild(void Function(SettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SettingsBuilder toBuilder() => new SettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Settings &&
        visible == other.visible &&
        notificationsEnabled == other.notificationsEnabled;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, visible.hashCode), notificationsEnabled.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Settings')
          ..add('visible', visible)
          ..add('notificationsEnabled', notificationsEnabled))
        .toString();
  }
}

class SettingsBuilder implements Builder<Settings, SettingsBuilder> {
  _$Settings? _$v;

  bool? _visible;
  bool? get visible => _$this._visible;
  set visible(bool? visible) => _$this._visible = visible;

  bool? _notificationsEnabled;
  bool? get notificationsEnabled => _$this._notificationsEnabled;
  set notificationsEnabled(bool? notificationsEnabled) =>
      _$this._notificationsEnabled = notificationsEnabled;

  SettingsBuilder();

  SettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _visible = $v.visible;
      _notificationsEnabled = $v.notificationsEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Settings other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Settings;
  }

  @override
  void update(void Function(SettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Settings build() {
    final _$result = _$v ??
        new _$Settings._(
            visible: visible, notificationsEnabled: notificationsEnabled);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
