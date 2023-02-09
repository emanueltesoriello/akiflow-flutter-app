import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/background_service.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/notifications/notifications_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/label/ui/cubit/labels_cubit.dart';
import 'package:mobile/src/label/ui/widgets/create_edit_section_modal.dart';
import 'package:mobile/src/label/ui/widgets/label_appbar.dart';
import 'package:mobile/src/label/ui/widgets/section_header.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';
import 'package:mobile/core/preferences.dart';

import '../../../base/ui/widgets/task/task_list.dart';
import '../../../tasks/ui/pages/create_task/create_task_modal.dart';

class LabelView extends StatefulWidget {
  const LabelView({Key? key}) : super(key: key);

  @override
  State<LabelView> createState() => _LabelViewState();
}

class _LabelViewState extends State<LabelView> {
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
        try {
          scrollController.animateTo(scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        } catch (_) {}
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Task> labelTasks = List.from(context.watch<TasksCubit>().state.labelTasks);
    bool showDone = context.watch<LabelsCubit>().state.showDone;
    Label? label = context.watch<LabelsCubit>().state.selectedLabel;

    return Scaffold(
      appBar: LabelAppBar(label: label!, showDone: showDone),
      body: BlocBuilder<LabelsCubit, LabelsCubitState>(
        builder: (context, labelState) {
          List<Task> filtered = labelTasks.toList();

          if (!labelState.showDone) {
            filtered = labelTasks.where((element) => !element.isCompletedComputed).toList();
          }

          filtered = filtered
              .where((element) => element.listId == labelState.selectedLabel?.id && element.status != 10)
              .toList();

          // Remove `sectionId` when the section not exists anymore
          for (Task task in filtered) {
            if (labelState.sections.every((element) => element.id != task.sectionId)) {
              int index = filtered.indexWhere((element) => element.id == task.id);
              Task updated = task.copyWith(sectionId: Nullable(null));
              filtered[index] = updated;
            }
          }

          return RefreshIndicator(
            backgroundColor: ColorsExt.background(context),
            onRefresh: () async {
              context.read<SyncCubit>().sync();
              NotificationsCubit.scheduleNotificationsService(locator<PreferencesRepository>());
            },
            child: SlidableAutoCloseBehavior(
              child: ListView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    ...labelState.sections.map((section) {
                      List<Task> tasks = filtered.where((element) => element.sectionId == section.id).toList();

                      List<Task> tasksWithoutSnoozedAndSomeday = List.from(tasks);

                      if (!labelState.showSnoozed) {
                        tasksWithoutSnoozedAndSomeday.removeWhere((element) => element.isSnoozed);
                      }

                      if (!labelState.showSomeday) {
                        tasksWithoutSnoozedAndSomeday.removeWhere((element) => element.isSomeday);
                      }

                      int count = tasksWithoutSnoozedAndSomeday
                          .where((element) => element.sectionId == section.id)
                          .toList()
                          .length;

                      Widget? header = SectionHeaderItem(
                        section.title ?? t.noTitle,
                        taskCount: count,
                        showActionsMenu: section.id != null,
                        onClick: () {
                          context.read<LabelsCubit>().toggleOpenSection(section.id);
                        },
                        listOpened: labelState.openedSections[section.id] ?? false,
                        onCreateTask: () async {
                          EditTaskCubit editTaskCubit = context.read<EditTaskCubit>();

                          Task task = editTaskCubit.state.updatedTask.copyWith(
                            sectionId: Nullable(section.id),
                            status: Nullable(TaskStatusType.inbox.id),
                            date: Nullable(null),
                            datetime: Nullable(null),
                            listId: Nullable(labelState.selectedLabel?.id),
                          );

                          editTaskCubit.attachTask(task);

                          showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => const CreateTaskModal(),
                          );
                        },
                        onDelete: () {
                          context.read<LabelsCubit>().deleteSection(section);
                        },
                        onRename: () async {
                          LabelsCubit labelsCubit = context.read<LabelsCubit>();

                          Label? sectionUpdated = await showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => CreateEditSectionModal(initialSection: section),
                          );

                          if (sectionUpdated != null) {
                            labelsCubit.updateSection(sectionUpdated);
                          }
                        },
                      );

                      int snoozedCount = tasks.where((element) => element.isSnoozed).toList().length;
                      int somedayCount = tasks.where((element) => element.isSomeday).toList().length;

                      Widget? footer;

                      if (snoozedCount != 0 || somedayCount != 0) {
                        List<Widget> wrapped = [];

                        if (snoozedCount != 0) {
                          wrapped.add(() {
                            String text;
                            String? iconAsset;

                            if (!labelState.showSnoozed) {
                              text = "$snoozedCount ${t.task.snoozed}";
                              iconAsset = Assets.images.icons.common.clockSVG;
                            } else {
                              text = t.label.hideSnoozed;
                            }

                            return CompactInfo(
                              iconAsset: iconAsset,
                              text: text,
                              onPressed: () {
                                SchedulerBinding.instance.addPostFrameCallback((_) {
                                  double position = scrollController.position.maxScrollExtent;
                                  scrollController.animateTo(position,
                                      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                });

                                context.read<LabelsCubit>().toggleShowSnoozed();
                              },
                            );
                          }());
                        }

                        if (somedayCount != 0) {
                          wrapped.add(() {
                            String text;
                            String? iconAsset;

                            if (!labelState.showSomeday) {
                              text = "$somedayCount ${t.task.someday}";
                              iconAsset = Assets.images.icons.common.archiveboxSVG;
                            } else {
                              text = t.label.hideSomeday;
                            }

                            return CompactInfo(
                              iconAsset: iconAsset,
                              text: text,
                              onPressed: () async {
                                SchedulerBinding.instance.addPostFrameCallback((_) {
                                  double position = scrollController.position.maxScrollExtent;
                                  scrollController.animateTo(position,
                                      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                });

                                context.read<LabelsCubit>().toggleShowSomeday();
                              },
                            );
                          }());
                        }
                        footer = Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(spacing: 8, runSpacing: 8, children: wrapped),
                        );
                      }

                      return TaskList(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        tasks: tasksWithoutSnoozedAndSomeday,
                        visible: labelState.openedSections[section.id] ?? false,
                        showLabel: false,
                        header: labelState.sections.length > 1 ? header : null,
                        footer: footer,
                        showPlanInfo: true,
                        sorting: TaskListSorting.sortingLabelAscending,
                      );
                    }).toList(),
                    const SizedBox(height: 100)
                  ]),
            ),
          );
        },
      ),
    );
  }
}

class CompactInfo extends StatelessWidget {
  final String? iconAsset;
  final String text;
  final Function()? onPressed;

  const CompactInfo({
    Key? key,
    this.iconAsset,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: ColorsExt.grey5(context), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Builder(builder: (context) {
              if (iconAsset == null) {
                return const SizedBox();
              }

              return Row(
                children: [
                  SizedBox(width: 16, height: 16, child: SvgPicture.asset(iconAsset!, color: ColorsExt.grey2(context))),
                  const SizedBox(width: 4),
                ],
              );
            }),
            Text(
              text,
              style: TextStyle(fontSize: 13, color: ColorsExt.grey2(context)),
            ),
          ],
        ),
      ),
    );
  }
}
