import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';

part 'inbox_view_state.dart';

class InboxCubit extends Cubit<InboxCubitState> {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

  InboxCubit() : super(const InboxCubitState()) {
    _init();
  }

  _init() async {
    bool inboxNoticeHidden = _preferencesRepository.inboxNoticeHidden;

    if (inboxNoticeHidden == false) {
      emit(state.copyWith(showInboxNotice: true));
    }
  }

  void inboxNoticeClosed() {
    emit(state.copyWith(showInboxNotice: false));
    _preferencesRepository.setInboxNoticeHidden(true);
  }
}
