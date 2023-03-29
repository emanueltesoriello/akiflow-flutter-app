import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/utils/stylable_text_editing_controller.dart';
import 'package:mobile/core/services/chrono_js_service.dart';
import 'package:models/nlp/nlp_date_time.dart';

class TitleNlpTextField extends StatefulWidget {
  final StylableTextEditingController stylableController;
  final FocusNode titleFocus;
  final Function(String, {String? textWithoutDate}) onChanged;
  final Function(NLPDateTime) onDateDetected;
  final Function() setToInbox;

  const TitleNlpTextField(
      {super.key,
      required this.stylableController,
      required this.titleFocus,
      required this.onChanged,
      required this.setToInbox,
      required this.onDateDetected});

  @override
  State<TitleNlpTextField> createState() => _TestJsLibraryState();
}

class _TestJsLibraryState extends State<TitleNlpTextField> {
  TextEditingController textEditingController = TextEditingController();
  late ChronoJsLibrary chronoJsLibrary;
  Future<bool>? isLoaded;
  NLPDateTime? nlpDateTime;
  String? lastTextWithoutDate;

  @override
  void initState() {
    super.initState();
    chronoJsLibrary = ChronoJsLibrary();
    isLoaded = chronoJsLibrary.initJsEngine();
  }

  @override
  void dispose() {
    chronoJsLibrary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.stylableController,
      focusNode: widget.titleFocus,
      textCapitalization: TextCapitalization.sentences,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        isDense: true,
        hintText: t.addTask.titleHint,
        border: InputBorder.none,
        hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: ColorsExt.grey3(context),
              fontWeight: FontWeight.w500,
            ),
      ),
      onTap: () {
        print('On tap');
      },
      onChanged: (text) async {
        if (await isLoaded != null && await isLoaded!) {
          widget.onChanged(text);
          if (text.isNotEmpty) {
            nlpDateTime = chronoJsLibrary.runNlp(text);
            if (nlpDateTime != null &&
                ((nlpDateTime!.hasDate != null && nlpDateTime!.hasDate!) ||
                    (nlpDateTime!.hasTime != null && nlpDateTime!.hasTime!))) {
              widget.onDateDetected(nlpDateTime!);
              widget.onChanged(text, textWithoutDate: nlpDateTime!.textWithoutDate!);
              lastTextWithoutDate = nlpDateTime?.textWithDate;
            } else {
              print(nlpDateTime!.toMap().toString());
              widget.stylableController.removeMapping(0);
              if (lastTextWithoutDate != null && nlpDateTime?.textWithDate == null) widget.setToInbox();
            }
          } else {
            widget.stylableController.removeMapping(0);
          }
        }
      },
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: ColorsExt.grey2(context),
            fontWeight: FontWeight.w500,
          ),
    );
  }
}
