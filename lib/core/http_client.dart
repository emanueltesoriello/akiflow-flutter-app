import 'package:http/http.dart';
import 'package:mobile/core/preferences.dart';

class HttpClient extends BaseClient {
  final PreferencesRepository _preferences;

  final Client _inner;

  HttpClient(this._preferences) : _inner = Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    if (_preferences.getUser() != null) {
      request.headers['Authorization'] =
          "Bearer " + (_preferences.getUser()!.accessToken ?? '');
    }

    request.headers['Accept'] = "application/json";

    return _inner.send(request);
  }
}
