import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';

class SettingHeaderText extends StatelessWidget {
  final String text;

  const SettingHeaderText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text.toUpperCase(),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
