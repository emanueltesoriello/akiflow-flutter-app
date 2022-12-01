import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../ui/cubit/availability_cubit.dart';

List<BlocProvider> availabilityProviders = [
  BlocProvider<AvailabilityCubit>(
    lazy: false,
    create: (BuildContext context) => AvailabilityCubit(),
  ),
];
