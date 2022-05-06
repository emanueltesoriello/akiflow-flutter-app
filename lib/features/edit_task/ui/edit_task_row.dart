import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/aki_chip.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/actions/labels_modal.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/string_ext.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

class EditTaskRow extends StatefulWidget {
  const EditTaskRow({
    Key? key,
  }) : super(key: key);

  @override
  State<EditTaskRow> createState() => _EditTaskRowState();
}

class _EditTaskRowState extends State<EditTaskRow> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    _titleController.text =
        context.read<EditTaskCubit>().state.newTask.title ?? '';
    _descriptionController.text =
        context.read<EditTaskCubit>().state.newTask.description ?? '';
    super.initState();
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

  TextField _description(BuildContext context) {
    return TextField(
      controller: _descriptionController,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        isDense: true,
        hintText: t.addTask.descriptionHint,
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: ColorsExt.grey3(context),
          fontSize: 17,
        ),
      ),
      style: TextStyle(
        color: ColorsExt.grey2(context),
        fontSize: 17,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _thirdLine(BuildContext context) {
    Task task = context.watch<EditTaskCubit>().state.newTask;

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
    );
  }

  InkWell _checkbox(BuildContext context) {
    Task task = context.watch<EditTaskCubit>().state.newTask;

    return InkWell(
      onTap: () {
        context.read<EditTaskCubit>().markAsDone(task);
      },
      child: Builder(builder: (context) {
        bool completed = task.isCompletedComputed;

        return SvgPicture.asset(
          completed
              ? "assets/images/icons/_common/Check-done.svg"
              : "assets/images/icons/_common/Check-empty.svg",
          width: 20,
          height: 20,
          color:
              completed ? ColorsExt.grey2(context) : ColorsExt.grey3(context),
        );
      }),
    );
  }

  Widget _status(BuildContext context) {
    Task task = context.watch<EditTaskCubit>().state.newTask;

    void statusClick() {
      print(task.status);
    }

    if (task.deletedAt != null ||
        task.statusType == TaskStatusType.deleted ||
        task.statusType == TaskStatusType.permanentlyDeleted) {
      return AkiChip(
        icon: "assets/images/icons/_common/trash.svg",
        backgroundColor: ColorsExt.grey6(context),
        text: task.statusType!.name.capitalizeFirstCharacter(),
        onPressed: statusClick,
        foregroundColor: ColorsExt.grey3(context),
      );
    }

    if (task.isCompletedComputed) {
      return const SizedBox();
    }

    if (task.isOverdue) {
      return AkiChip(
        backgroundColor: ColorsExt.cyan25(context),
        text: task.overdueFormatted,
        onPressed: statusClick,
      );
    }

    switch (task.statusType) {
      case TaskStatusType.someday:
        return AkiChip(
          icon: "assets/images/icons/_common/archivebox.svg",
          backgroundColor: ColorsExt.akiflow10(context),
          text: task.statusType!.name.capitalizeFirstCharacter(),
          onPressed: statusClick,
        );
      case TaskStatusType.snoozed:
        return AkiChip(
          icon: "assets/images/icons/_common/clock.svg",
          backgroundColor: ColorsExt.pink30(context),
          text: task.datetimeFormatted,
          onPressed: statusClick,
        );
      case TaskStatusType.planned:
        return AkiChip(
          backgroundColor: ColorsExt.cyan25(context),
          text: task.shortDate,
          onPressed: statusClick,
        );
      default:
        return AkiChip(
          backgroundColor: ColorsExt.cyan25(context),
          text: task.statusType!.name.capitalizeFirstCharacter(),
          onPressed: statusClick,
        );
    }
  }

  Widget _label(BuildContext context) {
    Task task = context.watch<EditTaskCubit>().state.newTask;

    List<Label> labels = context.watch<TasksCubit>().state.labels;

    Label? label;

    if (task.listId != null) {
      label = labels.firstWhereOrNull(
        (label) => task.listId!.contains(label.id!),
      );
    }

    return AkiChip(
      icon: "assets/images/icons/_common/number.svg",
      text: label?.title ?? t.editTask.noLabel,
      backgroundColor: label?.color != null
          ? ColorsExt.getFromName(label!.color!).withOpacity(0.1)
          : ColorsExt.grey6(context),
      iconColor: label?.color != null
          ? ColorsExt.getFromName(label!.color!)
          : ColorsExt.grey3(context),
      onPressed: () {
        var cubit = context.read<EditTaskCubit>();

        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => LabelsModal(
            selectLabel: (Label label) {
              cubit.setLabel(label);
            },
          ),
        );
      },
    );
  }
}
