import 'package:flutter/material.dart';
import 'package:hrtz_hrms/core/api/network/social_service.dart';
import 'package:hrtz_hrms/core/models/social_post_model.dart';
import 'package:hrtz_hrms/core/services/logger_service.dart';
import 'package:hrtz_hrms/core/services/local_storage_service.dart';

enum SocialState { initial, loading, loaded, error }

class SocialProvider with ChangeNotifier {
  final SocialService _socialService = SocialService();
  final LocalStorageService _localStorage = LocalStorageService();
  
  SocialState _state = SocialState.initial;
  SocialState get state => _state;

  List<SocialPostModel> _posts = [];
  List<SocialPostModel> get posts => _posts;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedType = 'all';
  String get selectedType => _selectedType;

  static const String _keySocialPosts = 'social_posts_cache';

  SocialProvider() {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // 1. Try to load from local cache first for instant UI
    await _loadFromCache();
    // 2. Fetch fresh posts in the background
    await fetchPosts(showLoader: _posts.isEmpty);
  }

  Future<void> _loadFromCache() async {
    final cachedData = await _localStorage.getJson(_keySocialPosts);
    if (cachedData != null) {
      try {
        final List<dynamic> list = cachedData as List;
        _posts = list.map((json) => SocialPostModel.fromJson(json)).toList();
        _state = SocialState.loaded;
        notifyListeners();
      } catch (e) {
        LoggingService.instance.error('SOCIAL', 'Error parsing cached posts', error: e);
      }
    }
  }

  Future<void> _saveToCache() async {
    final jsonList = _posts.map((post) => post.toJson()).toList();
    await _localStorage.saveJson(_keySocialPosts, jsonList);
  }

  void setSelectedType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  List<SocialPostModel> get filteredPosts {
    if (_selectedType == 'all') return _posts;
    return _posts.where((post) => post.type == _selectedType).toList();
  }

  Future<void> fetchPosts({bool showLoader = true}) async {
    if (showLoader) {
      _state = SocialState.loading;
      notifyListeners();
    }

    try {
      final response = await _socialService.getPosts();
      if (response.success) {
        _posts = response.data ?? [];
        _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        await _saveToCache();
        _state = SocialState.loaded;
      } else {
        _errorMessage = response.message;
        if (_posts.isEmpty) _state = SocialState.error;
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (_posts.isEmpty) _state = SocialState.error;
    }
    notifyListeners();
  }

  Future<bool> createPost(SocialPostModel post) async {
    try {
      final response = await _socialService.createPost(post);
      if (response.success) {
        await fetchPosts(showLoader: false);
        return true;
      }
      return false;
    } catch (e) {
      LoggingService.instance.error('SOCIAL', 'Error creating post', error: e);
      return false;
    }
  }

  Future<void> toggleLike(String eventId, String userId) async {
    final index = _posts.indexWhere((p) => p.id == eventId);
    if (index == -1) return;

    final post = _posts[index];
    final originalLikes = List<String>.from(post.likes);
    final newLikes = List<String>.from(post.likes);

    if (newLikes.contains(userId)) {
      newLikes.remove(userId);
    } else {
      newLikes.add(userId);
    }

    _posts[index] = _updatePostLikes(post, newLikes);
    notifyListeners();

    try {
      final body = {"action": "like", "userId": userId};
      final response = await _socialService.updateEvent(eventId: eventId, body: body);
      
      if (!response.success) {
        _posts[index] = _updatePostLikes(post, originalLikes);
        notifyListeners();
      } else {
        await _saveToCache();
      }
    } catch (e) {
      _posts[index] = _updatePostLikes(post, originalLikes);
      notifyListeners();
      LoggingService.instance.error('SOCIAL', 'Error toggling like', error: e);
    }
  }

  SocialPostModel _updatePostLikes(SocialPostModel post, List<String> newLikes) {
    return SocialPostModel(
      id: post.id,
      type: post.type,
      title: post.title,
      userName: post.userName,
      userId: post.userId,
      employeeName: post.employeeName,
      message: post.message,
      imageUrl: post.imageUrl,
      createdBy: post.createdBy,
      createdAt: post.createdAt,
      likes: newLikes,
      comments: post.comments,
      question: post.question,
      expiry: post.expiry,
      options: post.options,
      eventDate: post.eventDate,
    );
  }

  Future<void> addComment(String eventId, String userId, String userName, String content) async {
    try {
      final response = await _socialService.addComment(
        eventId: eventId,
        userId: userId,
        userName: userName,
        content: content,
      );
      if (response.success) {
        await fetchPosts(showLoader: false);
      }
    } catch (e) {
      LoggingService.instance.error('SOCIAL', 'Error adding comment', error: e);
    }
  }

  Future<void> vote(String eventId, String optionId, String userId) async {
    try {
      final body = {
        "action": "vote",
        "optionId": optionId,
        "userId": userId
      };
      final response = await _socialService.updateEvent(eventId: eventId, body: body);
      if (response.success) {
        await fetchPosts(showLoader: false);
      }
    } catch (e) {
      LoggingService.instance.error('SOCIAL', 'Error voting', error: e);
    }
  }

  Future<bool> deletePost(String eventId) async {
    try {
      final response = await _socialService.deletePost(eventId);
      if (response.success) {
        _posts.removeWhere((post) => post.id == eventId);
        await _saveToCache();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      LoggingService.instance.error('SOCIAL', 'Error deleting post', error: e);
      return false;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      final response = await _socialService.deleteComment(commentId);
      if (response.success) {
        await fetchPosts(showLoader: false);
        return true;
      }
      return false;
    } catch (e) {
      LoggingService.instance.error('SOCIAL', 'Error deleting comment', error: e);
      return false;
    }
  }
}
