import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/add_task/cubit/add_task_cubit.dart';
import 'package:mobile/features/add_task/ui/add_task_action_item.dart';
import 'package:mobile/features/add_task/ui/add_task_duration.dart';
import 'package:mobile/features/add_task/ui/add_task_labels.dart';
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
      child: const AddTaskModalView(),
    );
  }
}

class AddTaskModalView extends StatefulWidget {
  const AddTaskModalView({Key? key}) : super(key: key);

  @override
  State<AddTaskModalView> createState() => _AddTaskModalViewState();
}

class _AddTaskModalViewState extends State<AddTaskModalView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FocusNode _titleFocus = FocusNode();

  @override
  void initState() {
    _titleFocus.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
              .padding
              .top,
        ),
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
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SafeArea(
                child: Column(
                  children: [
                    BlocBuilder<AddTaskCubit, AddTaskCubitState>(
                      builder: (context, state) {
                        if (state.setDuration) {
                          return const AddTaskDurationItem();
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                    BlocBuilder<AddTaskCubit, AddTaskCubitState>(
                      builder: (context, state) {
                        if (state.showLabelsList) {
                          return const AddTaskLabels();
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _title(context),
                          const SizedBox(height: 8),
                          _description(context),
                          const SizedBox(height: 16),
                          _actions(context),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row _actions(BuildContext context) {
    return Row(
      children: [
        _plannedFor(context),
        const SizedBox(width: 8),
        AddTaskActionItem(
          leadingIconAsset: "assets/images/icons/_common/hourglass.svg",
          color: ColorsExt.grey6(context),
          active: context.watch<AddTaskCubit>().state.setDuration,
          onPressed: () {
            context.read<AddTaskCubit>().toggleDuration();
          },
        ),
        const SizedBox(width: 8),
        BlocBuilder<AddTaskCubit, AddTaskCubitState>(
          builder: (context, state) {
            Color? background;

            if (state.selectedLabel?.color != null) {
              background = ColorsExt.getFromName(state.selectedLabel!.color!);
            }

            return AddTaskActionItem(
              leadingIconAsset: "assets/images/icons/_common/number.svg",
              leadingIconColor: background ?? ColorsExt.grey2(context),
              color: background != null
                  ? background.withOpacity(0.1)
                  : ColorsExt.grey6(context),
              active: true,
              text: state.selectedLabel?.title ?? t.addTask.label,
              onPressed: () {
                context.read<AddTaskCubit>().toggleLabels();
              },
            );
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
    );
  }

  TextField _description(BuildContext context) {
    return TextField(
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
    );
  }

  TextField _title(BuildContext context) {
    return TextField(
      controller: _titleController,
      focusNode: _titleFocus,
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
            FocusManager.instance.primaryFocus?.unfocus();

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
