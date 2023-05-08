import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/availability/ui/cubit/availability_cubit.dart';
import 'package:models/task/availability_config.dart';

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
              color: ColorsExt.grey50(context),
              borderRadius: BorderRadius.circular(Dimension.radius),
              border: Border.all(
                color: ColorsExt.grey200(context),
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
              const SizedBox(width: Dimension.paddingS),
              Expanded(
                  child: Text(
                config.title ?? '',
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: ColorsExt.grey900(context),
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
              )),
              const SizedBox(width: Dimension.paddingS),
              Text(
                config.durationString,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: ColorsExt.grey600(context),
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
              const SizedBox(width: Dimension.paddingS),
              InkWell(
                  onTap: () {
                    context.read<AvailabilityCubit>().launchUrl(config.url_path);
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
            context.read<AvailabilityCubit>().copyLinkToClipboard(config).then((_) {
              _showLinkCopiedSnackBar(context);
            });
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

  _showLinkCopiedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(Dimension.padding),
            decoration: BoxDecoration(
              color: ColorsExt.green20(context),
              border: Border.all(
                color: ColorsExt.grey200(context),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(Dimension.radiusS),
            ),
            child: Row(
              children: [
                SvgPicture.asset(Assets.images.icons.common.squareOnSquareSVG),
                const SizedBox(width: Dimension.paddingS),
                Text(
                  t.availability.linkCopiedToClipboard,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: ColorsExt.grey800(context),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          )),
    );
  }
}
