import 'package:equatable/equatable.dart';

class ChronoModel extends Equatable {
  final Reference? reference;
  final String? refDate;
  final int? index;
  final String? text;
  final ChronoDate? start;
  final ChronoDate? end;

  DateTime? get impliedDate {
    try {
      int year = start!.knownValues?.year ?? start!.impliedValues!.year!;
      int month = start!.knownValues?.month ?? start!.impliedValues!.month!;
      int day = start!.knownValues?.day ?? start!.impliedValues!.day!;
      int hour = start?.knownValues?.hour ?? start?.impliedValues?.hour ?? 0;
      int minute = start?.knownValues?.minute ?? start?.impliedValues?.minute ?? 0;

      return DateTime(year, month, day, hour, minute);
    } catch (_) {}

    return null;
  }

  const ChronoModel({
    this.reference,
    this.refDate,
    this.index,
    this.text,
    required this.start,
    this.end,
  });

  ChronoModel copyWith({
    Reference? reference,
    String? refDate,
    int? index,
    String? text,
    ChronoDate? start,
    ChronoDate? end,
  }) {
    return ChronoModel(
      reference: reference ?? this.reference,
      refDate: refDate ?? this.refDate,
      index: index ?? this.index,
      text: text ?? this.text,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reference': reference?.toMap(),
      'refDate': refDate,
      'index': index,
      'text': text,
      'start': start?.toMap(),
      'end': end?.toMap(),
    };
  }

  factory ChronoModel.fromMap(Map<String, dynamic> map) {
    return ChronoModel(
      reference: map['reference'] != null ? Reference.fromMap(map['reference'] as Map<String, dynamic>) : null,
      refDate: map['refDate'] as String?,
      index: map['index'] as int?,
      text: map['text'] as String?,
      start: map['start'] != null ? ChronoDate.fromMap(map['start'] as Map<String, dynamic>) : null,
      end: map['end'] != null ? ChronoDate.fromMap(map['end'] as Map<String, dynamic>) : null,
    );
  }

  @override
  List<Object?> get props {
    return [
      reference,
      refDate,
      index,
      text,
      start,
      end,
    ];
  }
}

class Reference extends Equatable {
  final String? instant;

  const Reference({
    required this.instant,
  });

  Reference copyWith({
    String? instant,
  }) {
    return Reference(
      instant: instant ?? this.instant,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'instant': instant,
    };
  }

  factory Reference.fromMap(Map<String, dynamic> map) {
    return Reference(
      instant: map['instant'] as String?,
    );
  }

  @override
  List<Object?> get props => [instant];
}

class ChronoDate extends Equatable {
  final Reference? reference;
  final Values? knownValues;
  final Values? impliedValues;

  const ChronoDate({
    this.reference,
    required this.knownValues,
    required this.impliedValues,
  });

  ChronoDate copyWith({
    Reference? reference,
    Values? knownValues,
    Values? impliedValues,
  }) {
    return ChronoDate(
      reference: reference ?? this.reference,
      knownValues: knownValues ?? this.knownValues,
      impliedValues: impliedValues ?? this.impliedValues,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reference': reference?.toMap(),
      'knownValues': knownValues?.toMap(),
      'impliedValues': impliedValues?.toMap(),
    };
  }

  factory ChronoDate.fromMap(Map<String, dynamic> map) {
    return ChronoDate(
      reference: map['reference'] != null ? Reference.fromMap(map['reference'] as Map<String, dynamic>) : null,
      knownValues: map['knownValues'] != null ? Values.fromMap(map['knownValues'] as Map<String, dynamic>) : null,
      impliedValues: map['impliedValues'] != null ? Values.fromMap(map['impliedValues'] as Map<String, dynamic>) : null,
    );
  }

  @override
  List<Object?> get props => [reference, knownValues, impliedValues];
}

class Values extends Equatable {
  final int? year;
  final int? month;
  final int? day;
  final int? hour;
  final int? minute;
  final int? second;
  final int? millisecond;

  const Values({
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minute,
    this.second,
    this.millisecond,
  });

  Values copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
  }) {
    return Values(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      millisecond: millisecond ?? this.millisecond,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'second': second,
      'millisecond': millisecond,
    };
  }

  factory Values.fromMap(Map<String, dynamic> map) {
    return Values(
      year: map['year'] as int?,
      month: map['month'] as int?,
      day: map['day'] as int?,
      hour: map['hour'] as int?,
      minute: map['minute'] as int?,
      second: map['second'] as int?,
      millisecond: map['millisecond'] as int?,
    );
  }

  @override
  List<Object?> get props {
    return [
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
    ];
  }
}
