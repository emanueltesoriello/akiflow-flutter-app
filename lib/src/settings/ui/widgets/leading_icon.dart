import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class LeadingIcon extends StatelessWidget {
  const LeadingIcon({Key? key, this.leading}) : super(key: key);
  final Widget? leading;
  @override
  Widget build(BuildContext context) {
    if (leading == null) {
      return const SizedBox();
    }

    return Row(
      children: [
        SizedBox(width: 26, child: leading!),
        const SizedBox(width: 10.5),
      ],
    );
  }
}
