import 'package:sembast/sembast.dart';

abstract class LocalStorageRepository {}

class LocalStorageRepositoryImpl implements LocalStorageRepository {
  final Database database;

  LocalStorageRepositoryImpl(this.database);
}
