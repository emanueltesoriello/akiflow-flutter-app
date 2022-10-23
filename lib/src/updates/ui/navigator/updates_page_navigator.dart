import 'package:flutter/material.dart';
import 'package:mobile/src/updates/ui/pages/updates_page.dart';
import 'package:mobile/src/updates/ui/widget/custom_navigator_pop_scope.dart';
import 'package:provider/provider.dart';

import '../../di/updates_page_providers.dart';
import '../model/updates_page_navigation_state.dart';
import '../viewmodel/updates_page_view_model_main.dart';

final _updatesPageNavigationKey = GlobalKey<NavigatorState>();

class UpdatesPageNavigator extends StatefulWidget {
  final Function()? onMainPop;

  const UpdatesPageNavigator({
    required this.onMainPop,
  });

  @override
  _UpdatesPageNavigatorState createState() => _UpdatesPageNavigatorState();
}

class _UpdatesPageNavigatorState extends State<UpdatesPageNavigator> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: updatePageProviders,
      child: Consumer<UpdatesPageViewModelMain>(
        builder: (_, viewModel, __) {
          return CustomNavigatorPopScope(
            navigatorStateKey: _updatesPageNavigationKey,
            pages: [
              MaterialPage(
                child: UpdatesPage(
                  viewModel: viewModel,
                  onPop: widget.onMainPop,
                ),
              ),
            ],
            onPopPage: (route, result) {
              viewModel.updatesNavigationState = UpdatesPageNavigationState.baseUpdatesPage;
              return false;
            },
          );
        },
      ),
    );
  }
}
