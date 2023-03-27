import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/text_top_action_item.dart';

class CreateTaskTopActionItem extends StatelessWidget {
  final Function() onPressed;
  final String? text;
  final String leadingIconAsset;
  final Color color;
  final bool active;

  const CreateTaskTopActionItem({
    Key? key,
    required this.onPressed,
    required this.leadingIconAsset,
    required this.color,
    required this.active,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 38,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        decoration: BoxDecoration(
          color: active ? color : ColorsExt.background(context),
          borderRadius: BorderRadius.circular(Dimension.radius),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                leadingIconAsset,
                width: Dimension.defaultIconSize,
                height: Dimension.defaultIconSize,
                color: active ? ColorsExt.grey2(context) : ColorsExt.grey3(context),
              ),
              TextTopActionItem(text: text, active: active)
            ],
          ),
        ),
      ),
    );
  }
}
