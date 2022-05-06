import 'package:models/label/label.dart';

extension LabelExt on Label {
  static List<Label> filter(List<Label> labels) {
    return labels.where((element) => element.deletedAt == null).toList();
  }
}
