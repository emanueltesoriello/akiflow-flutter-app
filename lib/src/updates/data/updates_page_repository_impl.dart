import 'package:mobile/src/updates/domain/model/posts_filter_model.dart';
import 'package:mobile/src/updates/domain/model/posts_response.dart';

import '../domain/updates_page_repository.dart';
import 'source/updates_page_data_source.dart';

class UpdatesPageRepositoryImpl extends UpdatesPageRepository {
  final UpdatesPageDataSource _updatesPageRemoteDataSource;

  UpdatesPageRepositoryImpl(this._updatesPageRemoteDataSource);

  Future<PostsDetailResponse> getPosts(PostsFilterModel filters) => _updatesPageRemoteDataSource.getPosts(filters);
}
