import 'package:equatable/equatable.dart';

abstract class DocBase extends Equatable {
  String get getLinkedContentSummary;

  @override
  String get getSummary;

  @override
  String get getFinalURL;
}
