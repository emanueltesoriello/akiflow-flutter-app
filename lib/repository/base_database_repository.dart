abstract class IBaseDatabaseRepository {
  Future<List<T>> get<T>();

  Future<void> updateById<T>(String? id, {required T data});

  Future<List<T>> unsynced<T>();

  Future<T> byId<T>(String id);
}
