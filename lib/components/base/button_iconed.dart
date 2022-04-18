import 'package:flutter/material.dart';
import 'package:mobile/style/colors.dart';

class ButtonIconed extends StatelessWidget {
  final IconData icon;
  final String? text;
  final Function() onPressed;

  const ButtonIconed({
    Key? key,
    required this.icon,
    this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() => onPressed()),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: ColorsExt.grey4(context),
            width: 1,
          ),
        ),
        child: Wrap(
          children: [
            Icon(
              icon,
              color: ColorsExt.grey3(context),
              size: 18,
            ),
            Builder(builder: (context) {
              if (text == null) {
                return const SizedBox();
              }

              return Row(
                children: [
                  const SizedBox(width: 4),
                  Text(
                    text!,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                      color: ColorsExt.grey3(context),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
