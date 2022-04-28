import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
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
                    _predefinedDate(),
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

  Widget _predefinedDate() {
    return Container();
  }
}
