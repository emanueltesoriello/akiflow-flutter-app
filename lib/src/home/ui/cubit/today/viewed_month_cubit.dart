import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';

part 'viewed_month_state.dart';

class ViewedMonthCubit extends Cubit<ViewedMonthState> {
  late final TasksCubit tasksCubit;

  ViewedMonthCubit() : super(const ViewedMonthState());

  updateViewedMonth(int? newMonth) {
    emit(state.copyWith(viewedMonth: newMonth));
  }
}
