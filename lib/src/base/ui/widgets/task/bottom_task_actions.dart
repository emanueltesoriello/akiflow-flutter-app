import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/button_action.dart';
import 'package:mobile/src/base/ui/widgets/base/popup_menu_item.dart';
import 'package:mobile/src/home/ui/cubit/today/today_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/change_priority_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/deadline_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/labels_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/plan_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:table_calendar/table_calendar.dart';

enum BottomTaskAdditionalActions { moveToInbox, planForToday, setDeadline, duplicate, markAsDone, delete }

class BottomTaskActions extends StatelessWidget {
  const BottomTaskActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: bottomBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ButtonAction(
                    backColor: ColorsExt.cyan25(context),
                    topColor: ColorsExt.cyan(context),
                    icon: 'assets/images/icons/_common/calendar.svg',
                    bottomLabel: t.task.plan,
                    click: () {
                      showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => PlanModal(
                          initialDate: DateTime.now(),
                          initialDatetime: null,
                          taskStatusType: TaskStatusType.planned,
                          onSelectDate: (
                              {required DateTime? date,
                              required DateTime? datetime,
                              required TaskStatusType statusType}) {
                            context
                                .read<TasksCubit>()
                                .editPlanOrSnooze(date, dateTime: datetime, statusType: statusType);
                          },
                          setForInbox: () {
                            context.read<TasksCubit>().planFor(null, dateTime: null, statusType: TaskStatusType.inbox);
                          },
                          setForSomeday: () {
                            context
                                .read<TasksCubit>()
                                .planFor(null, dateTime: null, statusType: TaskStatusType.someday);
                          },
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ButtonAction(
                    backColor: ColorsExt.pink30(context),
                    topColor: ColorsExt.pink(context),
                    icon: 'assets/images/icons/_common/clock.svg',
                    bottomLabel: t.task.snooze,
                    click: () {
                      showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => PlanModal(
                          initialDate: DateTime.now(),
                          initialDatetime: null,
                          initialHeaderStatusType: TaskStatusType.snoozed,
                          taskStatusType: TaskStatusType.snoozed,
                          onSelectDate: (
                              {required DateTime? date,
                              required DateTime? datetime,
                              required TaskStatusType statusType}) {
                            context
                                .read<TasksCubit>()
                                .editPlanOrSnooze(date, dateTime: datetime, statusType: statusType);
                          },
                          setForInbox: () {
                            context.read<TasksCubit>().planFor(null, dateTime: null, statusType: TaskStatusType.inbox);
                          },
                          setForSomeday: () {
                            context
                                .read<TasksCubit>()
                                .planFor(null, dateTime: null, statusType: TaskStatusType.someday);
                          },
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ButtonAction(
                    backColor: ColorsExt.grey5(context),
                    topColor: ColorsExt.grey3(context),
                    icon: 'assets/images/icons/_common/number.svg',
                    bottomLabel: t.task.assign,
                    click: () {
                      var cubit = context.read<TasksCubit>();

                      showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => LabelsModal(
                          selectLabel: (Label label) {
                            cubit.assignLabel(label);
                            Navigator.pop(context);
                          },
                          showNoLabel: true,
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ButtonAction(
                    backColor: ColorsExt.grey5(context),
                    topColor: ColorsExt.grey3(context),
                    icon: 'assets/images/icons/_common/exclamationmark.svg',
                    bottomLabel: t.task.priority.title,
                    click: () async {
                      TasksCubit cubit = context.read<TasksCubit>();

                      PriorityEnum? newPriority = await showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => const PriorityModal(null),
                        closeProgressThreshold: 0,
                        expand: false,
                      );

                      cubit.setPriority(newPriority);
                    },
                  ),
                ),
                Expanded(
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(useMaterial3: false, popupMenuTheme: const PopupMenuThemeData(elevation: 4)),
                    child: BlocBuilder<TodayCubit, TodayCubitState>(builder: (context, todayCubitState) {
                      return BlocBuilder<MainCubit, MainCubitState>(builder: (context, state) {
                        return PopupMenuButton<BottomTaskAdditionalActions>(
                          icon: SvgPicture.asset(
                            "assets/images/icons/_common/ellipsis.svg",
                            width: 26,
                            height: 26,
                            color: ColorsExt.grey2(context),
                          ),
                          onSelected: (BottomTaskAdditionalActions result) {
                            switch (result) {
                              case BottomTaskAdditionalActions.moveToInbox:
                                context.read<TasksCubit>().moveToInbox();
                                break;
                              case BottomTaskAdditionalActions.planForToday:
                                context.read<TasksCubit>().planForToday();
                                break;
                              case BottomTaskAdditionalActions.setDeadline:
                                var cubit = context.read<TasksCubit>();

                                showCupertinoModalBottomSheet(
                                  context: context,
                                  builder: (context) => BlocProvider.value(
                                    value: cubit,
                                    child: DeadlineModal(
                                      initialDate: () {
                                        try {
                                          return DateTime.tryParse(
                                              context.watch<EditTaskCubit>().state.updatedTask.dueDate!);
                                        } catch (_) {
                                          return null;
                                        }
                                      }(),
                                      onSelectDate: (DateTime? date) {
                                        cubit.setDeadline(date);
                                      },
                                    ),
                                  ),
                                );

                                break;
                              case BottomTaskAdditionalActions.duplicate:
                                context.read<TasksCubit>().duplicate();
                                break;
                              case BottomTaskAdditionalActions.markAsDone:
                                HapticFeedback.heavyImpact();
                                TasksCubit tasksCubit = context.read<TasksCubit>();
                                tasksCubit.markAsDone();
                                break;
                              case BottomTaskAdditionalActions.delete:
                                context.read<TasksCubit>().delete();
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<BottomTaskAdditionalActions>>[
                            if (state.homeViewType != HomeViewType.inbox)
                              PopupMenuItem<BottomTaskAdditionalActions>(
                                value: BottomTaskAdditionalActions.moveToInbox,
                                child: PopupMenuCustomItem(
                                  iconAsset: "assets/images/icons/_common/tray.svg",
                                  text: t.task.moveToInbox,
                                ),
                              ),
                            if (state.homeViewType != HomeViewType.today ||
                                !isSameDay(todayCubitState.selectedDate, DateTime.now()))
                              PopupMenuItem<BottomTaskAdditionalActions>(
                                value: BottomTaskAdditionalActions.planForToday,
                                child: PopupMenuCustomItem(
                                  iconAsset:
                                      "assets/images/icons/_common/${DateFormat("dd").format(DateTime.now())}_square.svg",
                                  text: t.task.planForToday,
                                ),
                              ),
                            PopupMenuItem<BottomTaskAdditionalActions>(
                              value: BottomTaskAdditionalActions.setDeadline,
                              child: PopupMenuCustomItem(
                                iconAsset: "assets/images/icons/_common/flags.svg",
                                text: t.task.setDeadline,
                              ),
                            ),
                            PopupMenuItem<BottomTaskAdditionalActions>(
                              value: BottomTaskAdditionalActions.duplicate,
                              child: PopupMenuCustomItem(
                                iconAsset: "assets/images/icons/_common/square_on_square.svg",
                                text: t.task.duplicate,
                              ),
                            ),
                            PopupMenuItem<BottomTaskAdditionalActions>(
                              value: BottomTaskAdditionalActions.markAsDone,
                              child: PopupMenuCustomItem(
                                iconAsset: "assets/images/icons/_common/Check-done-outline.svg",
                                text: t.task.markAsDone,
                              ),
                            ),
                            PopupMenuItem<BottomTaskAdditionalActions>(
                              value: BottomTaskAdditionalActions.delete,
                              child: PopupMenuCustomItem(
                                iconAsset: "assets/images/icons/_common/trash.svg",
                                text: t.task.delete,
                              ),
                            ),
                          ],
                        );
                      });
                    }),
                  ),
                ),
              ],
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: SizedBox(height: MediaQuery.of(context).padding.bottom))
        ],
      ),
    );
  }
}
