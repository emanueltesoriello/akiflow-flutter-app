import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/services/dialog_service.dart';

part 'dialog_state.dart';

class DialogCubit extends Cubit<DialogState> {
  final DialogService _dialogService = locator<DialogService>();

  DialogCubit() : super(DialogInitial()) {
    _dialogService.dialogStream.listen((action) {
      emit(DialogShowMessage(action: action));
    });
  }

  @override
  Future<void> close() async {
    await _dialogService.close();
    return super.close();
  }
}
