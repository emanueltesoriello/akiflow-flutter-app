import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
//import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/icon_badge.dart';
import 'package:mobile/src/base/ui/widgets/navbar/nav_item.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    Key? key,
    required this.labelStyle,
    required this.bottomBarIconSize,
    required this.topPadding,
  }) : super(key: key);

  final TextStyle labelStyle;
  final double bottomBarIconSize;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(builder: (context, taskState) {
      return Container(
        decoration: BoxDecoration(
          color: ColorsExt.background(context),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              offset: Offset(0, -1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: Dimension.bottomBarHeight,
              child: BlocBuilder<MainCubit, MainCubitState>(
                builder: (context, state) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NavItem(
                        active: false,
                        activeIconAsset: Assets.images.icons.common.menuSVG,
                        title: t.bottomBar.menu,
                        topPadding: topPadding,
                        badge: FutureBuilder<dynamic>(
                            //future: Intercom.instance.unreadConversationCount(),
                            builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return IconBadge(
                              snapshot.data,
                            );
                          }
                          return const SizedBox();
                        }),
                      ),
                      NavItem(
                        active: active(HomeViewType.inbox, state.homeViewType),
                        activeIconAsset: Assets.images.icons.common.traySVG,
                        title: t.bottomBar.inbox,
                        homeViewType: HomeViewType.inbox,
                        badge: IconBadge(List.from(taskState.inboxTasks).length),
                        topPadding: topPadding,
                      ),
                      NavItem(
                        active: active(HomeViewType.today, state.homeViewType),
                        activeIconAsset:
                            "assets/images/icons/_common/${DateFormat("dd").format(DateTime.now())}_square.svg",
                        title: t.bottomBar.today,
                        homeViewType: HomeViewType.today,
                        badge: IconBadge(taskState.todayCount),
                        topPadding: topPadding,
                      ),
                      NavItem(
                        active: active(HomeViewType.calendar, state.homeViewType),
                        activeIconAsset: "assets/images/icons/_common/calendar.svg",
                        title: t.bottomBar.calendar,
                        homeViewType: HomeViewType.calendar,
                        topPadding: topPadding,
                      ),
                      NavItem(
                        active: active(HomeViewType.availability, state.homeViewType),
                        activeIconAsset: Assets.images.icons.common.availabilitySVG,
                        title: "Availability",
                        homeViewType: HomeViewType.availability,
                        topPadding: topPadding,
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      );
    });
  }

  bool active(HomeViewType view, state) {
    return view == state;
  }
}
