import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:models/label/label.dart';

part 'label_state.dart';

class LabelCubit extends Cubit<LabelCubitState> {
  LabelCubit(Label label) : super(LabelCubitState(selectedLabel: label)) {
    _init();
  }

  _init() async {}
}
