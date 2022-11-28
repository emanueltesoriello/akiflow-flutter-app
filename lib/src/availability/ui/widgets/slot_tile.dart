import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:models/task/availability_config.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:mobile/extensions/date_extension.dart';

class SlotTile extends StatelessWidget {
  const SlotTile({super.key, required this.config});
  final AvailabilityConfig config;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListTile(
        title: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: ColorsExt.grey7(context),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: ColorsExt.grey5(context),
                width: 1,
              )),
          child: Row(
            children: [
              config.settings != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(config.settings?['hostPicture']),
                    )
                  : CircleAvatar(
                      child: Text(config.title?.characters.first ?? ''),
                    ),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                config.title ?? '',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 17,
                  color: ColorsExt.grey1(context),
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
              InkWell(
                  onTap: () {
                    launchUrlString("https://booking.akiflow.com/${config.url_path}");
                  },
                  child: SvgPicture.asset(Assets.images.icons.common.arrowUpRightSquareSVG)),
              const SizedBox(width: 10),
            ],
          ),
        ),
        trailing: InkWell(
            onTap: () async {
              String text = ''' Would any of these times work for you for a ${config.durationString} meeting?
${DateTime.parse(config.min_start_time ?? '').shortDateFormatted}
• ${DateTime.parse(config.min_start_time ?? '').timeFormatted} - ${DateTime.parse(config.max_end_time ?? '').timeFormatted}
Let me know or confirm here:
https://booking.akiflow.com/${config.url_path}''';
              print(text);
              Clipboard.setData(ClipboardData(text: text)).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied to clipboard!')));
              });
            },
            child: SvgPicture.asset(Assets.images.icons.common.linkSVG)),
      ),
    );
  }
}
