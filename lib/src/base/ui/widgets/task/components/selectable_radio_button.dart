import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:models/task/task.dart';

class SelectableRadioButton extends StatelessWidget {
  final Task task;

  const SelectableRadioButton(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool selected = task.selected ?? false;

    Color color = selected ? ColorsExt.akiflow(context) : ColorsExt.grey3(context);

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(2.17),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 21.67,
          height: 21.67,
          child: SvgPicture.asset(
            selected
                ? "assets/images/icons/_common/largecircle_fill_circle_2.svg"
                : "assets/images/icons/_common/circle.svg",
            color: color,
          ),
        ),
      ),
    );
  }
}
