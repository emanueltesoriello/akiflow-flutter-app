import 'package:models/label/label.dart';

extension LabelExt on Label {
  static List<Label> filter(List<Label> labels) {
    List<Label> filtered = List.from(labels);
    filtered.removeWhere((element) => element.deletedAt != null);
    filtered.removeWhere((element) => element.type != null && element.type == "section");
    return filtered;
  }
}
