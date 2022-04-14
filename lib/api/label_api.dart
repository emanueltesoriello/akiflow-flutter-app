import 'package:mobile/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/label/label.dart';

class LabelApi extends Api {
  LabelApi()
      : super(
          Uri.parse(Config.endpoint + "/v3/labels"),
          fromMap: Label.fromMap,
        );

  @override
  Future<List<Label>> get<Label>({
    int perPage = 2500,
    bool withDeleted = true,
    DateTime? updatedAfter,
    bool allPages = false,
  }) async {
    return await super.get<Label>(
      perPage: perPage,
      withDeleted: withDeleted,
      updatedAfter: updatedAfter,
      allPages: allPages,
    );
  }

  @override
  Future<List<Label>> post<Label>({required List<Label> unsynced}) async {
    return (await super.post(
      unsynced: unsynced,
    ));
  }
}
