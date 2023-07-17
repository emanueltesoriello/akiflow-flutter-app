import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/style/colors.dart';

class BottomButton extends StatelessWidget {
  final String title;
  final String image;
  final void Function()? onTap;
  final Color? iconColor;
  final Color? containerColor;

  const BottomButton(
      {Key? key, required this.title, required this.image, this.onTap, this.iconColor, this.containerColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: containerColor ?? ColorsExt.grey100(context),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
                height: 20,
                child: SvgPicture.asset(
                  image,
                  width: iconColor != null ? 15 : 20,
                  height: iconColor != null ? 15 : 20,
                  color: iconColor ?? ColorsExt.grey600(context),
                ),
              ),
            ],
          ),
        ),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w500)),
      ],
    );
  }
}
