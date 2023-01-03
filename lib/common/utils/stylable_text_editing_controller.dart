import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';

import 'custom_text_span.dart';

class MapType {
  const MapType(this.type, this.style);

  final int type;
  final TextStyle style;
}

class StylableTextEditingController extends TextEditingController {
  Map<String, MapType> mapping;
  Set<String> recognizedButRemoved;
  Pattern pattern;
  Function(String?) onclick;

  StylableTextEditingController(this.mapping, this.onclick, this.recognizedButRemoved)
      : pattern = RegExp(mapping.keys.map((key) => RegExp.escape(key)).join('|'));

  Map<String, MapType> addMapping(Map<String, MapType> newMapping) {
    var map = mapping;
    mapping.addAll(newMapping);
    mapping = map;
    pattern = RegExp(map.keys.map((key) => RegExp.escape(key)).join('|'));
    return map;
  }

  bool hasParsedDate() {
    return mapping.keys.any((element) => mapping[element]?.type == 0);
  }

  bool hasParsedLabel() {
    return mapping.keys.any((element) => mapping[element]?.type == 1);
  }

  bool hasParsedPriority() {
    return mapping.keys.any((element) => mapping[element]?.type == 2);
  }

  bool hasParsedDuration() {
    return mapping.keys.any((element) => mapping[element]?.type == 3);
  }

  Color? getColorFromValue(String? match) {
    return mapping.entries.where((element) => element.key == match).first.value.style.backgroundColor;
  }

  Map<String, MapType> removeMapping(int type) {
    var map = mapping;
    mapping.removeWhere((key, value) => value.type == type);
    mapping = map;
    pattern = RegExp(map.keys.map((key) => RegExp.escape(key)).join('|'));
    return map;
  }

  MapType removeMappingByValue(String? value) {
    var map = mapping;
    var removed = map.entries.where((element) => element.key == value).first.value;
    if (value != null) {
      recognizedButRemoved = {...recognizedButRemoved, value};
      mapping.removeWhere((k, v) => k == value);
      mapping = map;
      pattern = RegExp(map.keys.map((key) => RegExp.escape(key)).join('|'));
    }
    return removed;
  }

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: TextSelection(baseOffset: newText.length, extentOffset: newText.length),
      composing: TextRange.empty,
    );
  }

  bool isRemoved(String value) {
    return recognizedButRemoved.any((element) => element.contains(value));
  }

  onTap(int type) {
    removeMapping(type);
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    List<InlineSpan> children = [];

    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        if (match.input.isNotEmpty && mapping.isNotEmpty) {
          children.add(
            addTextSpanWithBackground(textToBeStyled: match[0], color: getColorFromValue(match[0])),
          );
        }
        return '';
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return '';
      },
    );

    return TextSpan(style: style, children: children);
  }

  CustomTextSpan addTextSpanWithBackground({
    required String? textToBeStyled,
    required Color? color,
  }) {
    return CustomTextSpan(
      text: textToBeStyled,
      style: TextStyle(
        height: 0.58,
        leadingDistribution: TextLeadingDistribution.even,
        wordSpacing: 0.5,
        background: Paint()
          ..strokeWidth = 9.9
          ..strokeJoin = StrokeJoin.round
          ..color = color ?? ColorsLight.akiflow20
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.square
          ..strokeJoin = StrokeJoin.round,
        fontSize: 16.3,
        // color: foregroundColor,
        fontWeight: FontWeight.w500,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          onclick(textToBeStyled);
        },
    );
  }
}
