import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/calendar/ui/models/navigation_state.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarCubitState> {
  CalendarCubit() : super(const CalendarCubitState()) {
    _init();
  }

  _init() async {
    //TODO to simulate an async Func just change the seconds
    await Future.delayed(const Duration(seconds: 0), () {
      print('Example loading operation');
      emit(state.copyWith(navigationState: CalendarNavigationState.mainPage));
    });
  }

  //N.B. When we need to get access to the state of other BlocProviders we can get access to them declaring streams that listen their states.
}
