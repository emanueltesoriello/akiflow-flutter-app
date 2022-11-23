import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:models/task/availability_config.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SlotTile extends StatelessWidget {
  const SlotTile({super.key, required this.config});
  final AvailabilityConfig config;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: ColorsExt.grey7(context),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: ColorsExt.grey5(context),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                config.settings != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(config.settings?['hostPicture']),
                      )
                    : CircleAvatar(
                        child: Text(config.title?.characters.first ?? ''),
                      ),
                const SizedBox(width: 10),
               Text(
                    config.title ?? '',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                ),
                const SizedBox(width: 10),
                Text(config.durationString,
                    style: TextStyle(
                      fontSize: 17,
                      color: ColorsExt.grey3(context),
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(width: 10),
                InkWell(
                    onTap: () {
                      launchUrlString("https://booking.akiflow.com/${config.url_path}");
                    },
                    child: SvgPicture.asset(Assets.images.icons.common.arrowUpRightSquareSVG))
              ],
            ),
          ),
          InkWell(
              onTap: () async {
                Clipboard.setData(ClipboardData(text: "https://booking.akiflow.com/${config.url_path}")).then((_) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Link copied to clipboard!')));
                });
              },
              child: SvgPicture.asset(Assets.images.icons.common.linkSVG))
        ],
      ),
    );
  }
}
