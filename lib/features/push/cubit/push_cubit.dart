import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/services/push_notification_service.dart';
import 'package:models/user.dart';

part 'push_state.dart';

class PushCubit extends Cubit<PushCubitState> {
  final PushNotificationService _pushNotificationService = locator<PushNotificationService>();

  PushCubit() : super(const PushCubitState()) {
    _init();
  }

  _init() async {
    await _pushNotificationService.start();
  }

  login(User user) async {
    await _pushNotificationService.updateUserId(user);
  }

  logout() async {
    await _pushNotificationService.stop();
  }
}
