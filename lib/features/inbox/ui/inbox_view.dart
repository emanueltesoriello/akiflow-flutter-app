import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/task/notice.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/features/inbox/cubit/inbox_view_cubit.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:models/task/task.dart';

class InboxView extends StatelessWidget {
  const InboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => InboxCubit(), child: const _View());
  }
}

class _View extends StatelessWidget {
  const _View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, tasksState) {
        List<Task> tasks = List.from(tasksState.inboxTasks);

        return BlocBuilder<InboxCubit, InboxCubitState>(
          builder: (context, state) {
            if (tasksState.tasksLoaded && tasks.isEmpty) {
              return const HomeViewPlaceholder();
            }

            return TaskList(
              tasks: tasks,
              hideInboxLabel: true,
              sorting: TaskListSorting.ascending,
              showLabel: true,
              showPlanInfo: false,
              notice: () {
                if (!state.showInboxNotice) {
                  return null;
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Notice(
                    title: t.notice.inboxTitle,
                    subtitle: t.notice.inboxSubtitle,
                    icon: Icons.info_outline,
                    onClose: () {
                      context.read<InboxCubit>().inboxNoticeClosed();
                    },
                  ),
                );
              }(),
            );
          },
        );
      },
    );
  }
}

class HomeViewPlaceholder extends StatelessWidget {
  const HomeViewPlaceholder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/akiflow/inbox-nice.svg",
            width: 80.81,
            height: 97.72,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  t.task.awesomeInboxZero,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () {
              context.read<MainCubit>().changeHomeView(HomeViewType.today);
            },
            child: Container(
              width: 114,
              height: 36,
              decoration: BoxDecoration(
                color: ColorsExt.grey6(context),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: ColorsExt.grey4(context),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  t.calendar.goToToday,
                  style: TextStyle(
                    fontSize: 17,
                    color: ColorsExt.grey2(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
