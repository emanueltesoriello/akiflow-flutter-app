import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/theme.dart';

class Notice extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function() onClose;
  final Color? background;

  const Notice({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onClose,
    this.background,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background ?? ColorsExt.notice(context),
        borderRadius: BorderRadius.circular(noticeRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: ColorsExt.iconInfo(context)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              Icon(SFSymbols.xmark,
                  size: 20, color: ColorsExt.textGrey1(context)),
              InkWell(
                onTap: onClose,
                child: const SizedBox(width: 36, height: 36),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
