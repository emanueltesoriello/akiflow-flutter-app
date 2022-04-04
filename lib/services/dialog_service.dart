import 'dart:async';

class DialogAction {
  String title;
  String? content;
  String? confirmTitle;
  String? dismissTitle;
  Function()? confirm;
  Function()? dismiss;

  DialogAction(this.title,
      {this.confirm,
      this.dismiss,
      this.confirmTitle,
      this.content,
      this.dismissTitle});
}

class DialogService {
  final StreamController<DialogAction> _dialogStreamController =
      StreamController.broadcast();

  Stream<DialogAction> get dialogStream => _dialogStreamController.stream;

  DialogService();

  void showMessage(String message,
      {Function()? confirm, Function()? dismiss, String? confirmTitle}) {
    _dialogStreamController.add(DialogAction(
      message,
      confirm: confirm,
      confirmTitle: confirmTitle,
      dismiss: dismiss,
    ));
  }

  void showMessageWithAction(DialogAction dialogAction) {
    _dialogStreamController.add(dialogAction);
  }

  void showGenericError() {
    _dialogStreamController.add(DialogAction("Errore generico, riprova!"));
  }

  Future<void> close() async {
    await _dialogStreamController.close();
  }

  void showAuthError() {
    _dialogStreamController
        .add(DialogAction("Autenticazione non riuscita, riprova!"));
  }

  void showNoInternet() {
    _dialogStreamController.add(DialogAction(
        "Connessione a internet non disponibile, riprova più tardi"));
  }

  void showNoPermission() {
    _dialogStreamController.add(DialogAction(
        "Non hai i permessi necessari per accedere a questa funzionalità"));
  }
}
