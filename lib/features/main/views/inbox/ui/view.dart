import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/notice.dart';
import 'package:mobile/components/inbox/task.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/main/views/inbox/cubit/view_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';

class InboxView extends StatelessWidget {
  const InboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => InboxCubit(), child: const _View());
  }
}

class _View extends StatelessWidget {
  const _View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Task> tasks = List.from(context.watch<TasksCubit>().state.tasks);

    tasks = TaskExt.filterInboxTasks(tasks);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<MainCubit>().syncClick();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return BlocBuilder<InboxCubit, InboxCubitState>(
              builder: (context, state) {
                return Visibility(
                  visible: state.showInboxNotice,
                  child: Notice(
                    title: t.notice.inbox_title,
                    subtitle: t.notice.inbox_subtitle,
                    icon: Icons.info_outline,
                    onClose: () {
                      context.read<InboxCubit>().inboxNoticeClosed();
                    },
                  ),
                );
              },
            );
          }

          index -= 1;

          Task task = tasks[index];

          return TaskRow(
            task: task,
            completed: () {
              context.read<TasksCubit>().setCompleted(task);
            },
          );
        },
        separatorBuilder: (context, index) {
          if (index == 0) {
            return BlocBuilder<InboxCubit, InboxCubitState>(
              builder: (context, state) {
                return Visibility(
                  visible: state.showInboxNotice,
                  child: const SizedBox(height: 16),
                );
              },
            );
          } else {
            return const SizedBox(height: 4);
          }
        },
      ),
    );
  }
}
