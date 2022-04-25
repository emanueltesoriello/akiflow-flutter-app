import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';

class BottomTaskActions extends StatelessWidget {
  const BottomTaskActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _button(
            icon: "assets/images/icons/_common/Check-done.svg",
            label: t.task.done,
            click: () => context.read<TasksCubit>().done(),
          ),
          _button(
            icon: "assets/images/icons/_common/calendar.svg",
            label: t.task.plan,
            click: () => context.read<TasksCubit>().plan(),
          ),
          _button(
            icon: "assets/images/icons/_common/clock.svg",
            label: t.task.snooze,
            click: () => context.read<TasksCubit>().snooze(),
          ),
          const Text("3"),
          const Text("4"),
          const Text("5"),
        ],
      ),
    );
  }

  Widget _button({
    required String icon,
    required String label,
    required Function() click,
  }) {
    return InkWell(
      onTap: click,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(icon),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }
}
