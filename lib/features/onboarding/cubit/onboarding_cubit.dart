import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/repository/accounts_repository.dart';
import 'package:models/account/account.dart';

part 'onboarding_state.dart';

enum OnboardingNextAction { none, reset, next, close }

class OnboardingCubit extends Cubit<OnboardingCubitState> {
  static const int onboardingSteps = 3;

  static final AccountsRepository _accountsRepository = locator<AccountsRepository>();

  OnboardingCubit() : super(const OnboardingCubitState()) {
    _getGmailAccounts();
  }

  void _getGmailAccounts() async {
    List<Account> accounts = await _accountsRepository.get();

    List<Account> gmailAccounts =
        accounts.where((account) => account.connectorId == "gmail" && account.deletedAt == null).toList();

    emit(state.copyWith(gmailAccounts: gmailAccounts));
  }

  void back() {
    if (state.page == 0) {
      return;
    }

    emit(state.copyWith(page: state.page - 1));

    next(reset: true);
  }

  OnboardingNextAction next({bool reset = false}) {
    if (state.page == onboardingSteps + 1) {
      return OnboardingNextAction.none;
    }

    if (reset == false) {
      emit(state.copyWith(page: state.page + 1));
    } else {
      return OnboardingNextAction.reset;
    }

    if (state.page == onboardingSteps + 1) {
      emit(state.copyWith(show: false));
      return OnboardingNextAction.close;
    } else {
      return OnboardingNextAction.next;
    }
  }

  void skipAll() {
    emit(state.copyWith(show: false));
  }
}
