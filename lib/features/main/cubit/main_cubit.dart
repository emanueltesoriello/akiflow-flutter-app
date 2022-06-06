import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/user.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainCubitState> {
  final SentryService _sentryService = locator<SentryService>();

  final SyncCubit _syncCubit;
  final AuthCubit _authCubit;

  final StreamController<Label?> _labelCubitController = StreamController<Label?>.broadcast();
  Stream<Label?> get labelCubitStream => _labelCubitController.stream;

  MainCubit(this._syncCubit, this._authCubit) : super(const MainCubitState()) {
    _syncCubit.sync();
  }

  void changeHomeView(HomeViewType homeViewType) {
    emit(state.copyWith(homeViewType: homeViewType, selectedLabel: Nullable(null)));
  }

  void selectLabel(Label label) {
    emit(state.copyWith(lastHomeViewType: state.homeViewType));
    emit(state.copyWith(selectedLabel: Nullable(label), homeViewType: HomeViewType.label));
    _labelCubitController.add(label);
  }

  void onLoggedAppStart() {
    User? user = _authCubit.state.user;

    print("onLoggedAppStart user: ${user?.id}");

    if (user != null) {
      _sentryService.authenticate(user.id.toString(), user.email);
    }
  }
}
