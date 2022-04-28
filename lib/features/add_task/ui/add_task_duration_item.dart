import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/add_task/cubit/add_task_cubit.dart';
import 'package:mobile/style/colors.dart';

class AddTaskDurationItem extends StatelessWidget {
  const AddTaskDurationItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: BlocBuilder<AddTaskCubit, AddTaskCubitState>(
            builder: (context, state) {
              double hours = state.selectedDuration ?? 4;
              double minutes = (hours - hours.floor()) * 60;

              return Text(
                "${hours.floor()}h${minutes.floor()}m",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: ColorsExt.grey2(context),
                  fontSize: 15,
                ),
              );
            },
          ),
        ),
        Slider(
          value: context.watch<AddTaskCubit>().state.selectedDuration ?? 4,
          min: 0,
          max: 8,
          divisions: 16,
          thumbColor: ColorsExt.background(context),
          onChanged: (double value) {
            context.read<AddTaskCubit>().setDuration(value);
          },
        ),
        const SizedBox(height: 10),
        _marks(context),
        const SizedBox(height: 24),
        Container(
          color: Theme.of(context).dividerColor,
          width: double.infinity,
          height: 1,
        ),
      ],
    );
  }

  Widget _marks(BuildContext context) {
    List<Widget> marks = [];

    for (int i = 0; i < 8 + 1; i++) {
      if (i % 4 == 0) {
        marks.add(
          Flexible(
            child: Center(
              child: Text(
                i == 0 ? "0" : "${i}h",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: ColorsExt.grey2(context),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      } else if (i % 2 == 0) {
        marks.add(
          Flexible(
            child: Center(
              child: Container(
                height: 8,
                width: 1,
                color: ColorsExt.grey3(context),
              ),
            ),
          ),
        );
      } else {
        marks.add(
          Flexible(
            child: Center(
              child: Container(
                height: 4,
                width: 1,
                color: ColorsExt.grey3(context),
              ),
            ),
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: marks,
    );
  }
}
