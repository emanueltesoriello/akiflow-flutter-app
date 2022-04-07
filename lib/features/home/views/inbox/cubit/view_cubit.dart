import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'view_state.dart';

class InboxCubit extends Cubit<InboxCubitState> {
  InboxCubit() : super(const InboxCubitState()) {
    _init();
  }

  _init() async {}
}
