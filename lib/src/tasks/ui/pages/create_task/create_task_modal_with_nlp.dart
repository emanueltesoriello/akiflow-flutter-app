/*//import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/create_task_actions.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/description_field.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/duration_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/label_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/priority_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/send_task_button.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/stylable_text_editing_controller.dart';
import 'package:models/task/task.dart';
// import 'package:mobile/utils/interactive_webview.dart';
// import 'package:mobile/utils/task_extension.dart';
// import 'package:models/label/label_highlight_type.dart';

// import '../../label/cubit/labels_cubit.dart';

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
  List<TextPartStyleDefinition> newDefinitions = [];

  final ScrollController _parentScrollController = ScrollController();

  @override
  void initState() {
    // titleController = StyleableTextFieldControllerBackground(
    //     styles: TextPartStyleDefinitions(
    //       definitionList: [],
    //     ),
    //     parsedTextClick: (parsedText, isFromAction, isLabel, isDate, isTime, isImportance) async {
    //       if (isImportance != null && isImportance) {
    //         context.read<EditTaskCubit>().removePriority();
    //         String newText = titleController.text.replaceAll('!', '');
    //         titleController.text = newText;
    //         titleController.selection = TextSelection.fromPosition(TextPosition(offset: newText.length));
    //       }
    //       if (isTime != null && isTime) {
    //         context.read<EditTaskCubit>().setDuration(0);
    //         String newText = titleController.text.replaceAll('=', '');
    //         titleController.text = newText;
    //         titleController.selection = TextSelection.fromPosition(TextPosition(offset: newText.length));
    //       }
    //       if (isLabel != null && isLabel) {
    //         context.read<EditTaskCubit>().removeLabel();
    //         String newText = titleController.text.replaceAll('#', '');
    //         titleController.text = newText;
    //         titleController.selection = TextSelection.fromPosition(TextPosition(offset: newText.length));
    //       }
    //       titleController.addNonParsableText(parsedText);
    //       newDefinitions.removeWhere((element) => element.pattern == "(?:($parsedText)+)");

    //       TextSelection currentSelection = titleController.selection;

    //       List<ChronoModel>? chronoParsed = await InteractiveWebView.chronoParse(titleController.text);

    //       //_checkTitleWithChrono(chronoParsed, titleController.text);

    //       if (isFromAction != null && isFromAction) {
    //         String newText = titleController.text.replaceFirst(RegExp(parsedText), "");
    //         titleController.text = newText;
    //       } else {
    //         titleController.text = titleController.text;
    //       }

    //       try {
    //         titleController.selection = currentSelection;
    //       } catch (_) {
    //         titleController.selection =
    //             TextSelection(baseOffset: titleController.text.length, extentOffset: titleController.text.length);
    //       }
    //     });

    titleFocus.requestFocus();
    EditTaskCubit editTaskCubit = context.read<EditTaskCubit>();
    titleController.text = editTaskCubit.state.originalTask.title ?? '';

    String descriptionHtml = editTaskCubit.state.originalTask.description ?? '';
    descriptionController.text = descriptionHtml;

    // focusListener = () {
    //   if (!titleFocus.hasFocus) {
    //     checkTitleChrono(titleController.text);
    //   }
    // };

    // titleFocus.addListener(focusListener!);

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
                      const PriorityWidget(),
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
                                  // callback: (List<ChronoModel>? chronoParsed) {
                                  // _checkTitleWithChrono(chronoParsed, titleController.text, isFromAction: true);
                                  //  },
                                ),
                                SendTaskButton(onTap: () {
                                  HapticFeedback.mediumImpact();
                                  context.read<EditTaskCubit>().create();
                                  Task taskUpdated = context.read<EditTaskCubit>().state.updatedTask;
                                  Navigator.pop(context, taskUpdated);
                                }),
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
            controller: _simpleTitleController,
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
            //onChanged: (value) async {
            // context.read<EditTaskCubit>().updateTitle(value);
            // List<ChronoModel>? chronoParsed = await InteractiveWebView.chronoParse(value);
            // _checkContainsNonParsableText();
            // if (value.endsWith(" ")) {
            //   _checkForLabel(value);
            //   _checkTitleWithChrono(chronoParsed, value, isFromAction: false);

            //   _checkForDuration(value);
            //   _checkForImportance(value);
            // }
            // },
          );
        });
  }

  // void checkTitleChrono(String value) {
  //   _isTitleEditing.value = false;
  //   titleController.text = value;
  //   titleController.selection = _simpleTitleController.selection;
  // }

  // void _checkContainsNonParsableText() {
  //   List<String> newNonParsableText = [];

  //   for (var textNonParsable in titleController.listPartNonParsable) {
  //     if (titleController.text.contains(textNonParsable)) {
  //       newNonParsableText.add(textNonParsable);
  //     }
  //   }

  //   titleController.setNonParsableTexts(newNonParsableText);
  // }

  // void _checkForDuration(String text) {
  //   if (text.contains('=')) {
  //     String substring = text.split('=').last.split(' ').first;
  //     List<String> chars = substring.split('');
  //     int hours = chars.indexWhere((element) => element.toLowerCase() == "h");
  //     int minutes = chars.indexWhere((element) => element.toLowerCase() == "m");
  //     try {
  //       int? h = hours != -1 ? int.tryParse(chars[hours - 1]) : null;
  //       int? m = minutes - 2 > -1
  //           ? int.tryParse((chars[minutes - 2] + chars[minutes - 1]).trim())
  //           : ((minutes - 1) > -1 ? int.tryParse((chars[minutes - 1]).trim()) : null);

  //       if (h != null || m != null) {
  //         context.read<EditTaskCubit>().setDuration(((h ?? 0) * 3600) + ((m ?? 0) * 60));
  //         checkForPrevious(HighlightType.time);
  //         newDefinitions.add(TextPartStyleDefinition(
  //             isLabel: false,
  //             isTime: true,
  //             isDate: false,
  //             isImportance: false,
  //             pattern: "(?:(=$substring)+)",
  //             color: ColorsExt.cyan25(context),
  //             isFromAction: false));
  //       }
  //     } catch (e) {
  //       context.read<EditTaskCubit>().setDuration(0);
  //     }
  //   } else {
  //     context.read<EditTaskCubit>().setDuration(0);
  //   }
  // }

  // void _checkForImportance(String text) {
  //   if (text.contains('!1')) {
  //     newDefinitions.add(TextPartStyleDefinition(
  //         isLabel: false,
  //         isTime: false,
  //         isDate: false,
  //         isImportance: true,
  //         pattern: "(?:(!1)+)",
  //         color: ColorsExt.cyan25(context),
  //         isFromAction: false));
  //     context.read<EditTaskCubit>().setPriority(null, value: 1);
  //   } else if (text.contains('!2')) {
  //     newDefinitions.add(TextPartStyleDefinition(
  //         isLabel: false,
  //         isTime: false,
  //         isImportance: true,
  //         isDate: false,
  //         pattern: "(?:(!2)+)",
  //         color: ColorsExt.cyan25(context),
  //         isFromAction: false));
  //     context.read<EditTaskCubit>().setPriority(null, value: 2);
  //   } else if (text.contains('!3')) {
  //     newDefinitions.add(TextPartStyleDefinition(
  //         isLabel: false,
  //         isTime: false,
  //         isDate: false,
  //         isImportance: true,
  //         pattern: "(?:(!3)+)",
  //         color: ColorsExt.cyan25(context),
  //         isFromAction: false));
  //     context.read<EditTaskCubit>().setPriority(null, value: 3);
  //   } else {
  //     context.read<EditTaskCubit>().setPriority(null, value: null);
  //   }
  //   titleController.setDefinitions(newDefinitions);
  // }

  // void _checkForLabel(String text) {
  //   List<String> titles = [];
  //   List<String?> labels = context.read<LabelsCubit>().state.labels.map((e) => e.title).toList();

  //   for (var label in labels) {
  //     if (text.toLowerCase().contains('#${label!.toLowerCase()}')) {
  //       checkForPrevious(HighlightType.label);
  //       newDefinitions.add(TextPartStyleDefinition(
  //           isLabel: true,
  //           isDate: false,
  //           isImportance: false,
  //           isTime: false,
  //           pattern: "(?:(#${label.toLowerCase()})+)",
  //           color: ColorsExt.cyan25(context),
  //           isFromAction: false));
  //       titles.add(label.toLowerCase());
  //     }
  //   }
  //   titleController.setDefinitions(newDefinitions);
  //   if (titles.isNotEmpty) {
  //     context.read<EditTaskCubit>().setLabel(context
  //         .read<LabelsCubit>()
  //         .state
  //         .labels
  //         .where((element) => element.title!.toLowerCase() == titles.last.toLowerCase())
  //         .first);
  //   } else {
  //     context.read<EditTaskCubit>().removeLabel();
  //   }
  //   titleController.setDefinitions(newDefinitions);
  // }

  // void _checkTitleWithChrono(List<ChronoModel>? chronoParsed, String text, {bool? isFromAction}) {
  //   if (chronoParsed == null || chronoParsed.isEmpty) {
  //     context.read<EditTaskCubit>().planFor(null, dateTime: null, statusType: TaskStatusType.inbox);
  //     return;
  //   }

  //   for (var textNonParsable in titleController.listPartNonParsable) {
  //     chronoParsed.removeWhere((chrono) => chrono.text?.trim() == textNonParsable.trim());
  //   }

  //   Color color = ColorsExt.cyan25(context);

  //   for (var chrono in chronoParsed) {
  //     String pattern = "(?:(${chrono.text!})+)";

  //     TextPartStyleDefinition? alreadyDefined = titleController.styles.definitionList.firstWhereOrNull((definition) {
  //       return definition.pattern == pattern;
  //     });
  //     checkForPrevious(HighlightType.date);
  //     newDefinitions.add(TextPartStyleDefinition(
  //       pattern: pattern,
  //       color: color,
  //       isDate: true,
  //       isTime: false,
  //       isImportance: false,
  //       isLabel: false,
  //       isFromAction: alreadyDefined?.isFromAction ?? (isFromAction ?? false),
  //     ));
  //   }

  //   titleController.setDefinitions(newDefinitions);

  //   context.read<EditTaskCubit>().updateTitle(text, chrono: chronoParsed);
  // }

  // void checkForPrevious(HighlightType type) {
//     switch (type) {
//       case HighlightType.label:
//         if (newDefinitions.where((element) => element.isLabel == true).isNotEmpty) {
//           newDefinitions.removeWhere((element) => element.isLabel == true);
//         }
//         break;
//       case HighlightType.date:
//         if (newDefinitions.where((element) => element.isDate == true).isNotEmpty) {
//           newDefinitions.removeWhere((element) => element.isDate == true);
//         }
//         break;
//       case HighlightType.time:
//         if (newDefinitions.where((element) => element.isTime == true).isNotEmpty) {
//           newDefinitions.removeWhere((element) => element.isTime == true);
//         }
//         break;

//       default:
//     }
//   }
// }
}
*/