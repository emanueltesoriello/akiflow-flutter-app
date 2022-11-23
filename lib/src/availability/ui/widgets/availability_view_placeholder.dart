import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';

import '../../../../common/style/colors.dart';

class AvailabilityViewPlaceholder extends StatelessWidget {
  const AvailabilityViewPlaceholder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            Assets.images.icons.common.noActiveLinksSVG,
            width: 130,
            height: 130,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
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
                      "To create a link use  the desktop app",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        color: ColorsExt.grey3(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Material(
            borderRadius: BorderRadius.circular(4),
            color: ColorsExt.grey6(context),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                context.read<MainCubit>().changeHomeView(HomeViewType.today);
              },
              child: Container(
                width: 114,
                height: 36,
                decoration: BoxDecoration(
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
          ),
          const SizedBox(height: bottomBarHeight),
        ],
      ),
    );
  }
}
