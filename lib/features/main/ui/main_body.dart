import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/components/task/bottom_task_actions.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/main/ui/bottom_nav_bar.dart';

import '../../../common/style/colors.dart';
import '../../calendar/ui/calendar_view.dart';
import '../../inbox/ui/inbox_view.dart';
import '../../label/ui/label_view.dart';
import '../../onboarding/cubit/onboarding_cubit.dart';
import '../../onboarding/ui/onboarding_tutorial.dart';
import '../../tasks/tasks_cubit.dart';
import '../../today/ui/today_view.dart';
import 'components/floating_button.dart';
import 'just_created_task_button.dart';
import 'undo_button.dart';
import 'webview.dart';

class MainBody extends StatelessWidget {
  const MainBody({super.key, required this.bottomBarHeight, required this.homeViewType});
  final double bottomBarHeight;
  final int homeViewType;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const InternalWebView(),
        Scaffold(
          extendBodyBehindAppBar: true,
          floatingActionButton: FloatingButton(bottomBarHeight: bottomBarHeight),
          bottomNavigationBar: CustomBottomNavigationBar(
            labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey2(context)),
            bottomBarIconSize: 30,
            topPadding: MediaQuery.of(context).padding.top,
          ),
          body: Builder(builder: (context) {
            if (homeViewType < 4) {
              return IndexedStack(
                index: homeViewType,
                children: const [
                  InboxView(),
                  TodayView(),
                  CalendarView(),
                ],
              );
            }
            return const LabelView();
          }),
        ),
        BlocBuilder<TasksCubit, TasksCubitState>(
          builder: (context, state) {
            bool anyInboxSelected = state.inboxTasks.any((t) => t.selected ?? false);
            bool anyTodaySelected = state.selectedDayTasks.any((t) => t.selected ?? false);
            bool anyLabelsSelected = state.labelTasks.any((t) => t.selected ?? false);

            if (anyInboxSelected || anyTodaySelected || anyLabelsSelected) {
              return const Align(
                alignment: Alignment.bottomCenter,
                child: BottomTaskActions(),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
        const UndoBottomView(),
        const JustCreatedTaskView(),
        BlocBuilder<OnboardingCubit, OnboardingCubitState>(
          builder: (context, state) {
            if (state.show) {
              return const OnboardingTutorial();
            } else {
              return const SizedBox();
            }
          },
        ),
      ],
    );
  }
}
