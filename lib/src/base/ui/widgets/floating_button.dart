import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/widgets/expandable_fab.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:mobile/src/home/ui/cubit/today/today_cubit.dart';
import 'package:mobile/src/label/ui/cubit/labels_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/create_task/create_task_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';

import '../../../../common/style/colors.dart';
import '../../../../extensions/task_extension.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton({Key? key, required this.bottomBarHeight}) : super(key: key);
  final double bottomBarHeight;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        HomeViewType homeViewType = context.read<MainCubit>().state.homeViewType;
        if (homeViewType == HomeViewType.availability) {
          return Container();
        } else if (homeViewType == HomeViewType.calendar) {
          GlobalKey<ExpandableFabState> fabKey = GlobalKey();
          return ExpandableFab(
            key: fabKey,
            distance: 70.0,
            children: [
              FabActionButton(
                icon: Assets.images.icons.common.checkDoneOutlineSVG,
                title: 'Task',
                onTap: () async {
                  _onTapTask(context: context, homeViewType: homeViewType);
                  fabKey.currentState!.toggle();
                },
              ),
              FabActionButton(
                icon: Assets.images.icons.common.daySVG,
                title: 'Event',
                onTap: () async {
                  _onTapEvent(context);
                  fabKey.currentState!.toggle();
                },
              ),
            ],
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(
                bottom: (state.queue.isNotEmpty || state.justCreatedTask != null) ? bottomBarHeight : 0),
            child: SizedBox(
              width: 52,
              height: 52,
              child: FloatingActionButton(
                onPressed: () async {
                  _onTapTask(context: context, homeViewType: homeViewType);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SvgPicture.asset(
                  Assets.images.icons.common.plusSVG,
                  color: ColorsExt.background(context),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  _onTapTask({required BuildContext context, required HomeViewType homeViewType}) {
    TaskStatusType taskStatusType;
    if (homeViewType == HomeViewType.inbox || homeViewType == HomeViewType.label) {
      taskStatusType = TaskStatusType.inbox;
    } else {
      taskStatusType = TaskStatusType.planned;
    }
    DateTime date = context.read<TodayCubit>().state.selectedDate;

    String? startTimeRounded;
    int duration = 1800;
    if (homeViewType == HomeViewType.calendar) {
      DateTime now = DateTime.now();
      startTimeRounded =
          DateTime(now.year, now.month, now.day, now.hour, [0, 15, 30, 45, 60][(now.minute / 15).round()])
              .toUtc()
              .toIso8601String();

      AuthCubit authCubit = context.read<AuthCubit>();
      if (authCubit.state.user != null &&
          authCubit.state.user?.settings != null &&
          authCubit.state.user?.settings?['tasks'] != null) {
        duration = authCubit.state.user?.settings?['tasks']?['defaultTasksDuration'] ?? 1800;
      }
    }

    Label? label = context.read<LabelsCubit>().state.selectedLabel;

    EditTaskCubit editTaskCubit = context.read<EditTaskCubit>();

    Task task = editTaskCubit.state.updatedTask.copyWith(
      status: Nullable(taskStatusType.id),
      date: (taskStatusType == TaskStatusType.inbox || homeViewType == HomeViewType.label)
          ? Nullable(null)
          : Nullable(date.toIso8601String()),
      datetime: homeViewType == HomeViewType.calendar ? Nullable(startTimeRounded) : Nullable(null),
      duration: homeViewType == HomeViewType.calendar ? Nullable(duration) : Nullable(null),
      listId: Nullable(label?.id),
    );

    editTaskCubit.attachTask(task);

    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => const CreateTaskModal(),
    );
  }

  _onTapEvent(BuildContext context) {
    context.read<EventsCubit>().createEvent(context);
  }
}
