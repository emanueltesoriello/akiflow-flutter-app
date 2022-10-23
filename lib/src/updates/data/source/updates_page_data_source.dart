import 'package:mobile/src/updates/domain/model/posts_filter_model.dart';
import 'package:mobile/src/updates/domain/model/posts_response.dart';

abstract class UpdatesPageDataSource {
  Future<PostsDetailResponse> getPosts(PostsFilterModel filters);
}
