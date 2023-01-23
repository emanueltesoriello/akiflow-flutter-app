import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/style/colors.dart';

class BottomButton extends StatelessWidget {
  final String title;
  final String image;
  const BottomButton({
    Key? key,
    required this.title,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: ColorsExt.grey6(context),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
              ),
              SvgPicture.asset(
                image,
                width: 22,
                height: 22,
                color: ColorsExt.grey3(context),
              ),
            ],
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500, color: ColorsExt.grey2(context)),
        ),
      ],
    );
  }
}
