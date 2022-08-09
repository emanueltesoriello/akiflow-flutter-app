abstract class IBaseDatabaseRepository {
  Future<List<T>> get<T>();

  Future<T?> getById<T>(id);
  
  Future<List<T>> getByIds<T>(List<String> ids);

  Future<List<Object?>> add<T>(List<T> items);

  Future<void> updateById<T>(String? id, {required T data});

  Future<void> setFieldByName<T>(String? id, {required String field, required T value});

  Future<List<T>> unsynced<T>();

  Future<T> byId<T>(String id);
}
