import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/availability/ui/cubit/availability_cubit.dart';
import 'package:models/task/availability_config.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SlotTile extends StatelessWidget {
  const SlotTile({super.key, required this.config});
  final AvailabilityConfig config;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ListTile(
        horizontalTitleGap: Dimension.paddingS,
        contentPadding: const EdgeInsets.only(left: Dimension.paddingS),
        title: Container(
          padding: const EdgeInsets.all(Dimension.paddingS),
          decoration: BoxDecoration(
              color: ColorsExt.grey7(context),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: ColorsExt.grey5(context),
                width: 1,
              )),
          child: Row(
            children: [
              config.settings != null && config.settings?['hostPicture'] != null
                  ? SizedBox(
                      height: Dimension.availabilityCircleAvatar,
                      width: Dimension.availabilityCircleAvatar,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(config.settings?['hostPicture']),
                      ),
                    )
                  : SizedBox(
                      height: Dimension.availabilityCircleAvatar,
                      width: Dimension.availabilityCircleAvatar,
                      child: CircleAvatar(
                        child: Text(config.title?.characters.first ?? ''),
                      ),
                    ),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                config.title ?? '',
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: ColorsExt.grey1(context),
                      fontWeight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                    ),
              )),
              const SizedBox(width: 5),
              Text(
                config.durationString,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: ColorsExt.grey3(context),
                      fontWeight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
              const SizedBox(width: Dimension.paddingS),
              InkWell(
                  onTap: () {
                    launchUrlString("https://booking.akiflow.com/${config.url_path}",
                        mode: LaunchMode.externalApplication);
                  },
                  child: SvgPicture.asset(
                    Assets.images.icons.common.arrowUpRightSquareSVG,
                    height: Dimension.arrowUpRightSquareSize,
                  )),
            ],
          ),
        ),
        visualDensity: VisualDensity.compact,
        trailing: InkWell(
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
                      const SizedBox(width: Dimension.paddingS),
                      Text(
                        t.availability.linkCopiedToClipboard,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: ColorsExt.grey2(context),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                )));
          },
          child: Container(
            margin: const EdgeInsets.only(right: Dimension.paddingXS),
            child: SizedBox(
              height: Dimension.availabilityLinkIconSize,
              width: Dimension.availabilityLinkIconSize,
              child: Center(
                child: SizedBox(
                  child: SvgPicture.asset(Assets.images.icons.common.linkSVG, height: 18),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
