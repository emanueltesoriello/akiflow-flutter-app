import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/availability/di/availability_providers.dart';
import 'package:mobile/src/availability/ui/pages/availability_view.dart';
import 'package:mobile/src/base/ui/widgets/custom_navigator_pop_scope.dart';


final _availabilityNavigationKey = GlobalKey<NavigatorState>();

class AvailabilityNavigatorPage extends StatelessWidget {
  const AvailabilityNavigatorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: availabilityProviders,
      child: Builder(
        builder: ((context) {
          //var state = context.watch<AvailabilityCubit>().state;
          return CustomNavigatorPopScope(
            navigatorStateKey: _availabilityNavigationKey,
            pages: const [
              /* if (state.navigationState == AvailabilityNavigationState.loading ||
                  state.navigationState == AvailabilityNavigationState.mainPage)
                const MaterialPage(
                  key: ValueKey('LoadingAvailabilityPage'),
                  child: Scaffold(body: Center(child: Text('Loading'))),
                ),
              if (state.navigationState == AvailabilityNavigationState.mainPage)*/
              MaterialPage(
                key: ValueKey('AvailabilityView'),
                child: AvailabilityView(),
              ),
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
