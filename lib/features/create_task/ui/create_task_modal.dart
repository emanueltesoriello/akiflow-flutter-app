import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';

import 'package:mobile/features/create_task/ui/components/create_task_actions.dart';
import 'package:mobile/features/create_task/ui/components/description_field.dart';
import 'package:mobile/features/create_task/ui/components/label_widget.dart';
import 'package:mobile/features/create_task/ui/components/send_task_button.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';

import 'package:mobile/features/main/ui/chrono_model.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/interactive_webview.dart';
import 'package:mobile/utils/stylable_text_editing_controller.dart';
import 'package:mobile/utils/task_extension.dart';

import 'components/duration_widget.dart';

class CreateTaskModal extends StatefulWidget {
  const CreateTaskModal({Key? key}) : super(key: key);

  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  final TextEditingController descriptionController = TextEditingController();

  final FocusNode titleFocus = FocusNode();

  late final StyleableTextFieldControllerBackground titleController;
  final TextEditingController _simpleTitleController = TextEditingController();

  final ValueNotifier<bool> _isTitleEditing = ValueNotifier<bool>(false);
  Function()? focusListener;

  final ScrollController _parentScrollController = ScrollController();

  @override
  void initState() {
    titleController = StyleableTextFieldControllerBackground(
        styles: TextPartStyleDefinitions(
          definitionList: [],
        ),
        parsedTextClick: (parsedText, isFromAction) async {
          titleController.addNonParsableText(parsedText);

          TextSelection currentSelection = titleController.selection;

          List<ChronoModel>? chronoParsed = await InteractiveWebView.chronoParse(titleController.text);

          _checkTitleWithChrono(chronoParsed, titleController.text);

          if (isFromAction != null && isFromAction) {
            String newText = titleController.text.replaceFirst(RegExp(parsedText), "");
            titleController.text = newText;
          } else {
            titleController.text = titleController.text;
          }

          try {
            titleController.selection = currentSelection;
          } catch (_) {
            titleController.selection =
                TextSelection(baseOffset: titleController.text.length, extentOffset: titleController.text.length);
          }
        });

    titleFocus.requestFocus();
    EditTaskCubit editTaskCubit = context.read<EditTaskCubit>();
    titleController.text = editTaskCubit.state.originalTask.title ?? '';

    String descriptionHtml = editTaskCubit.state.originalTask.description ?? '';
    descriptionController.text = descriptionHtml;

    focusListener = () {
      if (!titleFocus.hasFocus) {
        checkTitleChrono(titleController.text);
      }
    };

    titleFocus.addListener(focusListener!);

    super.initState();
  }

  @override
  void dispose() {
    titleFocus.removeListener(focusListener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: ListView(
        controller: _parentScrollController,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: Container(
                color: Theme.of(context).backgroundColor,
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SafeArea(
                  child: Column(
                    children: [
                      const DurationWidget(),
                      const LabelWidget(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _title(context),
                            const SizedBox(height: 8),
                            DescriptionField(descriptionController: descriptionController),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CreateTaskActions(
                                  titleController: titleController,
                                  titleFocus: titleFocus,
                                  callback: (List<ChronoModel>? chronoParsed) {
                                    _checkTitleWithChrono(chronoParsed, titleController.text, isFromAction: true);
                                  },
                                ),
                                const SendTaskButton(),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _isTitleEditing,
        builder: (context, bool isTitleEditing, child) {
          return TextField(
            controller: isTitleEditing ? _simpleTitleController : titleController,
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
            style: TextStyle(
              color: ColorsExt.grey2(context),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            onTap: () {
              if (!isTitleEditing) {
                _simpleTitleController.text = titleController.text;
                _simpleTitleController.selection = titleController.selection;

                _isTitleEditing.value = true;
              }
            },
            onChanged: (value) async {
              if (isTitleEditing) {
                titleController.text = value;
                titleController.selection = _simpleTitleController.selection;

                int currentSelection = _simpleTitleController.selection.baseOffset;
                String lastCharInserted = value.substring(currentSelection - 1, currentSelection);

                if (lastCharInserted == " ") {
                  checkTitleChrono(value);
                }
              } else {
                _simpleTitleController.text = value;
                _simpleTitleController.selection = titleController.selection;
              }

              context.read<EditTaskCubit>().updateTitle(value);

              List<ChronoModel>? chronoParsed = await InteractiveWebView.chronoParse(value);

              _checkContainsNonParsableText();

              _checkTitleWithChrono(chronoParsed, value, isFromAction: false);
            },
          );
        });
  }

  void checkTitleChrono(String value) {
    _isTitleEditing.value = false;

    titleController.text = value;
    titleController.selection = _simpleTitleController.selection;
  }

  void _checkContainsNonParsableText() {
    List<String> newNonParsableText = [];

    for (var textNonParsable in titleController.listPartNonParsable) {
      if (titleController.text.contains(textNonParsable)) {
        newNonParsableText.add(textNonParsable);
      }
    }

    titleController.setNonParsableTexts(newNonParsableText);
  }

  void _checkTitleWithChrono(List<ChronoModel>? chronoParsed, String text, {bool? isFromAction}) {
    if (chronoParsed == null || chronoParsed.isEmpty) {
      context.read<EditTaskCubit>().planFor(null, dateTime: null, statusType: TaskStatusType.inbox);
      return;
    }

    for (var textNonParsable in titleController.listPartNonParsable) {
      chronoParsed.removeWhere((chrono) => chrono.text == textNonParsable);
    }

    Color color = ColorsExt.cyan25(context);

    List<TextPartStyleDefinition> newDefinitions = [];
    for (var chrono in chronoParsed) {
      newDefinitions.add(TextPartStyleDefinition(
        pattern: "(?:(${chrono.text!})+)",
        color: color,
        isFromAction: isFromAction,
      ));
    }

    titleController.setDefinitions(newDefinitions);

    context.read<EditTaskCubit>().updateTitle(text, chrono: chronoParsed);
  }
}
