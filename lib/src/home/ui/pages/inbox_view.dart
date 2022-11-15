import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/components/task/notice.dart';
import 'package:mobile/common/components/task/task_list.dart';
import 'package:mobile/common/components/task/task_list_menu.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/home/ui/cubit/inbox/inbox_view_cubit.dart';
import 'package:mobile/src/home/ui/widgets/inbox/first_sync_progress_inbox.dart';
import 'package:models/task/task.dart';

import 'views/empty_home_view.dart';

class InboxView extends StatelessWidget {
  const InboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => InboxCubit(), child: const _View());
  }
}

class _View extends StatefulWidget {
  const _View({Key? key}) : super(key: key);

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  StreamSubscription? streamSubscription;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    TasksCubit tasksCubit = context.read<TasksCubit>();

    if (streamSubscription != null) {
      streamSubscription!.cancel();
    }

    streamSubscription = tasksCubit.scrollListStream.listen((allSelected) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, tasksState) {
        return Scaffold(
          appBar: AppBarComp(
            title: t.bottomBar.inbox,
            leading: SvgPicture.asset(
              "assets/images/icons/_common/tray.svg",
              width: 26,
              height: 26,
            ),
            actions: const [TaskListMenu()],
            showSyncButton: true,
          ),
          body: Stack(
            children: [
              Builder(
                builder: (context) {
                  List<Task> tasks = List.from(tasksState.inboxTasks);

                  tasks = tasks.where((element) => element.deletedAt == null && !element.isCompletedComputed).toList();

                  return BlocBuilder<InboxCubit, InboxCubitState>(
                    builder: (context, state) {
                      if (tasksState.tasksLoaded && tasks.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            return context.read<SyncCubit>().sync();
                          },
                          child: Center(
                            child: CustomScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                SliverFillRemaining(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: const [
                                      EmptyHomeViewPlaceholder(),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }

                      return TaskList(
                        tasks: tasks,
                        hideInboxLabel: true,
                        scrollController: scrollController,
                        sorting: TaskListSorting.sortingDescending,
                        showLabel: true,
                        showPlanInfo: false,
                        header: () {
                          if (!state.showInboxNotice) {
                            return null;
                          }
                          return GestureDetector(
                            onLongPress: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Notice(
                                title: t.notice.inboxTitle,
                                subtitle: t.notice.inboxSubtitle,
                                icon: Icons.info_outline,
                                onClose: () {
                                  context.read<InboxCubit>().inboxNoticeClosed();
                                },
                              ),
                            ),
                          );
                        }(),
                      );
                    },
                  );
                },
              ),
              Builder(
                builder: (context) {
                  if (tasksState.loading) {
                    return const FirstSyncProgressInbox();
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
