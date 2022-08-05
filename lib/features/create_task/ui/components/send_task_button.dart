import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';


class SendTaskButton extends StatelessWidget {
  const SendTaskButton({Key? key, required this.onTap}) : super(key: key);
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap.call();
      },
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 36,
          width: 36,
          child: Center(
            child: SvgPicture.asset(
              Assets.images.icons.common.paperplaneSendSVG,
              width: 24,
              height: 24,
              color: Theme.of(context).backgroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
