import 'package:hrtz_hrms/core/api/base_api/api_helper.dart';
import 'package:hrtz_hrms/core/api/base_api/api_response.dart';
import 'package:hrtz_hrms/core/models/social_post_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

class SocialService {
  final ApiHelper _apiHelper = ApiHelper();
  final LoggingService _logger = LoggingService.instance;

  /// ➕ Create Social Post (Post/Poll/Event)
  Future<ApiResponse<Map<String, dynamic>>> createPost(SocialPostModel post) async {
    _logger.info('SOCIAL', 'Creating ${post.type}: ${post.title}');
    return await _apiHelper.post<Map<String, dynamic>>('event/addEvent', post.toJson());
  }

  /// 📜 Get Social Posts
  Future<ApiResponse<List<SocialPostModel>>> getPosts() async {
    _logger.info('SOCIAL', 'Fetching social posts');
    final response = await _apiHelper.get<dynamic>('event/getEvents');
    
    if (response.success && response.data != null) {
      try {
        List<dynamic> postsJson = [];
        if (response.data is Map<String, dynamic>) {
          // Changed to look for 'items' key based on the actual API response
          postsJson = response.data['items'] ?? response.data['message'] ?? response.data['data'] ?? [];
        } else if (response.data is List) {
          postsJson = response.data;
        }

        if (postsJson is! List) {
           postsJson = [];
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

  /// ❤️ Like/Unlike Post or 🗳️ Vote in Poll
  Future<ApiResponse<Map<String, dynamic>>> updateEvent({
    required String eventId,
    required Map<String, dynamic> body,
  }) async {
    return await _apiHelper.put<Map<String, dynamic>>('event/updateEvent/$eventId', body);
  }

  /// 💬 Add Comment
  Future<ApiResponse<Map<String, dynamic>>> addComment({
    required String eventId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    final body = {
      "action": "comment",
      "userId": userId,
      "userName": userName,
      "content": content
    };
    return await _apiHelper.put<Map<String, dynamic>>('event/updateEvent/$eventId', body);
  }

  /// 🗑️ Delete Event
  Future<ApiResponse<Map<String, dynamic>>> deletePost(String eventId) async {
    return await _apiHelper.delete<Map<String, dynamic>>('event/deleteEvent/$eventId');
  }

  /// 🗑️ Delete Comment
  Future<ApiResponse<Map<String, dynamic>>> deleteComment(String commentId) async {
    return await _apiHelper.delete<Map<String, dynamic>>('event/deleteComment/$commentId');
  }
}
