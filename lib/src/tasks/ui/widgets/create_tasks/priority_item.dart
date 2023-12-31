import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/style/sizes.dart';
import '../../../../../common/style/colors.dart';

class PriorityItem extends StatelessWidget {
  const PriorityItem({Key? key, required this.asset, required this.title, required this.onSelect, required this.hint})
      : super(key: key);
  final String asset;
  final String title;
  final String hint;
  final VoidCallback onSelect;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.all(Dimension.paddingS),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 26,
                  width: 26,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimension.radiusS),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      asset,
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  width: Dimension.paddingS,
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        color: ColorsExt.grey2(context),
                      ),
                ),
              ],
            ),
            Text(
              hint,
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    color: ColorsExt.grey3(context),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
