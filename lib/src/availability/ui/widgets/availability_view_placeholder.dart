import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';

import '../../../../common/style/colors.dart';
import '../cubit/availability_cubit.dart';

class AvailabilityViewPlaceholder extends StatelessWidget {
  const AvailabilityViewPlaceholder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<AvailabilityCubit>().getAvailabilities(),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ListView(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: Dimension.paddingXXL),
              IgnorePointer(
                child: SvgPicture.asset(
                  Assets.images.icons.common.noActiveLinksSVG,
                  width: Dimension.defaultIllustrationSize,
                  height: Dimension.defaultIllustrationSize,
                ),
              ),
              const SizedBox(height: Dimension.paddingM),
              IgnorePointer(
                child: Column(
                  children: [
                    Text(
                      t.availability.noActiveLinksToShow,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey800(context)),
                    ),
                    const SizedBox(height: Dimension.padding),
                    Text(
                      t.availability.toCreateLinkUseDesktop,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(color: ColorsExt.grey600(context)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimension.paddingM),
              OutlinedButton(
                  onPressed: () {
                    context.read<MainCubit>().changeHomeView(HomeViewType.today);
                  },
                  child: Text(t.calendar.goToToday, style: TextStyle(color: ColorsExt.grey800(context)))),
              const SizedBox(height: Dimension.bottomBarHeight),
            ],
          ),
        ],
      ),
    );
  }
}
