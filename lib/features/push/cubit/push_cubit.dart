import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/push_notification_service.dart';
import 'package:models/user.dart';

part 'push_state.dart';

class PushCubit extends Cubit<PushCubitState> {
  // ignore: unused_field
  final PushNotificationService _pushNotificationService = locator<PushNotificationService>();

  PushCubit() : super(const PushCubitState()) {
    _init();
  }

  _init() async {}

  login(User user) async {}

  logout() async {}
}
