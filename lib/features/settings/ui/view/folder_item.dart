import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/style/colors.dart';
import 'package:models/label/label.dart';

class FolderItem extends StatelessWidget {
  final Label label;
  final Function() onTap;

  const FolderItem(
    this.label, {
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: SvgPicture.asset("assets/images/icons/_common/folder.svg", color: ColorsExt.grey2(context)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label.title!,
                style: TextStyle(
                  fontSize: 17,
                  color: ColorsExt.grey2(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
