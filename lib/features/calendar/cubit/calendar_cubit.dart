import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarCubitState> {
  CalendarCubit() : super(const CalendarCubitState()) {
    _init();
  }

  _init() async {}
}
