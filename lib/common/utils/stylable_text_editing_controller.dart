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

  void done() {
    recognizedButRemoved = {};
  }

  MapType? removeMappingByValue(String? value) {
    var map = mapping;
    MapType? removed;
    try {
      removed = map.entries.where((element) => element.key == value).first.value;
    } catch (e) {
      print(e);
    }
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
    return false;
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
        color: color ?? ColorsLight.akiflow,
        fontWeight: FontWeight.w500,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          onclick(textToBeStyled);
        },
    );
  }
}
