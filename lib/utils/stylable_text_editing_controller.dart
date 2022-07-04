import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/style/colors.dart';

TextStyle style = const TextStyle(color: Colors.black);

class TextPartStyleDefinition {
  TextPartStyleDefinition({
    required this.pattern,
    required this.color,
    required this.isFromAction,
  });

  final String pattern;
  final Color color;
  final bool? isFromAction;
}

class TextPartStyleDefinitions {
  TextPartStyleDefinitions({required this.definitionList});

  final List<TextPartStyleDefinition> definitionList;

  RegExp createCombinedPatternBasedOnStyleMap() {
    final String combinedPatternString = definitionList
        .map<String>(
          (TextPartStyleDefinition textPartStyleDefinition) => textPartStyleDefinition.pattern,
        )
        .join('|');

    return RegExp(
      combinedPatternString,
      multiLine: true,
      caseSensitive: false,
    );
  }

  TextPartStyleDefinition? getStyleOfTextPart(
    String textPart,
    String text,
  ) {
    return List<TextPartStyleDefinition?>.from(definitionList).firstWhere(
      (TextPartStyleDefinition? styleDefinition) {
        if (styleDefinition == null) return false;

        bool hasMatch = false;

        RegExp(styleDefinition.pattern, caseSensitive: false).allMatches(text).forEach(
          (RegExpMatch currentMatch) {
            if (hasMatch) return;

            if (currentMatch.group(0) == textPart) {
              hasMatch = true;
            }
          },
        );

        return hasMatch;
      },
      orElse: () => null,
    );
  }
}

class StyleableTextFieldControllerBackground extends TextEditingController {
  StyleableTextFieldControllerBackground({
    required this.styles,
    required this.parsedTextClick,
    List<String>? initialListPartNonParsable,
  })  : combinedPatternToDetect = styles.createCombinedPatternBasedOnStyleMap(),
        listPartNonParsable = initialListPartNonParsable ?? [];

  TextPartStyleDefinitions styles;
  Pattern combinedPatternToDetect;
  List<String> listPartNonParsable;
  Function(String parsedText, bool? isFromAction) parsedTextClick;

  bool _foundTextParsed = false;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> textSpanChildren = <InlineSpan>[];

    _foundTextParsed = false;

    text.splitMapJoin(
      combinedPatternToDetect,
      onMatch: (Match match) {
        final String? textPart = match.group(0);

        if (textPart == null) return '';

        if (listPartNonParsable.contains(textPart)) {
          _addTextSpan(textSpanChildren, textPart);
          return '';
        }

        final TextPartStyleDefinition? styleDefinition = styles.getStyleOfTextPart(
          textPart,
          text,
        );

        if (styleDefinition == null) return '';

        if (_foundTextParsed == false) {
          _addTextSpanWithBackground(
            textSpanChildren,
            textPart,
            styleDefinition.isFromAction,
            ColorsExt.cyan25(context),
          );

          _foundTextParsed = true;
        } else {
          _addTextSpan(textSpanChildren, textPart);
        }

        return '';
      },
      onNonMatch: (String text) {
        _addTextSpan(textSpanChildren, text);

        return '';
      },
    );

    return TextSpan(style: style, children: textSpanChildren);
  }

  void _addTextSpanWithBackground(
    List<InlineSpan> textSpanChildren,
    String? textToBeStyled,
    bool? isFromAction,
    Color color,
  ) {
    textSpanChildren.add(
      TextSpan(
        text: textToBeStyled,
        style: TextStyle(
          background: Paint()..color = color,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            parsedTextClick(textToBeStyled!, isFromAction);
          },
      ),
    );
  }

  void _addTextSpan(
    List<InlineSpan> textSpanChildren,
    String? textToBeStyled,
  ) {
    textSpanChildren.add(
      TextSpan(
        text: textToBeStyled,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  void setDefinitions(List<TextPartStyleDefinition> newDefinitions) {
    styles = TextPartStyleDefinitions(definitionList: newDefinitions);
    combinedPatternToDetect = styles.createCombinedPatternBasedOnStyleMap();
  }

  void addNonParsableText(String text) {
    listPartNonParsable.add(text);
  }

  void setNonParsableTexts(List<String> newNonParsableText) {
    listPartNonParsable = newNonParsableText;
  }
}
