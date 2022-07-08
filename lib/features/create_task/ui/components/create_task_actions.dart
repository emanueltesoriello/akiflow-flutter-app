import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/extensions/date_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

import '../../../../assets.dart';
import '../../../../components/base/tagbox.dart';
import '../../../../components/task/plan_for_action.dart';
import '../../../../style/colors.dart';
import '../../../../utils/interactive_webview.dart';
import '../../../../utils/task_extension.dart';
import '../../../edit_task/cubit/edit_task_cubit.dart';
import '../../../edit_task/ui/actions/plan_modal.dart';
import '../../../label/cubit/labels_cubit.dart';
import '../../../main/ui/chrono_model.dart';

class CreateTaskActions extends StatelessWidget {
  const CreateTaskActions({Key? key, required this.titleController, required this.titleFocus, required this.callback})
      : super(key: key);
  final TextEditingController titleController;
  final FocusNode titleFocus;
  final void Function(List<ChronoModel>?) callback;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Wrap(
        runSpacing: 8,
        children: [
          PlanForAction(
            task: context.watch<EditTaskCubit>().state.updatedTask,
            onTap: () {
              var editTaskCubit = context.read<EditTaskCubit>();
    
              editTaskCubit.planTap();
    
              showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => PlanModal(
                  initialDate: editTaskCubit.state.updatedTask.date != null
                      ? DateTime.parse(editTaskCubit.state.updatedTask.date!)
                      : DateTime.now(),
                  initialDatetime: editTaskCubit.state.updatedTask.datetime != null
                      ? DateTime.parse(editTaskCubit.state.updatedTask.datetime!)
                      : null,
                  taskStatusType: editTaskCubit.state.updatedTask.statusType ?? TaskStatusType.inbox,
                  onSelectDate: (
                      {required DateTime? date, required DateTime? datetime, required TaskStatusType statusType}) async {
                    editTaskCubit.planFor(date, dateTime: datetime, statusType: statusType);
    
                    if (date != null) {
                      String shortDate = date.shortDateFormatted;
                      String? shortTime = datetime?.timeFormatted;
    
                      titleController.text += shortDate;
    
                      if (shortTime != null) {
                        titleController.text += shortTime;
                      }
                    }
                    titleFocus.requestFocus();
                    List<ChronoModel>? chronoParsed = await InteractiveWebView.chronoParse(titleController.text);
                    callback(chronoParsed);
                  },
                  setForInbox: () {
                    editTaskCubit.planFor(null, dateTime: null, statusType: TaskStatusType.inbox);
                  },
                  setForSomeday: () {
                    editTaskCubit.planFor(null, dateTime: null, statusType: TaskStatusType.someday);
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          BlocBuilder<EditTaskCubit, EditTaskCubitState>(
            builder: (context, state) {
              Task task = state.updatedTask;
    
              String? text;
    
              if (task.duration != null && task.duration != 0) {
                int seconds = task.duration!;
    
                double hours = seconds / 3600;
                double minutes = (hours - hours.floor()) * 60;
    
                if (minutes.floor() == 0) {
                  text = '${hours.floor()}h';
                } else if (hours.floor() == 0) {
                  text = '${minutes.floor()}m';
                } else {
                  text = '${hours.floor()}h ${minutes.floor()}m';
                }
              }
    
              return TagBox(
                icon: "assets/images/icons/_common/hourglass.svg",
                active: task.duration != null && task.duration != 0,
                backgroundColor:
                    task.duration != null && task.duration != 0 ? ColorsExt.grey6(context) : ColorsExt.grey7(context),
                isSquare: task.duration != null && task.duration != 0 ? false : true,
                isBig: true,
                text: text,
                onPressed: () {
                  context.read<EditTaskCubit>().toggleDuration();
                },
              );
            },
          ),
          const SizedBox(width: 8),
          BlocBuilder<EditTaskCubit, EditTaskCubitState>(
            builder: (context, state) {
              Color? background;
    
              List<Label> labels = context.read<LabelsCubit>().state.labels;
    
              Label? label;
    
              try {
                label = labels.firstWhere((label) => state.updatedTask.listId!.contains(label.id!));
              } catch (_) {}
    
              if (label?.color != null) {
                background = ColorsExt.getFromName(label!.color!);
              }
    
              return TagBox(
                icon: Assets.images.icons.common.numberSVG,
                active: background != null,
                iconColor: background ?? ColorsExt.grey2(context),
                backgroundColor: background != null ? background.withOpacity(0.1) : ColorsExt.grey7(context),
                text: label?.title ?? t.addTask.label,
                isBig: true,
                onPressed: () {
                  context.read<EditTaskCubit>().toggleLabels();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
