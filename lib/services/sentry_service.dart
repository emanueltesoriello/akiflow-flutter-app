import 'dart:io';

import 'package:http/http.dart';
import 'package:mobile/core/config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  Future<void> captureException(exception, {stackTrace}) async {
    if (Config.development) {
      throw exception;
    } else {
      if (SentryService.ignoreException(exception)) {
        print("ignoring exception: $exception");
        return;
      }

      await Sentry.captureException(exception, stackTrace: stackTrace);
    }
  }

  void authenticate(String uid, String? email) {
    print("auth sentry $uid");

    Sentry.configureScope(
      (scope) => scope.user = SentryUser(id: uid, email: email),
    );
  }

  static bool ignoreException(throwable) {
    print(throwable);

    if (throwable is StateError &&
        throwable.message
            .contains("Cannot emit new states after calling close")) {
      return true;
    }

    return throwable is SocketException ||
        throwable is OSError ||
        throwable is HandshakeException ||
        throwable is ClientException;
  }
}
