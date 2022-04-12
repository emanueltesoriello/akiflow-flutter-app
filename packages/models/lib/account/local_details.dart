import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:models/serializers.dart';

part 'local_details.g.dart';

abstract class LocalDetails
    implements Built<LocalDetails, LocalDetailsBuilder> {
  bool? get firstSyncExecuted;
  DateTime? get lastAccountsSyncAt;
  DateTime? get lastLabelsSyncAt;
  DateTime? get lastTasksSyncAt;
  DateTime? get lastCalendarsSyncAt;
  DateTime? get lastEventsSyncAt;

  LocalDetails._();

  factory LocalDetails([void Function(LocalDetailsBuilder) updates]) =
      _$LocalDetails;

  @override
  LocalDetails rebuild(void Function(LocalDetailsBuilder) updates);

  @override
  LocalDetailsBuilder toBuilder();

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(LocalDetails.serializer, this)
        as Map<String, dynamic>;
  }

  static LocalDetails fromMap(Map<String, dynamic> json) {
    return serializers.deserializeWith(LocalDetails.serializer, json)!;
  }

  Map<String, Object?> toSql() {
    Map<String?, dynamic> data = serializers.serializeWith(
        LocalDetails.serializer, this) as Map<String?, dynamic>;

    for (var key in data.keys) {
      if (data[key] is bool) {
        data[key] = data[key] ? 1 : 0;
      }
    }

    return Map<String, Object?>.from(data);
  }

  static LocalDetails fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    return serializers.deserializeWith(LocalDetails.serializer, data)!;
  }

  static Serializer<LocalDetails> get serializer => _$localDetailsSerializer;
}
