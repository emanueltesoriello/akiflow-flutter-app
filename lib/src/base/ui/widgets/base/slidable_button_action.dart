import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/style/sizes.dart';

class SlidableButtonAction extends StatelessWidget {
  final Color backColor;
  final Color topColor;
  final String icon;
  final String? label;
  final String? bottomLabel;
  final double? size;
  final Function() click;
  final bool leftToRight;

  const SlidableButtonAction({
    Key? key,
    required this.backColor,
    required this.topColor,
    required this.icon,
    this.label,
    this.bottomLabel,
    this.size,
    required this.click,
    required this.leftToRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Align(
          child: leftToRight
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        icon,
                        color: topColor,
                        width: size ?? Dimension.defaultIconSize,
                        height: size ?? Dimension.defaultIconSize,
                      ),
                      if (label != null && label!.isNotEmpty) const SizedBox(width: Dimension.padding),
                      if (label != null && label!.isNotEmpty)
                        Text(
                          label!,
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: topColor,
                              ),
                        ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(
                      right: (MediaQuery.of(context).size.width * 0.6 / 3 / 2) -
                          (size ?? Dimension.defaultIconSize) +
                          Dimension.paddingS),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (label != null && label!.isNotEmpty)
                        Text(
                          label!,
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: topColor,
                              ),
                        ),
                      if (label != null && label!.isNotEmpty) const SizedBox(width: Dimension.padding),
                      SvgPicture.asset(
                        icon,
                        color: topColor,
                        width: size ?? Dimension.defaultIconSize,
                        height: size ?? Dimension.defaultIconSize,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
