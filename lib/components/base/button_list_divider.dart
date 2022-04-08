import 'package:flutter/material.dart';
import 'package:mobile/style/colors.dart';

class ButtonListDivider extends StatelessWidget {
  const ButtonListDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorsExt.grey5(context),
      height: 1,
    );
  }
}
