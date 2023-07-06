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
          painter: TrianglePainter(strokeColor: ColorsExt.jordyBlue200(context)),
          child: const SizedBox(
            height: 12,
            width: 14,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ColorsExt.jordyBlue200(context),
            borderRadius: BorderRadius.circular(Dimension.radius),
          ),
          padding: const EdgeInsets.all(Dimension.padding),
          child: Text(
            info,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ColorsExt.grey900(context),
                ),
          ),
        ),
      ],
    );
  }
}
