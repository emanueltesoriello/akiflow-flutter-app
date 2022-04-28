import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/style/colors.dart';

class AddTaskActionItem extends StatelessWidget {
  final Function() onPressed;
  final String? text;
  final String leadingIconAsset;
  final Color color;
  final bool active;

  const AddTaskActionItem({
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
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active ? color : ColorsExt.grey7(context),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Row(
            children: [
              SvgPicture.asset(
                leadingIconAsset,
                width: 22,
                height: 22,
                color: ColorsExt.grey2(context),
              ),
              _text(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _text(BuildContext context) {
    if (text == null || text!.isEmpty) {
      return const SizedBox();
    }

    return Row(
      children: [
        const SizedBox(width: 6),
        Text(
          text!,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: ColorsExt.grey2(context),
          ),
        ),
      ],
    );
  }
}
