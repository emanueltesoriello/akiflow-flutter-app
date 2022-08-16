import 'package:flutter/material.dart';
import 'package:mobile/features/onboarding/ui/triangle_painter.dart';
import 'package:mobile/common/style/colors.dart';

class BoxWithInfo extends StatelessWidget {
  final String info;

  const BoxWithInfo({
    Key? key,
    required this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          painter: TrianglePainter(strokeColor: ColorsExt.cyan25(context)),
          child: const SizedBox(
            height: 12,
            width: 14,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ColorsExt.cyan25(context),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(10),
          child: Text(
            info,
            style: TextStyle(
              color: ColorsExt.grey1(context),
              fontSize: 17,
            ),
          ),
        ),
      ],
    );
  }
}
