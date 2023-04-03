import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';

class SettingHeaderText extends StatelessWidget {
  final String text;

  const SettingHeaderText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text.toUpperCase(),
            style: Theme.of(context).textTheme.caption?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorsExt.grey3(context),
                )),
        const SizedBox(height: Dimension.paddingXS),
      ],
    );
  }
}
