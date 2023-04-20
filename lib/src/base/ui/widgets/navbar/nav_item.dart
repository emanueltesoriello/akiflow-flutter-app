import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/home/ui/cubit/today/today_cubit.dart';
import 'package:mobile/src/settings/ui/widgets/settings_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class NavItem extends StatelessWidget {
  final String activeIconAsset;
  final bool active;
  final String title;
  final HomeViewType? homeViewType;
  final Widget? badge;
  final double topPadding;

  const NavItem({
    Key? key,
    required this.activeIconAsset,
    required this.active,
    required this.title,
    required this.topPadding,
    this.homeViewType,
    this.badge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (homeViewType != null) {
            context.read<MainCubit>().changeHomeView(homeViewType!);

            if (homeViewType == HomeViewType.today) {
              DateTime now = DateTime.now();
              context.read<TodayCubit>().onDateSelected(now);
            }
          } else {
            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => SettingsModal(topPadding: topPadding),
            );
          }
        },
        child: Material(
          color: ColorsExt.background(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, Platform.isAndroid ? -3 : 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: SvgPicture.asset(
                        activeIconAsset,
                        color: color(context),
                        width: 26,
                        height: 26,
                      ),
                    )),
                    Flexible(
                      child: Text(title,
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              ?.copyWith(fontWeight: FontWeight.w500, color: color(context))),
                    ),
                  ],
                ),
              ),
              if (badge != null) Align(alignment: Alignment.topCenter, child: badge!),
            ],
          ),
        ),
      ),
    );
  }

  Color color(BuildContext context) {
    if (active) {
      return ColorsExt.akiflow(context);
    } else {
      return ColorsExt.grey2(context);
    }
  }
}
