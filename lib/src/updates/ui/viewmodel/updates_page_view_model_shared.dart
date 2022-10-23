import 'package:flutter/material.dart';
import 'package:mobile/src/updates/domain/model/post_model_response.dart';
import 'package:mobile/src/updates/domain/model/posts_filter_model.dart';

import '../../domain/updates_page_repository.dart';
import '../model/updates_page_navigation_state.dart';

part 'updates_page_view_model.dart';

mixin UpdatesPageViewModelShared on ChangeNotifier {
  late UpdatesPageRepository updatesPageRepository;
  Function(String)? showSnackBar;
  bool _showPageLoader = true;

  UpdatesPageNavigationState _updatesNavigationState = UpdatesPageNavigationState.baseUpdatesPage;

  UpdatesPageNavigationState get updatesNavigationState => _updatesNavigationState;

  set updatesNavigationState(UpdatesPageNavigationState newState) {
    _updatesNavigationState = newState;
    notifyListeners();
  }

  bool get showPageLoader => _showPageLoader;

  set showPageLoader(bool value) {
    _showPageLoader = value;
    notifyListeners();
  }

  void update(
    UpdatesPageRepository repository,
  ) {
    updatesPageRepository = repository;
  }
}
