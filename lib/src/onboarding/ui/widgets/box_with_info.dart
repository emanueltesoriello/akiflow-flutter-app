import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/onboarding/ui/widgets/triangle_painter.dart';

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
            borderRadius: BorderRadius.circular(Dimension.radius),
          ),
          padding: const EdgeInsets.all(Dimension.padding),
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
