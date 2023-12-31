import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/marks_widget.dart';
import 'package:models/extensions/user_ext.dart';
import 'package:models/task/task.dart';
import 'package:models/user.dart';

class CreateTaskDurationItem extends StatefulWidget {
  const CreateTaskDurationItem({Key? key, this.onDurationSelected}) : super(key: key);
  final Function(String)? onDurationSelected;

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
          padding: const EdgeInsets.all(Dimension.padding),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: ValueListenableBuilder(
                  valueListenable: _selectedDuration,
                  builder: (context, int selectedDuration, child) {
                    Duration duration = Duration(seconds: selectedDuration);

                    String text = "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";

                    return Text(text,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: ColorsExt.grey2(context),
                            ));
                  },
                ),
              ),
              ValueListenableBuilder(
                  valueListenable: _selectedDuration,
                  builder: (context, int selectedDuration, child) {
                    return GestureDetector(
                      onTap: () {
                        context.read<EditTaskCubit>().setDuration(_selectedDuration.value, fromModal: true);
                      },
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SvgPicture.asset(
                          Assets.images.icons.common.checkmarkSVG,
                          width: Dimension.defaultIconSize,
                          height: Dimension.defaultIconSize,
                          color: ColorsExt.akiflow(context),
                        ),
                      ),
                    );
                  })
            ],
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _selectedDuration,
          builder: (context, int selectedDuration, child) {
            return SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const CircleThumbShape(thumbRadius: 12),
              ),
              child: Slider(
                value: selectedDuration / 3600,
                min: 0,
                max: 4,
                divisions: 16,
                thumbColor: ColorsExt.akiflow(context),
                onChanged: (double value) {
                  _selectedDuration.value = (value * 3600).toInt();
                },
              ),
            );
          },
        ),
        MarksWidget(selectedDuration: _selectedDuration),
        const Separator(),
      ],
    );
  }
}

class CircleThumbShape extends SliderComponentShape {
  final double thumbRadius;

  const CircleThumbShape({
    this.thumbRadius = 6.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;

    final fillPaint = Paint()
      ..color = ColorsLight.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = sliderTheme.thumbColor!
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, thumbRadius, fillPaint);
    canvas.drawCircle(center, thumbRadius, borderPaint);
  }
}
