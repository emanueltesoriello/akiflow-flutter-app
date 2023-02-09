import 'package:equatable/equatable.dart';
import 'package:models/account/account.dart';

abstract class DocBase extends Equatable {
  String getLinkedContentSummary([Account? account]);
  String get getSummary;
  String get getFinalURL;
}
