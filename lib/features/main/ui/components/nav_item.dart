import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../../common/style/colors.dart';
import '../../../settings/ui/settings_modal.dart';
import '../../cubit/main_cubit.dart';

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
    Color color;

    if (active) {
      color = ColorsExt.akiflow(context);
    } else {
      color = ColorsExt.grey2(context);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (homeViewType != null) {
            context.read<MainCubit>().changeHomeView(homeViewType!);
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
                        color: color,
                        width: 26,
                        height: 26,
                      ),
                    )),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
                      ),
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
}
