part of 'dialog_cubit.dart';

abstract class DialogState {
  const DialogState();
}

class DialogInitial extends DialogState {}

class DialogShowMessage extends DialogState {
  final DialogAction action;

  const DialogShowMessage({
    required this.action,
  });
}
