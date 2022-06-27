import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/base/icon_badge.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/main/ui/main_page.dart';
import 'package:mobile/features/main/ui/nav_item.dart';
import 'package:mobile/style/colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    Key? key,
    required this.labelStyle,
    required this.bottomBarIconSize,
    required this.inboxTasksCount,
    required this.fixedTodoTodayTasksCount,
    required this.topPadding,
  }) : super(key: key);

  final TextStyle labelStyle;
  final double bottomBarIconSize;
  final int inboxTasksCount;
  final int fixedTodoTodayTasksCount;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
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
        children: [
          SizedBox(
            height: bottomBarHeight,
            child: BlocBuilder<MainCubit, MainCubitState>(
              builder: (context, state) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NavItem(
                      active: false,
                      activeIconAsset: "assets/images/icons/_common/menu.svg",
                      title: t.bottomBar.menu,
                      topPadding: topPadding,
                      badge: FutureBuilder<dynamic>(
                          future: Intercom.instance.unreadConversationCount(),
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
                      active: state.homeViewType == HomeViewType.inbox,
                      activeIconAsset: "assets/images/icons/_common/tray.svg",
                      title: t.bottomBar.inbox,
                      homeViewType: HomeViewType.inbox,
                      badge: IconBadge(inboxTasksCount),
                      topPadding: topPadding,
                    ),
                    NavItem(
                      active: state.homeViewType == HomeViewType.today,
                      activeIconAsset:
                          "assets/images/icons/_common/${DateFormat("dd").format(DateTime.now())}_square.svg",
                      title: t.bottomBar.today,
                      homeViewType: HomeViewType.today,
                      badge: IconBadge(fixedTodoTodayTasksCount),
                      topPadding: topPadding,
                    ),
                    NavItem(
                      active: state.homeViewType == HomeViewType.calendar,
                      activeIconAsset: "assets/images/icons/_common/calendar.svg",
                      title: t.bottomBar.calendar,
                      homeViewType: HomeViewType.calendar,
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
  }
}
