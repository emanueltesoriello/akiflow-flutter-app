import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/utils/stylable_text_editing_controller.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:models/label/label.dart';

import '../../../../../common/style/colors.dart';

class TitleField extends StatelessWidget {
  const TitleField(
      {Key? key,
      required this.stylableController,
      required this.isTitleEditing,
      required this.entityExtractor,
      required this.onDateDetected,
      required this.onLabelDetected,
      required this.onDurationDetected,
      required this.onPriorityDetected,
      required this.labels,
      required this.titleFocus,
      required this.onChanged})
      : super(key: key);
  final StylableTextEditingController stylableController;
  final ValueListenable<bool> isTitleEditing;
  final List<Label> labels;
  final EntityExtractor entityExtractor;
  final Function(DateTimeEntity, String, int, int) onDateDetected;
  final Function(Label, String) onLabelDetected;
  final Function(Duration, String) onDurationDetected;
  final Function(int, String) onPriorityDetected;
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
            onChanged: (String value) async {
              onChanged(value);
              if (value.contains('#')) {
                final i = value.lastIndexOf('#');
                String text = value.substring(i + 1).split(' ')[0].toLowerCase();
                List<Label> labelList = labels.where((element) => element.title?.toLowerCase() == text).toList();
                if (labelList.isNotEmpty) {
                  onLabelDetected(labelList.first, text);
                }
              }
              if (value.contains(' !')) {
                final i = value.lastIndexOf('!');
                String text = value.substring(i + 1).split(' ')[0];

                int? number = int.tryParse(text);
                if (number != null) {
                  onPriorityDetected(number, text);
                }
              }
              if (value.contains('=')) {
                final i = value.lastIndexOf('=');
                String text = value.substring(i + 1).split(' ')[0];

                Duration? duration = parseDuration(text);
                if (duration != null) {
                  onDurationDetected(duration, text);
                }
              }

              if (value.isNotEmpty) {
                final result = await entityExtractor.annotateText(value, entityTypesFilter: [EntityType.dateTime]);
                if (result.isNotEmpty) {
                  onDateDetected(result.last.entities.first as DateTimeEntity, result.last.text, result.last.start,
                      result.last.end);
                }
              } else {
                stylableController.removeMapping(0);
              }
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

  Duration? parseDuration(String s) {
    int? hours = 0;
    int? minutes = 0;
    List<String> parts = s.split(':');
    if (parts.length > 1) {
      hours = int.tryParse(parts[parts.length - 2]);
    }
    if (parts.isNotEmpty) {
      minutes = int.tryParse(parts[parts.length - 1]);
    }
    if (hours != null || minutes != null) {
      return Duration(hours: hours ?? 0, minutes: minutes ?? 0, microseconds: 0);
    }
    return null;
  }
}
