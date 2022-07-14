import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/create_task/ui/components/custom_text_span.dart';
import 'package:mobile/style/colors.dart';

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

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> textSpanChildren = <InlineSpan>[];

    String? dateMatch;
    bool dateDetected = false;

    try {
      dateMatch = combinedPatternToDetect.allMatches(text).first.group(0);
    } catch (_) {}

    text.splitMapJoin(
      combinedPatternToDetect,
      onMatch: (Match match) {
        final String? textPart = match.group(0);

        if (textPart == null) return '';

        if (listPartNonParsable.contains(textPart)) {
          _addTextSpan(
            textSpanChildren,
            textToBeStyled: textPart,
            foregroundColor: ColorsExt.grey2(context),
          );
          dateDetected = false;
          return '';
        }

        final TextPartStyleDefinition? styleDefinition = styles.getStyleOfTextPart(
          textPart,
          text,
        );

        if (styleDefinition == null) return '';

        if (dateMatch != null && dateMatch == textPart && dateDetected == false) {
          _addTextSpanWithBackground(
            textSpanChildren,
            textToBeStyled: textPart,
            isFromAction: styleDefinition.isFromAction,
            backgroundColor: ColorsExt.cyan25(context),
            foregroundColor: ColorsExt.grey2(context),
          );

          dateDetected = true;
        } else {
          _addTextSpan(
            textSpanChildren,
            textToBeStyled: textPart,
            foregroundColor: ColorsExt.grey2(context),
          );
        }

        return '';
      },
      onNonMatch: (String text) {
        _addTextSpan(
          textSpanChildren,
          textToBeStyled: text,
          foregroundColor: ColorsExt.grey2(context),
        );

        return '';
      },
    );

    return TextSpan(style: style, children: textSpanChildren);
  }

  void _addWidgetSpanWithBackground(
    List<InlineSpan> textSpanChildren, {
    required String? textToBeStyled,
    required bool? isFromAction,
    required Color foregroundColor,
    required Color backgroundColor,
  }) {
    textSpanChildren.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: GestureDetector(
          onTap: () => parsedTextClick(textToBeStyled!, isFromAction),
          child: Container(
              height: 26,
              padding: const EdgeInsets.only(left: 5, right: 0),
              margin: const EdgeInsets.only(top: 2.5, right: 5),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    textToBeStyled!,
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                      height: 1.2,
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  void _addTextSpanWithBackground(
    List<InlineSpan> textSpanChildren, {
    required String? textToBeStyled,
    required bool? isFromAction,
    required Color foregroundColor,
    required Color backgroundColor,
  }) {
    textSpanChildren.add(
      CustomTextSpan(
        text: textToBeStyled,
        style: TextStyle(
          background: Paint()..color = backgroundColor,
          color: foregroundColor,
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            parsedTextClick(textToBeStyled!, isFromAction);
          },
      ),
    );
  }

  void _addTextSpan(
    List<InlineSpan> textSpanChildren, {
    required String? textToBeStyled,
    required Color foregroundColor,
  }) {
    textSpanChildren.add(
      TextSpan(
        text: textToBeStyled,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
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
