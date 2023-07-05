import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/sizes.dart';

class SendTaskButton extends StatelessWidget {
  const SendTaskButton({Key? key, required this.onTap}) : super(key: key);
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap.call();
      },
      borderRadius: BorderRadius.circular(Dimension.radius),
      child: Material(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(Dimension.radius),
        child: SizedBox(
          height: 36,
          width: 36,
          child: Center(
            child: SvgPicture.asset(
              Assets.images.icons.common.paperplaneSendSVG,
              width: 24,
              height: 24,
              color: Theme.of(context).colorScheme.background,
            ),
          ),
        ),
      ),
    );
  }
}
