import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/style/colors.dart';

class CreateTaskDurationItem extends StatefulWidget {
  const CreateTaskDurationItem({Key? key}) : super(key: key);

  static const double defaultHour = 2;

  @override
  State<CreateTaskDurationItem> createState() => _CreateTaskDurationItemState();
}

class _CreateTaskDurationItemState extends State<CreateTaskDurationItem> {
  final ValueNotifier<double> _selectedDuration = ValueNotifier(CreateTaskDurationItem.defaultHour);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: ValueListenableBuilder(
                  valueListenable: _selectedDuration,
                  builder: (context, double selectedDuration, child) {
                    double hours = selectedDuration;
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
              GestureDetector(
                onTap: () {
                  context.read<EditTaskCubit>().setDuration(_selectedDuration.value);
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(
                    'assets/images/icons/_common/checkmark.svg',
                    width: 24,
                    height: 24,
                    color: ColorsExt.akiflow(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _selectedDuration,
          builder: (context, double selectedDuration, child) {
            return Slider(
              value: selectedDuration,
              min: 0,
              max: 4,
              divisions: 16,
              thumbColor: ColorsExt.background(context),
              onChanged: (double value) {
                _selectedDuration.value = value;
              },
            );
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
