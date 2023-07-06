import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:models/task/task.dart';

class SelectableRadioButton extends StatelessWidget {
  final Task task;

  const SelectableRadioButton(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool selected = task.selected ?? false;

    Color color = selected ? ColorsExt.akiflow500(context) : ColorsExt.grey600(context);

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(2.17),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 21.67,
          height: 21.67,
          child: SvgPicture.asset(
            selected ? Assets.images.icons.common.largecircleFillCircle2SVG : Assets.images.icons.common.circleSVG,
            color: color,
          ),
        ),
      ),
    );
  }
}
