import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';

import '../../../common/style/colors.dart';

class HomeViewPlaceholder extends StatelessWidget {
  const HomeViewPlaceholder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/akiflow/calendar-placeholder.svg",
            width: 130,
            height: 130,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  t.calendar.comingSoon,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
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
