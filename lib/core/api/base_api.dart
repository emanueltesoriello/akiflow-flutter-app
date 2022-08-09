abstract class IBaseApi {
  Future<List<T>> getItems<T>({
    int perPage = 2500,
    bool withDeleted = true,
    DateTime? updatedAfter,
    bool allPages = false,
  });

  Future<List<T>> postUnsynced<T>({
    required List<T> unsynced,
  });
}
