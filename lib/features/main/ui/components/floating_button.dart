import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';
import '../../../../style/colors.dart';
import '../../../../utils/task_extension.dart';
import '../../../create_task/ui/create_task_modal.dart';
import '../../../edit_task/cubit/edit_task_cubit.dart';
import '../../../label/cubit/labels_cubit.dart';
import '../../../tasks/tasks_cubit.dart';
import '../../../today/cubit/today_cubit.dart';
import '../../cubit/main_cubit.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton({Key? key, required this.bottomBarHeight}) : super(key: key);
  final double bottomBarHeight;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: (state.queue.isNotEmpty || state.justCreatedTask != null) ? bottomBarHeight : 0),
          child: SizedBox(
            width: 52,
            height: 52,
            child: FloatingActionButton(
              onPressed: () async {
                HomeViewType homeViewType = context.read<MainCubit>().state.homeViewType;
                TaskStatusType taskStatusType;
                if (homeViewType == HomeViewType.inbox || homeViewType == HomeViewType.label) {
                  taskStatusType = TaskStatusType.inbox;
                } else {
                  taskStatusType = TaskStatusType.planned;
                }
                DateTime date = context.read<TodayCubit>().state.selectedDate;

                Label? label = context.read<LabelsCubit>().state.selectedLabel;

                EditTaskCubit editTaskCubit = context.read<EditTaskCubit>();

                Task task = editTaskCubit.state.updatedTask.copyWith(
                  status: Nullable(taskStatusType.id),
                  date: (taskStatusType == TaskStatusType.inbox || homeViewType == HomeViewType.label)
                      ? Nullable(null)
                      : Nullable(date.toIso8601String()),
                  listId: Nullable(label?.id),
                );

                editTaskCubit.attachTask(task);

                await showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) => SingleChildScrollView(
                    controller: ModalScrollController.of(context),
                    child: const CreateTaskModal(),
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SvgPicture.asset(
                "assets/images/icons/_common/plus.svg",
                color: ColorsExt.background(context),
              ),
            ),
          ),
        );
      },
    );
  }
}
