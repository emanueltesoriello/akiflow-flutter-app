import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
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
        Text(label.title ?? '(No title)',
            style: Theme.of(context).textTheme.subtitle1?.copyWith(
                  overflow: TextOverflow.ellipsis,
                  color: label.id != null ? ColorsExt.grey800(context) : ColorsExt.grey600(context),
                )),
        Builder(builder: (context) {
          if (folder == null) {
            return const SizedBox();
          }

          return Row(
            children: [
              const SizedBox(width: Dimension.padding),
              SvgPicture.asset(Assets.images.icons.common.folderSVG,
                  width: 16, height: 16, color: ColorsExt.grey600(context)),
              const SizedBox(width: Dimension.paddingXS),
              Text(
                folder?.title ?? "",
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: ColorsExt.grey600(context),
                    ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
