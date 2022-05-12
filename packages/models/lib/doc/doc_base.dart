import 'package:equatable/equatable.dart';

abstract class DocBase extends Equatable {
  String get getLinkedContentSummary;
  String get getSummary;
  String get getFinalURL;
}
