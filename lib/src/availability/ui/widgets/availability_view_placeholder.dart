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
              const SizedBox(
                height: 80,
              ),
              IgnorePointer(
                child: SvgPicture.asset(
                  Assets.images.icons.common.noActiveLinksSVG,
                  width: 130,
                  height: 130,
                ),
              ),
              const SizedBox(height: 24),
              IgnorePointer(
                child: Column(
                  children: [
                    Text(
                      t.availability.noActiveLinksToShow,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      t.availability.toCreateLinkUseDesktop,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        color: ColorsExt.grey3(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  context.read<MainCubit>().changeHomeView(HomeViewType.today);
                },
                child: Container(
                  width: 114,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  height: 36,
                  decoration: BoxDecoration(
                    color: ColorsExt.grey6(context),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: ColorsExt.grey4(context),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      t.calendar.goToToday,
                      style: TextStyle(
                        fontSize: 17,
                        color: ColorsExt.grey2(context),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimension.bottomBarHeight),
            ],
          ),
        ],
      ),
    );
  }
}
