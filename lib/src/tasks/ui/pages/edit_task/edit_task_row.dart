import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/tagbox.dart';
import 'package:mobile/extensions/string_extension.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/label/ui/cubit/labels_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/labels_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:url_launcher/url_launcher.dart';

class EditTaskRow extends StatefulWidget {
  final TextEditingController titleController;
  final ValueNotifier<QuillController> quillController;
  final FocusNode descriptionFocusNode;
  final FocusNode titleFocusNode;

  const EditTaskRow({
    Key? key,
    required this.titleController,
    required this.quillController,
    required this.descriptionFocusNode,
    required this.titleFocusNode,
  }) : super(key: key);

  @override
  State<EditTaskRow> createState() => _EditTaskRowState();
}

class _EditTaskRowState extends State<EditTaskRow> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: _checkbox(context),
              ),
              const SizedBox(width: Dimension.paddingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _firstLine(context),
                    const SizedBox(height: Dimension.paddingS),
                    _description(context),
                    const SizedBox(height: Dimension.paddingM),
                    if (!state.hasFocusOnTitleOrDescription) _thirdLine(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _description(BuildContext context) {
    return ValueListenableBuilder<QuillController>(
      valueListenable: widget.quillController,
      builder: (context, value, child) => Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: ColorsExt.akiflow500(context)!.withOpacity(0.1),
          ),
        ),
        child: GestureDetector(
          onTap: () async {
            if (!widget.descriptionFocusNode.hasFocus && !widget.titleFocusNode.hasFocus) {
              widget.descriptionFocusNode.unfocus();
              context.read<EditTaskCubit>().setHasFocusOnTitleOrDescription(true);
              await Future.delayed(const Duration(milliseconds: 500));
              FocusScope.of(context).requestFocus(widget.descriptionFocusNode);
            } else {
              FocusScope.of(context).requestFocus(widget.descriptionFocusNode);
            }
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                QuillToolbar.basic(controller: value),
                QuillEditor(
                  controller: value,
                  readOnly: false,
                  enableSelectionToolbar: true,
                  scrollController: ScrollController(),
                  scrollable: true,
                  focusNode: widget.descriptionFocusNode,
                  autoFocus: false,
                  expands: false,
                  padding: EdgeInsets.zero,
                  keyboardAppearance: Brightness.light,
                  placeholder: t.task.description,
                  linkActionPickerDelegate: (BuildContext context, String link, node) async {
                    launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
                    return LinkMenuAction.none;
                  },
                  customStyles: DefaultStyles(
                    placeHolder: DefaultTextBlockStyle(
                      const TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                      const VerticalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _thirdLine(BuildContext context) {
    final task = context.watch<EditTaskCubit>().state.updatedTask;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Builder(builder: (context) {
          if (task.statusType == null || task.statusType == TaskStatusType.inbox) {
            return const SizedBox();
          }

          return _status(context);
        }),
        _label(context),
      ],
    );
  }

  Widget _firstLine(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!widget.descriptionFocusNode.hasFocus && !widget.titleFocusNode.hasFocus) {
          widget.titleFocusNode.unfocus();
          context.read<EditTaskCubit>().setHasFocusOnTitleOrDescription(true);
          await Future.delayed(const Duration(milliseconds: 500));
          FocusScope.of(context).requestFocus(widget.titleFocusNode);
        } else {
          FocusScope.of(context).requestFocus(widget.titleFocusNode);
        }
      },
      child: TextField(
        controller: widget.titleController,
        maxLines: null,
        onTap: null,
        focusNode: widget.titleFocusNode,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          isDense: true,
          hintText: t.addTask.titleHint,
          border: InputBorder.none,
          hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorsExt.grey600(context),
              ),
        ),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorsExt.grey800(context),
            ),
        onChanged: (value) {
          context.read<EditTaskCubit>().onTitleChanged(value);
        },
      ),
    );
  }

  InkWell _checkbox(BuildContext context) {
    final task = context.watch<EditTaskCubit>().state.updatedTask;
    final hasFocusOnTitleOrDescription = context.watch<EditTaskCubit>().state.hasFocusOnTitleOrDescription;
    return InkWell(
      onTap: hasFocusOnTitleOrDescription
          ? null
          : () {
              HapticFeedback.heavyImpact();
              task.playTaskDoneSound();
              context.read<EditTaskCubit>().markAsDone();
              Navigator.of(context).pop();
            },
      child: Builder(builder: (context) {
        final completed = task.isCompletedComputed;

        return SvgPicture.asset(
          completed ? Assets.images.icons.common.checkDoneSVG : Assets.images.icons.common.checkEmptySVG,
          width: 22,
          height: 22,
          color: completed ? ColorsExt.yorkGreen400(context) : ColorsExt.grey600(context),
        );
      }),
    );
  }

  Widget _status(BuildContext context) {
    final task = context.watch<EditTaskCubit>().state.updatedTask;

    if (task.deletedAt != null ||
        task.statusType == TaskStatusType.deleted ||
        task.statusType == TaskStatusType.trashed) {
      return TagBox(
        icon: Assets.images.icons.common.trashSVG,
        backgroundColor: ColorsExt.grey100(context),
        active: true,
        text: task.statusType!.name.capitalizeFirstCharacter(),
        foregroundColor: ColorsExt.grey600(context),
      );
    }

    if (task.isCompletedComputed) {
      return const SizedBox();
    }

    return const SizedBox();
  }

  Widget _label(BuildContext context) {
    final editTaskCubit = context.read<EditTaskCubit>();
    final task = editTaskCubit.state.updatedTask;
    final labels = context.read<LabelsCubit>().state.labels;

    final label = task.listId != null
        ? labels.firstWhereOrNull(
            (label) => task.listId!.contains(label.id!),
          )
        : null;

    return TagBox(
      isBig: true,
      icon: Assets.images.icons.common.numberSVG,
      text: label?.title ?? t.editTask.addLabel,
      textColor: label?.title != null ? ColorsExt.grey800(context) : ColorsExt.grey600(context),
      backgroundColor:
          label?.color != null ? ColorsExt.getLightColorFromName(label!.color!) : ColorsExt.grey100(context),
      iconColor: label?.color != null ? ColorsExt.getFromName(label!.color!) : ColorsExt.grey600(context),
      active: label?.color != null,
      onPressed: () {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => LabelsModal(
            selectLabel: (Label label) {
              editTaskCubit.setLabel(label);
            },
            showNoLabel: task.listId != null,
          ),
        );
      },
    );
  }
}
