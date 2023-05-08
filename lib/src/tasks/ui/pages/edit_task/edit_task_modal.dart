import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/no_scroll_behav.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/base/ui/widgets/interactive_webview.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/create_task/create_task_duration.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_bottom_actions.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_linked_content.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_links.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_row.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_top_actions.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/material.dart';

class EditTaskModal extends StatefulWidget {
  const EditTaskModal({Key? key}) : super(key: key);

  @override
  State<EditTaskModal> createState() => _EditTaskModalState();
}

class _EditTaskModalState extends State<EditTaskModal> {
  final TextEditingController _titleController = TextEditingController();
  ValueNotifier<quill.QuillController> quillController = ValueNotifier<quill.QuillController>(
      quill.QuillController(document: quill.Document(), selection: const TextSelection.collapsed(offset: 0)));

  WebViewController? wController;
  StreamSubscription? streamSubscription;

  FocusNode _descriptionFocusNode = FocusNode();
  FocusNode _titleFocusNode = FocusNode();

  @override
  void initState() {
    _init(isFirstInit: true);
    super.initState();
  }

  _init({bool isFirstInit = false}) {
    EditTaskCubit cubit = context.read<EditTaskCubit>();
    context.read<EditTaskCubit>().setRead();
    if (isFirstInit) {
      _titleController.text = cubit.state.updatedTask.title ?? '';
    } else {
      _titleController.text = cubit.state.originalTask.title ?? '';
    }

    initFocusNodeListener();
    initDescription(isFirstInit: isFirstInit).whenComplete(() {
      streamSubscription = quillController.value.changes.listen((change) async {
        List<dynamic> delta = quillController.value.document.toDelta().toJson();
        String html = await InteractiveWebView.deltaToHtml(delta);
        cubit.updateDescription(html);
      });
    });
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  initFocusNodeListener() {
    EditTaskCubit cubit = context.read<EditTaskCubit>();
    _titleFocusNode.addListener(() {
      print('Focus on title');
      if (_titleFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 0), () {
          //SystemChannels.textInput.invokeMethod('TextInput.show');

          cubit.setHasFocusOnTitleOrDescription(true);
        });
      }
    });
    _descriptionFocusNode.addListener(() {
      print('Focus on description');
      if (_descriptionFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 0), () {
          //SystemChannels.textInput.invokeMethod('TextInput.show');

          cubit.setHasFocusOnTitleOrDescription(true);
        });
      }
    });
  }

  Future initDescription({bool isFirstInit = false}) async {
    EditTaskCubit cubit = context.read<EditTaskCubit>();
    String html;
    if (isFirstInit) {
      html = cubit.state.updatedTask.description ?? '';
    } else {
      html = cubit.state.originalTask.description ?? '';
    }
    quill.Document document = await InteractiveWebView.htmlToDelta(html);
    quillController.value =
        quill.QuillController(document: document, selection: const TextSelection.collapsed(offset: 0));
    quillController.value.moveCursorToEnd();
  }

  _actionsForFocusNodes(EditTaskCubitState state) {
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
              style: Theme.of(context).textTheme.button?.copyWith(color: ColorsExt.grey600(context)),
            ),
          ),
          TextButton(
            onPressed: () => cubit.setHasFocusOnTitleOrDescription(false),
            child: Text(
              'SAVE',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontWeight: FontWeight.w500, color: ColorsExt.akiflow(context)),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> onBack(EditTaskCubitState state) async {
    EditTaskCubit cubit = context.read<EditTaskCubit>();
    if (state.hasFocusOnTitleOrDescription) {
      if (cubit.state.originalTask == cubit.state.updatedTask) {
        cubit.setHasFocusOnTitleOrDescription(false);
        FocusScope.of(context).unfocus();
      } else {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  shape:
                      const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Dimension.radiusM))),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Discard changes?',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: ColorsExt.grey900(context))),
                      const SizedBox(height: Dimension.paddingM),
                      Text('The changes you’ve made won’t be saved',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
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
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'.toUpperCase(),
                                style:
                                    Theme.of(context).textTheme.bodyText1?.copyWith(color: ColorsExt.grey900(context))),
                          ),
                          const SizedBox(width: Dimension.padding),
                          TextButton(
                            style: Theme.of(context)
                                .textButtonTheme
                                .style
                                ?.copyWith(overlayColor: MaterialStateProperty.all(ColorsExt.grey200(context))),
                            onPressed: () async {
                              streamSubscription?.cancel();
                              quillController = ValueNotifier<quill.QuillController>(quill.QuillController(
                                  document: quill.Document(), selection: const TextSelection.collapsed(offset: 0)));
                              _init();
                              cubit.undoChanges();
                              cubit.setHasFocusOnTitleOrDescription(false);
                              FocusScope.of(context).unfocus();
                              Navigator.of(context).pop();
                            },
                            child: Text('Discard'.toUpperCase(),
                                style:
                                    Theme.of(context).textTheme.bodyText1?.copyWith(color: ColorsExt.grey900(context))),
                          )
                        ],
                      )
                    ],
                  ));
            });
      }

      return false;
    } else {
      Navigator.of(context).pop(true);
      return true;
    }
  }

  Widget animatedChild(bool showWidget, Widget child) {
    Widget animatedChild = Container();

    return AnimatedSwitcher(
        reverseDuration: const Duration(milliseconds: 300),
        duration: const Duration(milliseconds: 300),
        child: showWidget ? child : animatedChild);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () => onBack(state),
          child: Material(
              color: Colors.transparent,
              child: AnimatedSize(
                curve: Curves.linear,
                duration: const Duration(milliseconds: 200),
                reverseDuration: const Duration(milliseconds: 200),
                child: Container(
                  height: state.hasFocusOnTitleOrDescription
                      ? MediaQuery.of(context).size.height -
                          (kToolbarHeight * 2) -
                          MediaQuery.of(context).viewInsets.bottom
                      : null,
                  decoration: BoxDecoration(
                    color: ColorsExt.background(context),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(Dimension.radius),
                      topRight: Radius.circular(Dimension.radius),
                    ),
                  ),
                  margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: ScrollConfiguration(
                    behavior: NoScrollBehav(),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: Dimension.padding),
                        animatedChild(!state.hasFocusOnTitleOrDescription, const ScrollChip()),
                        animatedChild(!state.hasFocusOnTitleOrDescription, const SizedBox(height: 12)),
                        animatedChild(!state.hasFocusOnTitleOrDescription,
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
                        )),
                        Column(
                          children: [
                            animatedChild(!state.hasFocusOnTitleOrDescription, const EditTaskTopActions()),
                            animatedChild(!state.hasFocusOnTitleOrDescription, const SizedBox(height: 12)),
                            animatedChild(state.hasFocusOnTitleOrDescription, _actionsForFocusNodes(state)),
                            if (state.hasFocusOnTitleOrDescription) const SizedBox(height: 10),
                            if (state.hasFocusOnTitleOrDescription) const Separator(),
                            if (state.hasFocusOnTitleOrDescription) const SizedBox(height: 15),
                            EditTaskRow(
                              key: const GlobalObjectKey('EditTaskRow'),
                              quillController: quillController,
                              titleController: _titleController,
                              descriptionFocusNode: _descriptionFocusNode,
                              titleFocusNode: _titleFocusNode,
                            ),
                            if (!state.hasFocusOnTitleOrDescription) const SizedBox(height: 12),
                            if (!state.hasFocusOnTitleOrDescription) const Separator(),
                            if (!state.hasFocusOnTitleOrDescription) const EditTaskLinkedContent(),
                            if (!state.hasFocusOnTitleOrDescription) const EditTaskLinks(),
                            if (!state.hasFocusOnTitleOrDescription) const EditTaskBottomActions(),
                            if (!state.hasFocusOnTitleOrDescription) const Separator(),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )),
        );
      },
    );
  }
}
