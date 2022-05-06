import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/notice.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/features/inbox/cubit/inbox_view_cubit.dart';
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

    return BlocBuilder<InboxCubit, InboxCubitState>(
      builder: (context, state) {
        return TaskList(
          tasks: tasks,
          hideInboxLabel: true,
          sorting: TaskListSorting.ascending,
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
  }
}
