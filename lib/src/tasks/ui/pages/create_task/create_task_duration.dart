import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/marks_widget.dart';
import 'package:models/extensions/user_ext.dart';
import 'package:models/task/task.dart';
import 'package:models/user.dart';

class CreateTaskDurationItem extends StatefulWidget {
  const CreateTaskDurationItem({Key? key}) : super(key: key);

  @override
  State<CreateTaskDurationItem> createState() => _CreateTaskDurationItemState();
}

class _CreateTaskDurationItemState extends State<CreateTaskDurationItem> {
  late final ValueNotifier<int> _selectedDuration;

  @override
  void initState() {
    Task task = context.read<EditTaskCubit>().state.updatedTask;

    if (task.duration != null) {
      _selectedDuration = ValueNotifier(task.duration!);
    } else {
      User user = context.read<AuthCubit>().state.user!;
      _selectedDuration = ValueNotifier(user.defaultDuration);
    }
    super.initState();
  }

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
                  builder: (context, int selectedDuration, child) {
                    Duration duration = Duration(seconds: selectedDuration);

                    String text = "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";

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
                    Assets.images.icons.common.checkmarkSVG,
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
          builder: (context, int selectedDuration, child) {
            return Slider(
              value: selectedDuration / 3600,
              min: 0,
              max: 4,
              divisions: 16,
              thumbColor: ColorsExt.background(context),
              onChanged: (double value) {
                _selectedDuration.value = (value * 3600).toInt();
              },
            );
          },
        ),
        MarksWidget(selectedDuration: _selectedDuration),
        const Separator(),
      ],
    );
  }
}
