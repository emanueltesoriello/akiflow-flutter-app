import 'package:http/http.dart';
import 'package:mobile/core/preferences.dart';
import 'package:models/user.dart';

class HttpClient extends BaseClient {
  final PreferencesRepository _preferences;

  final Client _inner;

  HttpClient(this._preferences) : _inner = Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    User? user = _preferences.user;

    if (user != null) {
      request.headers['Authorization'] = "Bearer ${user.accessToken ?? ''}";
    }

    request.headers['Content-Type'] = "application/json";

    return _inner.send(request);
  }
}
