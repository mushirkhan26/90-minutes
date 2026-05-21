import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/local_storage_service.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';
import 'dart:convert';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final LocalStorageService _localStorage = LocalStorageService();
  static const String _wishlistKey = 'cached_wishlist';

  WishlistBloc() : super(WishlistInitial()) {
    on<LoadWishlist>(_onLoadWishlist);
    on<ToggleWishlist>(_onToggleWishlist);
    on<ClearWishlist>(_onClearWishlist);
  }

  Future<void> _onLoadWishlist(LoadWishlist event, Emitter<WishlistState> emit) async {
    emit(WishlistLoading());
    try {
      final jsonStr = await _localStorage.getString(_wishlistKey);
      if (jsonStr != null) {
        final List<dynamic> list = jsonDecode(jsonStr);
        final items = list.map((j) => ProductModel.fromJson(j)).toList();
        emit(WishlistLoaded(items));
      } else {
        emit(const WishlistLoaded([]));
      }
    } catch (e) {
      emit(const WishlistError('Failed to load wishlist'));
    }
  }

  Future<void> _onToggleWishlist(ToggleWishlist event, Emitter<WishlistState> emit) async {
    if (state is WishlistLoaded) {
      final currentItems = List<ProductModel>.from((state as WishlistLoaded).items);
      final index = currentItems.indexWhere((i) => i.id == event.product.id);
      
      if (index != -1) {
        currentItems.removeAt(index);
      } else {
        currentItems.add(event.product);
      }

      await _localStorage.saveString(_wishlistKey, jsonEncode(currentItems.map((i) => i.toJson()).toList()));
      emit(WishlistLoaded(currentItems));
    }
  }

  Future<void> _onClearWishlist(ClearWishlist event, Emitter<WishlistState> emit) async {
    await _localStorage.removeString(_wishlistKey);
    emit(const WishlistLoaded([]));
  }
}
