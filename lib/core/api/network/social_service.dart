import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/models/social_post_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class SocialService {
  final ApiHelper _apiHelper = ApiHelper(baseUrl: ApiHelper.otherBaseUrl);
  final LoggingService _logger = LoggingService.instance;

  /// ➕ Create Social Post
  Future<ApiResponse<Map<String, dynamic>>> createPost(SocialPostModel post) async {
    _logger.info('SOCIAL', 'Creating post: ${post.title}');
    // Changed endpoint from 'social/create' to 'social/add-post' as previous ones returned 404
    return await _apiHelper.post<Map<String, dynamic>>('social/add-post', post.toJson());
  }

  /// 📜 Get Social Posts
  Future<ApiResponse<List<SocialPostModel>>> getPosts() async {
    _logger.info('SOCIAL', 'Fetching social posts');
    
    final response = await _apiHelper.get<dynamic>('social/list');
    
    if (response.success && response.data != null) {
      try {
        List<dynamic> postsJson = [];
        
        if (response.data is Map<String, dynamic>) {
          postsJson = response.data['message'] ?? response.data['data'] ?? [];
        } else if (response.data is List) {
          postsJson = response.data;
        } else if (response.data is String) {
          _logger.warning('SOCIAL', 'Server returned placeholder string: ${response.data}');
          return ApiResponse.success([]);
        } else {
          _logger.error('SOCIAL', 'Unexpected data format: ${response.data.runtimeType}');
          return ApiResponse.success([]);
        }

        if (postsJson is String) {
           return ApiResponse.success([]);
        }

        final posts = postsJson.map((json) => SocialPostModel.fromJson(json)).toList();
        return ApiResponse.success(posts);
      } catch (e) {
        _logger.error('SOCIAL', 'Error parsing posts', error: e);
        return ApiResponse.error('Failed to parse posts');
      }
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch posts');
  }

  /// ❤️ Like/Unlike Post
  Future<ApiResponse<Map<String, dynamic>>> toggleLike({
    required String postId,
    required String employeeId,
  }) async {
    final body = {"postId": postId, "employeeId": employeeId};
    return await _apiHelper.post<Map<String, dynamic>>('social/like', body);
  }

  /// 💬 Add Comment
  Future<ApiResponse<Map<String, dynamic>>> addComment({
    required String postId,
    required String employeeId,
    required String userName,
    required String comment,
  }) async {
    final body = {
      "postId": postId,
      "employeeId": employeeId,
      "userName": userName,
      "comment": comment
    };
    return await _apiHelper.post<Map<String, dynamic>>('social/comment', body);
  }

  /// 🗑️ Delete Post
  Future<ApiResponse<Map<String, dynamic>>> deletePost(String postId) async {
    return await _apiHelper.delete<Map<String, dynamic>>('social/delete/$postId');
  }
}
