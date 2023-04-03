import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/custom_text_span.dart';

class TextPartStyleDefinition {
  TextPartStyleDefinition({
    required this.pattern,
    required this.color,
    required this.isFromAction,
    required this.isLabel,
    required this.isDate,
    required this.isTime,
    required this.isImportance,
  });

  final String pattern;
  final Color color;
  final bool? isFromAction;
  final bool? isLabel;
  final bool? isDate;
  final bool? isTime;
  final bool? isImportance;
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
  Function(String parsedText, bool? isFromAction, bool? isLabel, bool? isDate, bool? isTime, bool? isImportance)
      parsedTextClick;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> textSpanChildren = <InlineSpan>[];

    // String? dateMatch;
    // bool dateDetected = false;

    // try {
    //   dateMatch = combinedPatternToDetect.allMatches(text).first.group(0);
    // } catch (_) {}

    text.splitMapJoin(
      combinedPatternToDetect,
      onMatch: (Match match) {
        final String? textPart = match.group(0);

        final TextPartStyleDefinition? styleDefinition = styles.getStyleOfTextPart(
          textPart ?? '',
          text,
        );

        _addTextSpanWithBackground(textSpanChildren,
            textToBeStyled: textPart,
            isFromAction: styleDefinition?.isFromAction,
            isLabel: styleDefinition?.isLabel,
            isDate: styleDefinition?.isDate,
            isTime: styleDefinition?.isTime,
            isImportance: styleDefinition?.isImportance,
            backgroundColor: ColorsExt.cyan25(context),
            foregroundColor: ColorsExt.grey2(context),
            context: context);

        return '';
      },
      onNonMatch: (String text) {
        _addTextSpan(textSpanChildren,
            textToBeStyled: text, foregroundColor: ColorsExt.grey2(context), context: context);

        return '';
      },
    );

    return TextSpan(style: style, children: textSpanChildren);
  }

  void _addTextSpanWithBackground(List<InlineSpan> textSpanChildren,
      {required String? textToBeStyled,
      required bool? isFromAction,
      required bool? isLabel,
      required bool? isImportance,
      required bool? isDate,
      required bool? isTime,
      required Color foregroundColor,
      required Color backgroundColor,
      required BuildContext context}) {
    textSpanChildren.add(
      CustomTextSpan(
        text: textToBeStyled,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              background: Paint()..color = backgroundColor,
              color: foregroundColor,
              fontWeight: FontWeight.w500,
            ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            parsedTextClick(textToBeStyled!, isFromAction, isLabel, isDate, isTime, isImportance);
          },
      ),
    );
  }

  void _addTextSpan(
    List<InlineSpan> textSpanChildren, {
    required String? textToBeStyled,
    required Color foregroundColor,
    required BuildContext context,
  }) {
    textSpanChildren.add(
      TextSpan(
          text: textToBeStyled,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w500,
              )),
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
