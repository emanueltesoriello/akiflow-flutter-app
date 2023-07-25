import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/widgets/floating_button.dart';
import 'package:mobile/src/base/ui/widgets/navbar/bottom_nav_bar.dart';
import 'package:mobile/src/base/ui/widgets/task/bottom_task_actions.dart';
import 'package:mobile/src/home/ui/navigator/home_navigator.dart';
import 'package:mobile/src/home/ui/widgets/just_created_task_button.dart';
import 'package:mobile/src/home/ui/widgets/undo_button.dart';
import 'package:mobile/src/home/ui/widgets/webview.dart';
import 'package:mobile/src/onboarding/ui/cubit/onboarding_cubit.dart';
import 'package:mobile/src/onboarding/ui/pages/onboarding_tutorial.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key, required this.bottomBarHeight, required this.homeViewType});
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
            topPadding: MediaQuery.of(context).padding.top,
          ),
          body: Builder(builder: (context) {
            return const HomePageNavigator();
          }),
        ),
        BlocBuilder<TasksCubit, TasksCubitState>(
          builder: (context, state) {
            bool anyInboxSelected = state.inboxTasks.any((t) => t.selected ?? false);
            bool anyTodaySelected = state.selectedDayTasks.any((t) => t.selected ?? false);
            bool anyLabelsSelected = state.labelTasks.any((t) => t.selected ?? false);
            bool anyAllTaskSelected = state.allTasks.any((t) => t.selected ?? false);
            bool anySomedaySelected = state.somedayTasks.any((t) => t.selected ?? false);

            if (anyInboxSelected || anyTodaySelected || anyLabelsSelected || anyAllTaskSelected || anySomedaySelected) {
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
