import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/tagbox.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/actions/labels_modal.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/quill_converter.dart';
import 'package:mobile/utils/string_ext.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EditTaskRow extends StatefulWidget {
  const EditTaskRow({
    Key? key,
  }) : super(key: key);

  @override
  State<EditTaskRow> createState() => _EditTaskRowState();
}

class _EditTaskRowState extends State<EditTaskRow> {
  final TextEditingController _titleController = TextEditingController();

  late QuillController quillController;
  WebViewController? wController;
  StreamSubscription? streamSubscription;

  @override
  void initState() {
    EditTaskCubit cubit = context.read<EditTaskCubit>();

    _titleController.text = cubit.state.updatedTask.title ?? '';

    quillController = QuillController(document: Document(), selection: const TextSelection.collapsed(offset: 0));

    initDescription().whenComplete(() {
      streamSubscription = quillController.changes.listen((change) async {
        List<dynamic> delta = quillController.document.toDelta().toJson();

        String html = await QuillConverter.deltaToHtml(delta);

        cubit.updateDescription(html);
      });
    });

    super.initState();
  }

  Future initDescription() async {
    EditTaskCubit cubit = context.read<EditTaskCubit>();

    String html = cubit.state.updatedTask.description ?? '';

    Document document = await QuillConverter.htmlToDelta(html);

    setState(() {
      quillController = QuillController(document: document, selection: const TextSelection.collapsed(offset: 0));
    });
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _checkbox(context),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _firstLine(context),
                const SizedBox(height: 8),
                _description(context),
                const SizedBox(height: 32),
                _thirdLine(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _description(BuildContext context) {
    return Theme(
      data: Theme.of(context)
          .copyWith(textSelectionTheme: TextSelectionThemeData(cursorColor: ColorsExt.akiflow(context))),
      child: QuillEditor(
        controller: quillController,
        readOnly: false,
        scrollController: ScrollController(),
        scrollable: true,
        focusNode: FocusNode(),
        autoFocus: false,
        expands: false,
        padding: EdgeInsets.zero,
        keyboardAppearance: Brightness.light,
      ),
    );
  }

  Widget _thirdLine(BuildContext context) {
    Task task = context.watch<EditTaskCubit>().state.updatedTask;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Builder(builder: (context) {
          if (task.statusType == null) {
            return const SizedBox();
          }
          if (task.statusType == TaskStatusType.inbox) {
            return const SizedBox();
          }

          return _status(context);
        }),
        _label(context),
      ],
    );
  }

  Widget _firstLine(BuildContext context) {
    return TextField(
      controller: _titleController,
      maxLines: null,
      textCapitalization: TextCapitalization.sentences,
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
      onChanged: (value) {
        context.read<EditTaskCubit>().onTitleChanged(value);
      },
    );
  }

  InkWell _checkbox(BuildContext context) {
    Task task = context.watch<EditTaskCubit>().state.updatedTask;

    return InkWell(
      onTap: () {
        context.read<EditTaskCubit>().markAsDone();
      },
      child: Builder(builder: (context) {
        bool completed = task.isCompletedComputed;

        return SvgPicture.asset(
          completed ? "assets/images/icons/_common/Check-done.svg" : "assets/images/icons/_common/Check-empty.svg",
          width: 20,
          height: 20,
          color: completed ? ColorsExt.green(context) : ColorsExt.grey3(context),
        );
      }),
    );
  }

  Widget _status(BuildContext context) {
    Task task = context.watch<EditTaskCubit>().state.updatedTask;

    if (task.deletedAt != null ||
        task.statusType == TaskStatusType.deleted ||
        task.statusType == TaskStatusType.permanentlyDeleted) {
      return TagBox(
        icon: "assets/images/icons/_common/trash.svg",
        backgroundColor: ColorsExt.grey6(context),
        active: true,
        text: task.statusType!.name.capitalizeFirstCharacter(),
        foregroundColor: ColorsExt.grey3(context),
      );
    }

    if (task.isCompletedComputed) {
      return const SizedBox();
    }

    if (task.isOverdue) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/images/icons/_common/Clock_alert.svg",
            width: 20,
            height: 20,
            color: ColorsExt.red(context),
          ),
          const SizedBox(width: 4),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _label(BuildContext context) {
    Task task = context.watch<EditTaskCubit>().state.updatedTask;

    List<Label> labels = context.watch<LabelsCubit>().state.labels;

    Label? label;

    if (task.listId != null) {
      label = labels.firstWhereOrNull(
        (label) => task.listId!.contains(label.id!),
      );
    }

    return TagBox(
      icon: "assets/images/icons/_common/number.svg",
      text: label?.title ?? t.editTask.noLabel,
      backgroundColor:
          label?.color != null ? ColorsExt.getFromName(label!.color!).withOpacity(0.1) : ColorsExt.grey6(context),
      iconColor: label?.color != null ? ColorsExt.getFromName(label!.color!) : ColorsExt.grey3(context),
      active: label?.color != null,
      onPressed: () {
        var cubit = context.read<EditTaskCubit>();

        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => LabelsModal(
            selectLabel: (Label label) {
              cubit.setLabel(label);
              Navigator.pop(context);
            },
            showNoLabel: task.listId != null,
          ),
        );
      },
    );
  }
}
