import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/social_service.dart';
import 'package:hrtz_hrms/core/models/social_post_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';

enum SocialState { initial, loading, loaded, error }

class SocialProvider with ChangeNotifier {
  final SocialService _socialService = SocialService();
  
  SocialState _state = SocialState.initial;
  SocialState get state => _state;

  List<SocialPostModel> _posts = [];
  List<SocialPostModel> get posts => _posts;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedType = 'all';
  String get selectedType => _selectedType;

  void setSelectedType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  List<SocialPostModel> get filteredPosts {
    if (_selectedType == 'all') return _posts;
    return _posts.where((post) => post.type == _selectedType).toList();
  }

  Future<void> fetchPosts() async {
    _state = SocialState.loading;
    notifyListeners();

    try {
      final response = await _socialService.getPosts();
      if (response.success) {
        _posts = response.data ?? [];
        _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _state = SocialState.loaded;
      } else {
        _errorMessage = response.message;
        _state = SocialState.error;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = SocialState.error;
    }
    notifyListeners();
  }

  Future<bool> createPost(SocialPostModel post) async {
    try {
      final response = await _socialService.createPost(post);
      if (response.success) {
        await fetchPosts();
        return true;
      }
      return false;
    } catch (e) {
      LoggingService.instance.error('SOCIAL', 'Error creating post', error: e);
      return false;
    }
  }

  Future<void> toggleLike(String postId, String employeeId) async {
    try {
      await _socialService.toggleLike(postId: postId, employeeId: employeeId);
      // Optimistic update
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final newLikes = List<String>.from(post.likes);
        if (newLikes.contains(employeeId)) {
          newLikes.remove(employeeId);
        } else {
          newLikes.add(employeeId);
        }
        _posts[index] = SocialPostModel(
          id: post.id,
          type: post.type,
          title: post.title,
          employeeName: post.employeeName,
          message: post.message,
          imageUrl: post.imageUrl,
          createdBy: post.createdBy,
          createdAt: post.createdAt,
          likes: newLikes,
          comments: post.comments,
        );
        notifyListeners();
      }
    } catch (e) {
      LoggingService.instance.error('SOCIAL', 'Error toggling like', error: e);
    }
  }

  Future<void> addComment(String postId, String employeeId, String userName, String comment) async {
    try {
      final response = await _socialService.addComment(
        postId: postId,
        employeeId: employeeId,
        userName: userName,
        comment: comment,
      );
      if (response.success) {
        await fetchPosts();
      }
    } catch (e) {
      LoggingService.instance.error('SOCIAL', 'Error adding comment', error: e);
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      final response = await _socialService.deletePost(postId);
      if (response.success) {
        _posts.removeWhere((post) => post.id == postId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      LoggingService.instance.error('SOCIAL', 'Error deleting post', error: e);
      return false;
    }
  }
}
