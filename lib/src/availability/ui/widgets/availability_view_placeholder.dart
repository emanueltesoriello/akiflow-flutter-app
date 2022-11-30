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
    return Center(
      child: RefreshIndicator(
        onRefresh: () => context.read<AvailabilityCubit>().getAvailabilities(),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(12.0),
          children: [
            const SizedBox(
              height: 80,
            ),
            SvgPicture.asset(
              Assets.images.icons.common.noActiveLinksSVG,
              width: 130,
              height: 130,
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                const Text(
                  "No active links to show",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "To create a link use the desktop app",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: ColorsExt.grey3(context),
                  ),
                ),
              ],
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
            const SizedBox(height: bottomBarHeight),
          ],
        ),
      ),
    );
  }
}
