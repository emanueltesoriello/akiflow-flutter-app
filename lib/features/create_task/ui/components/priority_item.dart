import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../style/colors.dart';

class PriorityItem extends StatelessWidget {
  const PriorityItem({Key? key, required this.asset, required this.title, required this.onSelect}) : super(key: key);
  final String asset;
  final String title;
  final VoidCallback onSelect;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
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
              width: 10,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                color: ColorsExt.grey2(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
