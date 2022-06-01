import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/style/colors.dart';

class CreateTaskDurationItem extends StatelessWidget {
  const CreateTaskDurationItem({Key? key}) : super(key: key);

  static const double defaultHour = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: BlocBuilder<EditTaskCubit, EditTaskCubitState>(
            builder: (context, state) {
              double hours = state.selectedDuration ?? defaultHour;
              double minutes = (hours - hours.floor()) * 60;

              String text;

              if (minutes == 0) {
                text = '${hours.floor()}h';
              } else {
                text = '${hours.floor()}h ${minutes.floor()}m';
              }

              return Text(
                text,
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
          value: context.watch<EditTaskCubit>().state.selectedDuration ?? defaultHour,
          min: 0,
          max: 4,
          divisions: 16,
          thumbColor: ColorsExt.background(context),
          onChanged: (double value) {
            context.read<EditTaskCubit>().setDuration(value);
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

    for (int i = 0; i < 4 + 1; i++) {
      if (i % 2 == 0) {
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
