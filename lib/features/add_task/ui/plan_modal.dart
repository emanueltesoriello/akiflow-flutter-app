import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/add_task/cubit/add_task_cubit.dart';
import 'package:mobile/features/add_task/ui/add_task_top_action_item.dart';
import 'package:mobile/style/colors.dart';

class PlanModal extends StatelessWidget {
  const PlanModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            child: Container(
              color: Theme.of(context).backgroundColor,
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SafeArea(
                child: Column(
                  children: [
                    _planType(),
                    _predefinedDate(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _planType() {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: BlocBuilder<AddTaskCubit, AddTaskCubitState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AddTaskTopActionItem(
                      text: t.addTask.plan,
                      color: ColorsExt.cyan25(context),
                      leadingIconAsset:
                          "assets/images/icons/_common/calendar.svg",
                      active: state.planType == AddTaskPlanType.plan,
                      onPressed: () {
                        context
                            .read<AddTaskCubit>()
                            .selectPlanType(AddTaskPlanType.plan);
                      },
                    ),
                    const SizedBox(width: 24),
                    AddTaskTopActionItem(
                      text: t.addTask.snooze,
                      color: ColorsExt.pink30(context),
                      leadingIconAsset: "assets/images/icons/_common/clock.svg",
                      active: state.planType == AddTaskPlanType.snooze,
                      onPressed: () {
                        context
                            .read<AddTaskCubit>()
                            .selectPlanType(AddTaskPlanType.snooze);
                      },
                    ),
                  ],
                ),
              ),
              Container(
                color: Theme.of(context).dividerColor,
                width: double.infinity,
                height: 1,
              )
            ],
          );
        },
      ),
    );
  }

  Widget _predefinedDate(BuildContext context) {
    DateTime now = DateTime.now();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(children: [
            BlocBuilder<AddTaskCubit, AddTaskCubitState>(
              builder: (context, state) {
                switch (state.planType) {
                  case AddTaskPlanType.plan:
                    return _predefinedDateItem(
                      context,
                      iconAsset:
                          "assets/images/icons/_common/${DateFormat("dd").format(now)}_square.svg",
                      text: t.addTask.today,
                      trailingText: DateFormat("EEE").format(DateTime.now()),
                      onPressed: () {
                        context.read<AddTaskCubit>().planFor(now);
                        Navigator.pop(context);
                      },
                    );
                  case AddTaskPlanType.snooze:
                    DateTime laterToday =
                        DateTime(now.year, now.month, now.day, now.hour + 3);

                    return _predefinedDateItem(
                      context,
                      iconAsset: "assets/images/icons/_common/clock.svg",
                      text: t.addTask.laterToday,
                      trailingText: DateFormat("EEE HH:mm").format(laterToday),
                      onPressed: () {
                        context
                            .read<AddTaskCubit>()
                            .planFor(laterToday, dateTime: laterToday);
                        Navigator.pop(context);
                      },
                    );
                }
              },
            ),
            const SizedBox(height: 2),
            _predefinedDateItem(
              context,
              iconAsset:
                  "assets/images/icons/_common/${DateFormat("dd").format(now.add(const Duration(days: 1)))}_square.svg",
              text: t.addTask.tomorrow,
              trailingText:
                  DateFormat("EEE").format(now.add(const Duration(days: 1))),
              onPressed: () {
                context
                    .read<AddTaskCubit>()
                    .planFor(now.add(const Duration(days: 1)));
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 2),
            Builder(builder: (context) {
              DateTime nextMonday =
                  now.add(Duration(days: 7 - now.weekday + 1));

              return _predefinedDateItem(
                context,
                iconAsset:
                    "assets/images/icons/_common/${DateFormat("dd").format(nextMonday)}_square.svg",
                text: t.addTask.nextWeek,
                trailingText: DateFormat("EEE").format(nextMonday),
                onPressed: () {
                  context.read<AddTaskCubit>().planFor(nextMonday);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 2),
            BlocBuilder<AddTaskCubit, AddTaskCubitState>(
              builder: (context, state) {
                switch (state.planType) {
                  case AddTaskPlanType.plan:
                    return _predefinedDateItem(
                      context,
                      iconAsset: "assets/images/icons/_common/slash_circle.svg",
                      text: t.addTask.remove,
                      trailingText: t.bottomBar.inbox,
                      onPressed: () {
                        context.read<AddTaskCubit>().setForInbox();
                        Navigator.pop(context);
                      },
                    );
                  case AddTaskPlanType.snooze:
                    return _predefinedDateItem(
                      context,
                      iconAsset: "assets/images/icons/_common/archivebox.svg",
                      text: t.addTask.someday,
                      trailingText: t.addTask.noDate,
                      onPressed: () {
                        context.read<AddTaskCubit>().setSomeday();
                        Navigator.pop(context);
                      },
                    );
                }
              },
            ),
          ]),
        ),
        Container(
          color: Theme.of(context).dividerColor,
          width: double.infinity,
          height: 1,
        )
      ],
    );
  }

  Widget _predefinedDateItem(
    BuildContext context, {
    required String iconAsset,
    required String text,
    required String trailingText,
    required Function() onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 24,
              height: 24,
              color: ColorsExt.grey2(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: ColorsExt.grey2(context),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              trailingText,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: ColorsExt.grey3(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
