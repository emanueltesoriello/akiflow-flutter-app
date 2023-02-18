import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/utils/stylable_text_editing_controller.dart';
import 'package:models/label/label.dart';

import '../../../../../common/style/colors.dart';

class TitleField extends StatelessWidget {
  const TitleField(
      {Key? key,
      required this.stylableController,
      required this.isTitleEditing,
      required this.entityExtractor,
      required this.onDateDetected,
      this.onLabelDetected,
      this.onDurationDetected,
      this.onPriorityDetected,
      required this.labels,
      required this.titleFocus,
      required this.onChanged})
      : super(key: key);
  final StylableTextEditingController stylableController;
  final ValueListenable<bool> isTitleEditing;
  final List<Label> labels;
  final EntityExtractor entityExtractor;
  final Function(DateTimeEntity, String, int, int) onDateDetected;
  final Function(Label, String)? onLabelDetected;
  final Function(Duration, String)? onDurationDetected;
  final Function(int, String)? onPriorityDetected;
  final Function(String) onChanged;

  final FocusNode titleFocus;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: isTitleEditing,
        builder: (context, bool isTitleEditing, child) {
          return TextField(
            controller: stylableController,
            focusNode: titleFocus,
            textCapitalization: TextCapitalization.sentences,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              isDense: true,
              hintText: t.addTask.titleHint,
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: ColorsExt.grey3(context),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              print('On tap');
            },
            onChanged: (String value) async {
              onChanged(value);
              if (value.isNotEmpty) {
                final result = await entityExtractor.annotateText(value, entityTypesFilter: [EntityType.dateTime]);
                if (result.isNotEmpty) {
                  onDateDetected(result.last.entities.first as DateTimeEntity, result.last.text, result.last.start,
                      result.last.end);
                }
              } else {
                stylableController.removeMapping(0);
              }
            },
            style: TextStyle(
              color: ColorsExt.grey2(context),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          );
        });
  }
}
