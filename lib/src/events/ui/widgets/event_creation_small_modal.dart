import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';

class EventCreationSmallModal extends StatelessWidget {
  const EventCreationSmallModal({
    Key? key,
    required this.tappedTime,
    required this.onTap,
    required this.use24hFormat,
  }) : super(key: key);
  final DateTime tappedTime;
  final Function(bool) onTap;
  final bool use24hFormat;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsCubitState>(
      builder: (context, state) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimension.padding),
            topRight: Radius.circular(Dimension.padding),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    const SizedBox(height: Dimension.padding),
                    const ScrollChip(),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        onTap(true);
                      },
                      child: ListView(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                        children: [
                          _titleRow(context),
                          const Separator(),
                          _datetimeRow(context),
                          const Separator(),
                          _busyRow(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Padding _titleRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
      child: Row(
        children: [
          Text(t.event.editEvent.addTitle,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: ColorsExt.grey700(context), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Padding _datetimeRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
      child: Row(
        children: [
          SizedBox(
            width: Dimension.defaultIconSize,
            height: Dimension.defaultIconSize,
            child: SvgPicture.asset(
              Assets.images.icons.common.calendarSVG,
            ),
          ),
          const SizedBox(width: Dimension.padding),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat("EEE dd MMM").format(tappedTime),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w400)),
                    const SizedBox(height: Dimension.padding),
                    Text(DateFormat(use24hFormat ? "HH:mm" : "h:mm a").format(tappedTime),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w600)),
                  ],
                ),
                SvgPicture.asset(Assets.images.icons.common.arrowRightSVG,
                    width: Dimension.defaultIconSize,
                    height: Dimension.defaultIconSize,
                    color: ColorsExt.grey600(context)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(DateFormat("EEE dd MMM").format(tappedTime),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w400)),
                    const SizedBox(height: Dimension.padding),
                    Text(DateFormat(use24hFormat ? "HH:mm" : "h:mm a").format(tappedTime.add(const Duration(hours: 1))),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding _busyRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimension.padding),
      child: Row(
        children: [
          SizedBox(
            width: Dimension.defaultIconSize,
            height: Dimension.defaultIconSize,
            child: SvgPicture.asset(
              Assets.images.icons.common.briefcaseSVG,
            ),
          ),
          const SizedBox(width: Dimension.padding),
          Text(t.event.busy,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}
