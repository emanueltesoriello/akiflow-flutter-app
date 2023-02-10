
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:models/label/label.dart';

class LabelTitle extends StatelessWidget {
  const LabelTitle({
    Key? key,
    required this.label,
    required this.folder,
  }) : super(key: key);

  final Label label;
  final Label? folder;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        const SizedBox(width: 8),
        Text(
          label.title ?? '(No title)',
          style: TextStyle(
            fontSize: 17,
            overflow: TextOverflow.ellipsis,
            color: label.id != null ? ColorsExt.grey2(context) : ColorsExt.grey3(context),
          ),
        ),
        Builder(builder: (context) {
          if (folder == null) {
            return const SizedBox();
          }

          return Row(
            children: [
              const SizedBox(width: 12),
              SvgPicture.asset("assets/images/icons/_common/folder.svg",
                  width: 16, height: 16, color: ColorsExt.grey3(context)),
              const SizedBox(width: 4),
              Text(
                folder?.title ?? "",
                style: TextStyle(
                  fontSize: 15,
                  color: ColorsExt.grey3(context),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}