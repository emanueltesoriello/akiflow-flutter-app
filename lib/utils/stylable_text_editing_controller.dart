import 'package:flutter/material.dart';
import 'package:mobile/style/colors.dart';

TextStyle style = const TextStyle(color: Colors.black);

class TextPartStyleDefinition {
  TextPartStyleDefinition({
    required this.pattern,
    required this.color,
  });

  final String pattern;
  final Color color;
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
  }) : combinedPattern = styles.createCombinedPatternBasedOnStyleMap();

  TextPartStyleDefinitions styles;
  Pattern combinedPattern;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> textSpanChildren = <InlineSpan>[];

    text.splitMapJoin(
      combinedPattern,
      onMatch: (Match match) {
        final String? textPart = match.group(0);

        if (textPart == null) return '';

        final TextPartStyleDefinition? styleDefinition = styles.getStyleOfTextPart(
          textPart,
          text,
        );

        if (styleDefinition == null) return '';

        _addTextSpanWithBackground(textSpanChildren, textPart, ColorsExt.cyan25(context));

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
    combinedPattern = styles.createCombinedPatternBasedOnStyleMap();
  }
}
