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

  initFocusNodeListener() {
    EditTaskCubit cubit = context.read<EditTaskCubit>();
    _titleFocusNode.addListener(() {
      print('Focus on title');
      Future.delayed(const Duration(milliseconds: 0), () => cubit.setHasFocusOnTitleOrDescription(true));
    });
    _descriptionFocusNode.addListener(() {
      print('Focus on description');
      Future.delayed(const Duration(milliseconds: 0), () => cubit.setHasFocusOnTitleOrDescription(true));
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

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  _actionsForFocusNodes(EditTaskCubitState state) {
    EditTaskCubit cubit = context.read<EditTaskCubit>();

    return Container(
      padding: const EdgeInsets.only(left: Dimension.paddingS, right: Dimension.paddingS),
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () {
              onBack(state);
            },
            icon: Icon(Icons.arrow_back, size: 16, color: ColorsExt.grey3(context)),
            label: Text(
              'Edit task',
              style: Theme.of(context).textTheme.button?.copyWith(color: ColorsExt.grey3(context)),
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
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Discard changes?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: ColorsExt.grey1(context))),
                const SizedBox(height: 10),
                Text('The changes you’ve made won’t be saved',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        ?.copyWith(color: ColorsExt.grey2_5(context), fontWeight: FontWeight.normal)),
                const SizedBox(height: Dimension.paddingS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 85,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: ColorsExt.grey6(context),
                            onPrimary: ColorsExt.grey5(context),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Dimension.radiusS),
                            ),
                          ),
                          child: Text('Cancel',
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: ColorsExt.grey1(context))),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimension.padding),
                    TextButton(
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
                      child: Text('Discard',
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: ColorsExt.grey1(context))),
                    )
                  ],
                )
              ],
            ));
          });
      return false;
    } else {
      Navigator.of(context).pop(true);
      return true;
    }
  }

  Widget animatedChild(bool showWidget, Widget child) {
    Widget animatedChild = Container();
    return AnimatedSwitcher(duration: const Duration(milliseconds: 2000), child: showWidget ? child : animatedChild);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () => onBack(state),
          child: Material(
              color: Theme.of(context).backgroundColor,
              child: AnimatedSize(
                curve: Curves.elasticOut,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  height: state.hasFocusOnTitleOrDescription ? MediaQuery.of(context).size.height / 2 : null,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Dimension.radiusM),
                      topRight: Radius.circular(Dimension.radiusM),
                    ),
                  ),
                  margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: ScrollConfiguration(
                    behavior: NoScrollBehav(),
                    child: ListView(
                      shrinkWrap: true,
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
