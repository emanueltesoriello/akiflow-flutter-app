import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/add_task/cubit/add_task_cubit.dart';
import 'package:mobile/features/add_task/ui/add_task_action_item.dart';
import 'package:mobile/features/add_task/ui/plan_modal.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';

class AddTaskModal extends StatelessWidget {
  const AddTaskModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddTaskCubit(context.read<TasksCubit>()),
      child: AddTaskModalView(),
    );
  }
}

class AddTaskModalView extends StatelessWidget {
  AddTaskModalView({Key? key}) : super(key: key);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      focusNode: FocusNode()..requestFocus(),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        hintText: t.addTask.titleHint,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: ColorsExt.grey3(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextStyle(
                        color: ColorsExt.grey2(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(bottom: 16),
                        isDense: true,
                        hintText: t.addTask.descriptionHint,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: ColorsExt.grey3(context),
                          fontSize: 17,
                        ),
                      ),
                      style: TextStyle(
                        color: ColorsExt.grey2(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _plannedFor(context),
                        const SizedBox(width: 8),
                        AddTaskActionItem(
                          leadingIconAsset:
                              "assets/images/icons/_common/hourglass.svg",
                          color: ColorsExt.grey6(context),
                          active: false,
                          onPressed: () {
                            // TODO CREATE TASK - task duration
                          },
                        ),
                        const SizedBox(width: 8),
                        AddTaskActionItem(
                          leadingIconAsset:
                              "assets/images/icons/_common/number.svg",
                          color: ColorsExt.grey6(context),
                          active: false,
                          text: t.addTask.label,
                          onPressed: () {
                            // TODO CREATE TASK - task label
                          },
                        ),
                        const Spacer(),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            context.read<AddTaskCubit>().create(
                                title: _titleController.text,
                                description: _descriptionController.text);

                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Material(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 36,
                              width: 36,
                              child: Center(
                                child: SvgPicture.asset(
                                  "assets/images/icons/_common/paperplane_send.svg",
                                  width: 24,
                                  height: 24,
                                  color: Theme.of(context).backgroundColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

  Widget _plannedFor(BuildContext context) {
    return BlocBuilder<AddTaskCubit, AddTaskCubitState>(
      builder: (context, state) {
        String leadingIconAsset;
        String text;
        Color color;

        if (state.planType == AddTaskPlanType.plan) {
          color = ColorsExt.cyan25(context);
          leadingIconAsset = "assets/images/icons/_common/calendar.svg";
        } else {
          color = ColorsExt.pink30(context);
          leadingIconAsset = "assets/images/icons/_common/clock.svg";
        }

        if (state.newTask.date != null) {
          if (state.newTask.datetime != null) {
            if (state.newTask.isToday) {
              text = DateFormat("HH:mm").format(state.newTask.date!.toLocal());
            } else if (state.newTask.isTomorrow) {
              text = t.addTask.tmw +
                  DateFormat(" - HH:mm").format(state.newTask.date!.toLocal());
            } else {
              text = DateFormat("EEE, d MMM")
                  .format(state.newTask.date!.toLocal());
            }
          } else {
            if (state.newTask.isToday) {
              text = t.addTask.today;
            } else if (state.newTask.isTomorrow) {
              text = t.addTask.tmw;
            } else {
              text = DateFormat("EEE, d MMM")
                  .format(state.newTask.date!.toLocal());
            }
          }
        } else if (state.newTask.status == TaskStatusType.someday.id) {
          text = t.addTask.someday;
        } else {
          text = t.bottomBar.inbox;
        }

        return AddTaskActionItem(
          text: text,
          color: color,
          leadingIconAsset: leadingIconAsset,
          active: true,
          onPressed: () {
            AddTaskCubit cubit = context.read<AddTaskCubit>();

            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              barrierColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => BlocProvider.value(
                value: cubit,
                child: const PlanModal(),
              ),
            );
          },
        );
      },
    );
  }
}
