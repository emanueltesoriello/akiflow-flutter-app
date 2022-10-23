import 'package:dio/dio.dart';
import 'package:mobile/src/updates/domain/model/posts_filter_model.dart';
import 'package:mobile/src/updates/domain/model/posts_response.dart';

import 'updates_page_data_source.dart';

class UpdatesPageDataSourceImpl extends UpdatesPageDataSource {
  final Dio _dio;

  UpdatesPageDataSourceImpl(this._dio);

  Future<PostsDetailResponse> getPosts(PostsFilterModel filters) async {
    try {
      Map<String, dynamic> temporaryFilters = {"pageNumber": filters.pageNumber, "totalPerPage": filters.totalPerPage};
      final Response response = await _dio
          .get("https://31cae3b4-9771-4151-bdb2-41437d3b17ec.mock.pstmn.io/v1/posts", queryParameters: temporaryFilters)
          .catchError((e) {
        print(e);
      });
      PostsDetailResponse posts = PostsDetailResponse.fromJson(response.data); //response.data);
      return posts;
    } catch (error, stack) {
      print(error);
      print(stack);
      return Future.error(error);
    }
  }
}
