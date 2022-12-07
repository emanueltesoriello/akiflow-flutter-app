import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/availability/ui/cubit/availability_cubit.dart';
import 'package:models/task/availability_config.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SlotTile extends StatelessWidget {
  const SlotTile({super.key, required this.config});
  final AvailabilityConfig config;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 9.0),
        title: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: ColorsExt.grey7(context),
              borderRadius: BorderRadius.circular(6),
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
                  fontSize: 15,
                  color: ColorsExt.grey1(context),
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
              const SizedBox(width: 5),
              Text(config.durationString,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 15,
                    color: ColorsExt.grey3(context),
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                  )),
              const SizedBox(width: 6),
              InkWell(
                  onTap: () {
                    launchUrlString("https://booking.akiflow.com/${config.url_path}",
                        mode: LaunchMode.externalApplication);
                  },
                  child: SvgPicture.asset(
                    Assets.images.icons.common.arrowUpRightSquareSVG,
                    height: 18,
                  )),
            ],
          ),
        ),
        trailing: Container(
          margin: const EdgeInsets.only(right: 5.0),
          child: InkWell(
              onTap: () async {
                Clipboard.setData(ClipboardData(text: context.read<AvailabilityCubit>().getAvailabilityText(config)));

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.transparent,
                    content: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: ColorsExt.green20(context),
                        border: Border.all(
                          color: ColorsExt.grey5(context),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(Assets.images.icons.common.squareOnSquareSVG),
                          const SizedBox(width: 8),
                          Text(
                            'Link copied to clipboard!',
                            style:
                                TextStyle(color: ColorsExt.grey2(context), fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ],
                      ),
                    )));
              },
              child: SvgPicture.asset(
                Assets.images.icons.common.linkSVG,
                height: 17.79,
              )),
        ),
      ),
    );
  }
}
