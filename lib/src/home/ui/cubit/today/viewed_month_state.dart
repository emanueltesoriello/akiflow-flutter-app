part of 'viewed_month_cubit.dart';

class ViewedMonthState extends Equatable {
  final int? viewedMonth;

  const ViewedMonthState({this.viewedMonth});

  ViewedMonthState copyWith({int? viewedMonth}) {
    return ViewedMonthState(viewedMonth: viewedMonth ?? this.viewedMonth);
  }

  @override
  List<Object?> get props => [viewedMonth];
}
