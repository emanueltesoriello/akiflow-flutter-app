import 'dart:async';

class Debouncer {
  static Timer? _timer;

  static process({
    required Function ifNotCancelled,
  }) {
    _timer?.cancel();

    _timer = Timer(const Duration(seconds: 2), () async {
      ifNotCancelled();
    });
  }

  cancel() {
    _timer?.cancel();
  }
}
