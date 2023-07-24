import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:webview_flutter/webview_flutter.dart';

import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/no_scroll_behav.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/create_task/create_task_duration.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_bottom_actions.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_linked_content.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_links.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_row.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_top_actions.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:flutter_quill/src/models/documents/document.dart';

class EditTaskModal extends StatefulWidget {
  const EditTaskModal({Key? key}) : super(key: key);

  @override
  State<EditTaskModal> createState() => _EditTaskModalState();
}

class _EditTaskModalState extends State<EditTaskModal> {
  final TextEditingController _titleController = TextEditingController();
  ValueNotifier<quill.QuillController> quillController = ValueNotifier<quill.QuillController>(
    quill.QuillController(document: quill.Document(), selection: const TextSelection.collapsed(offset: 0)),
  );
  late QuillEditorController quillEditorController;

  WebViewController? wController;
  StreamSubscription? streamSubscription;

  FocusNode _descriptionFocusNode = FocusNode();
  FocusNode _titleFocusNode = FocusNode();

  @override
  void initState() {
    _init(isFirstInit: true);
    super.initState();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _init({bool isFirstInit = false}) async {
    EditTaskCubit cubit = context.read<EditTaskCubit>();
    context.read<EditTaskCubit>().setRead();
    if (isFirstInit) {
      _titleController.text = cubit.state.updatedTask.title ?? '';
    } else {
      _titleController.text = cubit.state.originalTask.title ?? '';
    }

    initFocusNodeListener();
    await initDescription(isFirstInit: isFirstInit);
  }

  void initFocusNodeListener() {
    EditTaskCubit cubit = context.read<EditTaskCubit>();
    _titleFocusNode.addListener(() {
      print('Focus on title');
      if (_titleFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 0), () {
          cubit.setHasFocusOnTitleOrDescription(true);
        });
      }
    });
    _descriptionFocusNode.addListener(() {
      print('Focus on description');
      if (_descriptionFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 0), () {
          cubit.setHasFocusOnTitleOrDescription(true);
        });
      }
    });
  }

  Future<void> initDescription({bool isFirstInit = false}) async {
    EditTaskCubit cubit = context.read<EditTaskCubit>();
    quillEditorController = QuillEditorController();

    quillEditorController.onEditorLoaded(() async {
      debugPrint('Editor Loaded :)');
      String html;
      if (isFirstInit) {
        html = cubit.state.updatedTask.description ?? '';
      } else {
        html = cubit.state.originalTask.description ?? '';
      }
      await quillEditorController.insertText(html, index: 0);
      var delta = await quillEditorController.getDelta();
      quill.Document document = Document.fromJson(delta["ops"]);

      quillController.value =
          quill.QuillController(document: document, selection: const TextSelection.collapsed(offset: 0));
      quillController.value.changes.listen((change) async {
        quillEditorController.setDelta({"ops": quillController.value.document.toDelta().toJson()});
        var htmlText = await quillEditorController.getText();
        cubit.updateDescription(htmlText);
      });
      quillController.value.moveCursorToEnd();
    });
  }

  Future<bool> onBack(EditTaskCubitState state) async {
    EditTaskCubit cubit = context.read<EditTaskCubit>();
    if (state.hasFocusOnTitleOrDescription) {
      if (cubit.state.originalTask == cubit.state.updatedTask) {
        cubit.setHasFocusOnTitleOrDescription(false);
        FocusScope.of(context).unfocus();
      } else {
        return await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  surfaceTintColor: Colors.white,
                  backgroundColor: Colors.white,
                  shape:
                      const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Dimension.radiusM))),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: Dimension.padding),
                      Text(
                        'Discard changes?',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: ColorsExt.grey900(context)),
                      ),
                      const SizedBox(height: Dimension.paddingM),
                      Text(
                        'The changes you’ve made won’t be saved',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            ?.copyWith(color: ColorsExt.grey700(context), fontWeight: FontWeight.normal),
                      ),
                      Text('The changes you’ve made won’t be saved',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: ColorsExt.grey700(context), fontWeight: FontWeight.normal)),
                      const SizedBox(height: Dimension.paddingM),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            style: Theme.of(context)
                                .textButtonTheme
                                .style
                                ?.copyWith(overlayColor: MaterialStateProperty.all(ColorsExt.grey200(context))),
                            onPressed: () async {
                              Navigator.of(context).pop(false);
                            },
                            child: Text('Cancel'.toUpperCase(),
                                style:
                                    Theme.of(context).textTheme.bodyLarge?.copyWith(color: ColorsExt.grey900(context))),
                          ),
                          const SizedBox(width: Dimension.padding),
                          TextButton(
                            style: Theme.of(context)
                                .textButtonTheme
                                .style
                                ?.copyWith(overlayColor: MaterialStateProperty.all(ColorsExt.grey200(context))),
                            onPressed: () async {
                              streamSubscription?.cancel();
                              /* quillController = ValueNotifier<quill.QuillController>(
                                quill.QuillController(
                                    document: quill.Document(), selection: const TextSelection.collapsed(offset: 0)),
                              );*/
                              await _init();
                              cubit.undoChanges();
                              cubit.setHasFocusOnTitleOrDescription(false);
                              FocusScope.of(context).unfocus();
                              Navigator.of(context).pop(true);
                            },
                            child: Text('Discard'.toUpperCase(),
                                style:
                                    Theme.of(context).textTheme.bodyLarge?.copyWith(color: ColorsExt.grey900(context))),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ) ??
            false;
      }
    } else {
      Navigator.of(context).pop(true);
      return true;
    }
    return false;
  }

  Widget _buildActionsForFocusNodes(EditTaskCubitState state) {
    EditTaskCubit cubit = context.read<EditTaskCubit>();

    return Container(
      padding: const EdgeInsets.only(left: Dimension.paddingS, right: Dimension.paddingS),
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () {
              onBack(state);
            },
            icon: Icon(Icons.arrow_back, size: 16, color: ColorsExt.grey600(context)),
            label: Text(
              'Edit task',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: ColorsExt.grey600(context)),
            ),
          ),
          TextButton(
            onPressed: () {
              _titleFocusNode.unfocus();
              _descriptionFocusNode.unfocus();
              cubit.setHasFocusOnTitleOrDescription(false);
            },
            child: Text(
              'SAVE',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.w500, color: ColorsExt.akiflow500(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedChild(bool showWidget, Widget child) {
    Widget animatedChild = Container();

    return AnimatedSwitcher(
      reverseDuration: const Duration(milliseconds: 300),
      duration: const Duration(milliseconds: 300),
      child: showWidget ? child : animatedChild,
    );
  }

  Widget _buildContent(EditTaskCubitState state) {
    return ScrollConfiguration(
      behavior: NoScrollBehav(),
      child: ListView(
        shrinkWrap: true,
        children: [
          Column(
            children: [
              if (state.hasFocusOnTitleOrDescription) const SizedBox(height: Dimension.padding),
              EditTaskRow(
                key: const GlobalObjectKey('EditTaskRow'),
                quillEditorController: quillEditorController,
                controller: quillController,
                titleController: _titleController,
                descriptionFocusNode: _descriptionFocusNode,
                titleFocusNode: _titleFocusNode,
              ),
              if (!state.hasFocusOnTitleOrDescription) const SizedBox(height: Dimension.padding),
              if (!state.hasFocusOnTitleOrDescription) const Separator(),
              if (!state.hasFocusOnTitleOrDescription) const EditTaskLinkedContent(),
              if (!state.hasFocusOnTitleOrDescription) const EditTaskLinks(),
              if (!state.hasFocusOnTitleOrDescription) const EditTaskBottomActions(),
              if (!state.hasFocusOnTitleOrDescription) const Separator(),
            ],
          ),
        ],
      ),
    );
  }

  Widget body(EditTaskCubitState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: Dimension.padding),
        _buildAnimatedChild(
          !state.hasFocusOnTitleOrDescription,
          const ScrollChip(),
        ),
        _buildAnimatedChild(
          !state.hasFocusOnTitleOrDescription,
          const SizedBox(height: Dimension.padding),
        ),
        _buildAnimatedChild(
          !state.hasFocusOnTitleOrDescription,
          BlocBuilder<EditTaskCubit, EditTaskCubitState>(
            builder: (context, state) {
              return Visibility(
                visible: state.showDuration,
                replacement: const SizedBox(),
                child: Column(
                  children: const [
                    Separator(),
                    CreateTaskDurationItem(),
                  ],
                ),
              );
            },
          ),
        ),
        _buildAnimatedChild(
          !state.hasFocusOnTitleOrDescription,
          const EditTaskTopActions(),
        ),
        _buildAnimatedChild(
          !state.hasFocusOnTitleOrDescription,
          const SizedBox(height: Dimension.padding),
        ),
        _buildAnimatedChild(
          state.hasFocusOnTitleOrDescription,
          _buildActionsForFocusNodes(state),
        ),
        if (state.hasFocusOnTitleOrDescription) const SizedBox(height: Dimension.padding),
        if (state.hasFocusOnTitleOrDescription) const Separator(),
        Flexible(
          child: _buildContent(state),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () => onBack(state),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimension.radius),
              topRight: Radius.circular(Dimension.radius),
            ),
            child: Material(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: MediaQuery.of(context).size.height - kToolbarHeight * 2,
                ),
                child: AnimatedSize(
                  curve: Curves.linear,
                  duration: const Duration(milliseconds: 200),
                  reverseDuration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    height: state.hasFocusOnTitleOrDescription
                        ? MediaQuery.of(context).size.height -
                            (kToolbarHeight * 2) +
                            MediaQuery.of(context).viewInsets.bottom
                        : null,
                    child: state.hasFocusOnTitleOrDescription
                        ? Scaffold(
                            backgroundColor: Colors.transparent.withOpacity(0),
                            resizeToAvoidBottomInset: true,
                            body: body(state),
                          )
                        : body(state),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
