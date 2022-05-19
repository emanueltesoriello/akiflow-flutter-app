import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/container_inner_shadow.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/features/add_task/ui/add_task_modal.dart';
import 'package:mobile/features/label/cubit/create_edit/label_cubit.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/label/ui/create_edit_section_modal.dart';
import 'package:mobile/features/label/ui/label_appbar.dart';
import 'package:mobile/features/label/ui/section_header.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';
import 'package:mobile/features/today/ui/today_task_list.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';

class LabelView extends StatelessWidget {
  const LabelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Task> labelTasks = context.watch<TasksCubit>().state.labelTasks;

    return BlocBuilder<LabelCubit, LabelCubitState>(
      builder: (context, labelState) {
        List<Task> filtered = labelTasks.toList();

        if (!labelState.showDone) {
          filtered = labelTasks.where((element) => !element.isCompletedComputed).toList();
        }

        filtered = filtered.where((element) => element.listId == labelState.selectedLabel?.id).toList();

        // Remove `sectionId` when the section not exists anymore
        for (Task task in filtered) {
          if (labelState.sections.every((element) => element.id != task.sectionId)) {
            int index = filtered.indexWhere((element) => element.id == task.id);
            Task updated = task.copyWith(sectionId: Nullable(null));
            filtered[index] = updated;
          }
        }

        return Column(
          children: [
            LabelAppBar(label: labelState.selectedLabel!, showDone: labelState.showDone),
            Expanded(
              child: ContainerInnerShadow(
                child: SlidableAutoCloseBehavior(
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: PrimaryScrollController.of(context) ?? ScrollController(),
                    slivers: labelState.sections.map((section) {
                      List<Task> tasks = filtered.where((element) => element.sectionId == section.id).toList();
                      int count = tasks.where((element) => element.sectionId == section.id).toList().length;

                      Widget? header = SectionHeaderItem(
                        section.title ?? t.task.noTitle,
                        taskCount: count,
                        showActionsMenu: section.id != null,
                        onClick: () {
                          context.read<LabelCubit>().toggleOpenSection(section.id);
                        },
                        listOpened: labelState.openedSections[section.id] ?? false,
                        onCreateTask: () async {
                          TaskStatusType taskStatusType = TaskStatusType.inbox;
                          DateTime date = context.read<TodayCubit>().state.selectedDate;

                          showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => AddTaskModal(
                              taskStatusType: taskStatusType,
                              date: date,
                              section: section,
                              label: labelState.selectedLabel,
                            ),
                          );
                        },
                        onDelete: () {
                          context.read<LabelCubit>().deleteSection(section);
                        },
                        onRename: () async {
                          LabelCubit labelCubit = context.read<LabelCubit>();
                          LabelsCubit labelsCubit = context.read<LabelsCubit>();

                          Label? sectionUpdated = await showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => BlocProvider(
                              key: ObjectKey(section),
                              create: (context) => LabelCubit(section, labelsCubit: labelsCubit),
                              child: CreateEditSectionModal(section: section),
                            ),
                          );

                          if (sectionUpdated != null) {
                            labelCubit.updateSection(sectionUpdated);
                          }
                        },
                      );

                      int snoozedCount = tasks.where((element) => element.isSnoozed).toList().length;
                      int somedayCount = tasks.where((element) => element.isSomeday).toList().length;

                      Widget? footer;

                      if (snoozedCount != 0 || somedayCount != 0) {
                        footer = Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Builder(builder: (context) {
                              if (snoozedCount == 0) {
                                return const SizedBox();
                              }
                              return CompactInfo(
                                iconAsset: "assets/images/icons/_common/clock.svg",
                                title: t.task.snoozed,
                                value: snoozedCount.toString(),
                              );
                            }),
                            Builder(builder: (context) {
                              if (somedayCount == 0) {
                                return const SizedBox();
                              }
                              return CompactInfo(
                                iconAsset: "assets/images/icons/_common/archivebox.svg",
                                title: t.task.someday,
                                value: somedayCount.toString(),
                              );
                            }),
                          ],
                        );
                      }

                      return TodayTaskList(
                        tasks: tasks,
                        sorting: TaskListSorting.descending,
                        showTasks: labelState.openedSections[section.id] ?? false,
                        showLabel: false,
                        header: labelState.sections.length > 1 ? header : null,
                        footer: footer,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CompactInfo extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String value;

  const CompactInfo({
    Key? key,
    required this.iconAsset,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: ColorsExt.grey5(context), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 16, height: 16, child: SvgPicture.asset(iconAsset, color: ColorsExt.grey2(context))),
          const SizedBox(width: 4),
          Text(
            "$value $title",
            style: TextStyle(fontSize: 13, color: ColorsExt.grey2(context)),
          ),
        ],
      ),
    );
  }
}
