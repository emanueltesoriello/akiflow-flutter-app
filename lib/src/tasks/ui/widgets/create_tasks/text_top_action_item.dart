import 'package:flutter/material.dart';
import 'package:mobile/common/style/sizes.dart';

import '../../../../../common/style/colors.dart';

class TextTopActionItem extends StatelessWidget {
  const TextTopActionItem({Key? key, required this.text, required this.active}) : super(key: key);
  final String? text;
  final bool active;
  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) {
      return const SizedBox();
    }

    return Row(
      children: [
        const SizedBox(width: Dimension.paddingS),
        Text(text!,
            style: Theme.of(context).textTheme.subtitle1?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: active ? ColorsExt.grey2(context) : ColorsExt.grey3(context),
                )),
      ],
    );
  }
}
