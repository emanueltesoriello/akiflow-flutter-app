import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/task/notice.dart';
import 'package:mobile/src/base/ui/widgets/task/task_list.dart';
import 'package:mobile/src/home/ui/cubit/inbox/inbox_view_cubit.dart';
import 'package:mobile/src/home/ui/pages/views/empty_inbox_placeholder.dart';
import 'package:mobile/src/home/ui/widgets/first_sync_progress.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:models/task/task.dart';

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
  bool wasEmpty = false;

  @override
  void initState() {
    try {
      TasksCubit tasksCubit = context.read<TasksCubit>();

      if (streamSubscription != null) {
        streamSubscription!.cancel();
      }

      streamSubscription = tasksCubit.scrollListStream.listen((allSelected) {
        try {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            try {
              if (scrollController.hasClients) {
                scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              }
            } catch (e) {
              rethrow;
            }
          });
        } catch (e) {
          print(e);
        }
      });
    } catch (e) {
      print(e);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, tasksState) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBarComp(
            title: t.bottomBar.inbox,
            leading: SvgPicture.asset(
              Assets.images.icons.common.traySVG,
              width: Dimension.appBarLeadingIcon,
              height: Dimension.appBarLeadingIcon,
            ),
            showSyncButton: true,
          ),
          body: Stack(
            children: [
              BlocBuilder<InboxCubit, InboxCubitState>(
                builder: (context, state) {
                  List<Task> tasks = List.from(tasksState.inboxTasks);

                  tasks = tasks.where((element) => element.deletedAt == null && !element.isCompletedComputed).toList();
                  if (tasksState.tasksLoaded && tasks.isEmpty) {
                    wasEmpty = true;
                    return RefreshIndicator(
                      backgroundColor: ColorsExt.background(context),
                      onRefresh: () async {
                        context.read<SyncCubit>().sync();
                      },
                      child: const EmptyInboxPlaceholder(),
                    );
                  } else {
                    return TaskList(
                      key: const Key("inbox"),
                      tasks: tasks,
                      wasEmpty: wasEmpty, // workaround to show animation on first task added
                      afterAddingFirstTask: () {
                        wasEmpty = false; // workaround to show animation on first task added
                      },
                      hideInboxLabel: true,
                      scrollController: scrollController,
                      sorting: TaskListSorting.sortingDescending,
                      showLabel: true,
                      showPlanInfo: false,
                      addBottomPadding: true,
                      header: () {
                        if (!state.showInboxNotice) {
                          return null;
                        }

                        return GestureDetector(
                          onLongPress: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(Dimension.padding),
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
                  }
                },
              ),
              tasksState.loading ? const FirstSyncProgress() : const SizedBox()
            ],
          ),
        );
      },
    );
  }
}
