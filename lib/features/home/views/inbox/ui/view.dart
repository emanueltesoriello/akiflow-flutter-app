import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/notice.dart';
import 'package:mobile/features/home/views/inbox/cubit/view_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
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
    List<Task> tasks = context.watch<TasksCubit>().state.tasks;

    return ListView.separated(
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

        return Text(task.title ?? "");
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
    );
  }
}
