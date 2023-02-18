import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/widgets/custom_navigator_pop_scope.dart';
import 'package:mobile/src/calendar/di/calendar_providers.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/calendar/ui/models/navigation_state.dart';
import 'package:mobile/src/calendar/ui/pages/calendar_view.dart';

final _calendarNavigationKey = GlobalKey<NavigatorState>();

class CalendarNavigatorPage extends StatelessWidget {
  const CalendarNavigatorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: calendarProviders,
      child: Builder(
        builder: ((context) {
          //var state = context.watch<CalendarCubit>().state;
          return CustomNavigatorPopScope(
            navigatorStateKey: _calendarNavigationKey,
            pages: const [
              MaterialPage(
                key: ValueKey('CalendarView'),
                child: CalendarView(),
              ),
              // if (state.navigationState == CalendarNavigationState.loading)
              //   const MaterialPage(
              //     key: ValueKey('StartPage'),
              //     child: Scaffold(body: Center(child: Text('Loading'))),
              //   ),
              // if (state.navigationState == CalendarNavigationState.mainPage)
              //   const MaterialPage(
              //     key: ValueKey('CalendarView'),
              //     child: CalendarView(),
              //   ),
            ],
            onPopPage: (route, result) {
              //Handle the Main onPop here
              return false;
            },
          );
        }),
      ),
    );
  }
}
