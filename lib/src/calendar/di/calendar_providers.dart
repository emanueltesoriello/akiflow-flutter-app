import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';

List<BlocProvider> calendarProviders = [
  BlocProvider<CalendarCubit>(
    lazy: false,
    create: (BuildContext context) => CalendarCubit(),
  ),
];
