import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/button_iconed.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/doc_extension.dart';
import 'package:mobile/utils/string_ext.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/doc/doc.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

class TaskRow extends StatelessWidget {
  final Task task;
  final Function() completed;

  const TaskRow({
    Key? key,
    required this.task,
    required this.completed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              completed();
            },
            child: SvgPicture.asset(
              "assets/images/icons/_common/square.svg",
              width: 20,
              height: 20,
              color: ColorsExt.grey3(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? "",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _secondLine(context),
                Wrap(
                  spacing: 4,
                  children: [
                    _status(context),
                    _label(context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _status(BuildContext context) {
    if (task.statusType == null) {
      return const SizedBox();
    }

    String text = task.statusType!.name;
    Color color;

    switch (task.statusType) {
      case TaskStatusType.someday:
      case TaskStatusType.snoozed:
        color = ColorsExt.akiflow10(context);
        break;
      case TaskStatusType.completed:
        color = ColorsExt.green20(context);
        break;
      case TaskStatusType.deleted:
      case TaskStatusType.permanentlyDeleted:
        color = ColorsExt.grey6(context);
        break;
      default:
        color = ColorsExt.cyan25(context);
    }

    return Column(
      children: [
        const SizedBox(height: 10.5),
        ButtonIconed(
          icon: "assets/images/icons/_common/number.svg",
          text: text.capitalizeFirstCharacter(),
          backgroundColor: color,
          onPressed: () {
            // TODO status click
          },
        ),
      ],
    );
  }

  Widget _label(BuildContext context) {
    if (task.listId == null || task.listId!.isEmpty) {
      return const SizedBox();
    }

    List<Label> labels = context.watch<TasksCubit>().state.labels;

    if (labels.isEmpty) {
      return const SizedBox();
    }

    Label label = labels.firstWhere(
      (label) => task.listId!.contains(label.id!),
    );

    return Column(
      children: [
        const SizedBox(height: 10.5),
        ButtonIconed(
          icon: "assets/images/icons/_common/number.svg",
          text: label.title,
          backgroundColor: label.color != null
              ? ColorsExt.getFromName(label.color!).withOpacity(0.1)
              : null,
          iconColor: label.color != null
              ? ColorsExt.getFromName(label.color!)
              : ColorsExt.grey3(context),
          onPressed: () {
            // TODO label click
          },
        ),
      ],
    );
  }

  Widget _secondLine(BuildContext context) {
    List<Doc> docs = context.watch<TasksCubit>().state.docs;

    int index = docs.indexWhere(
      (doc) => doc.taskId == task.id,
    );

    if ((task.description == null || task.description!.isEmpty) &&
        index == -1) {
      return const SizedBox();
    }
    return Column(
      children: [
        const SizedBox(height: 4),
        Builder(builder: (context) {
          if (index != -1) {
            return Row(
              children: [
                SvgPicture.asset(
                  docs[index].computedIcon,
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 7),
                Text(
                  t.task.linkedContent,
                  style:
                      TextStyle(fontSize: 15, color: ColorsExt.grey3(context)),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                SvgPicture.asset(
                  "assets/images/icons/_common/arrow_turn_down_right.svg",
                  color: ColorsExt.grey3(context),
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 4.5),
                Text(
                  t.task.description,
                  style:
                      TextStyle(fontSize: 15, color: ColorsExt.grey3(context)),
                ),
              ],
            );
          }
        }),
      ],
    );
  }
}
