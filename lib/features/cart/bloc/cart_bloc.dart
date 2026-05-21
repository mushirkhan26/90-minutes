import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/cart_model.dart';
import '../../../core/services/local_storage_service.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import 'dart:convert';

class CartBloc extends Bloc<CartEvent, CartState> {
  final LocalStorageService _localStorage = LocalStorageService();
  static const String _cartKey = 'cached_cart';

  CartBloc() : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cartJson = await _localStorage.getString(_cartKey);
      if (cartJson != null) {
        final cart = CartModel.fromJson(jsonDecode(cartJson));
        emit(CartLoaded(cart));
      } else {
        emit(CartLoaded(CartModel.empty()));
      }
    } catch (e) {
      emit(const CartError('Failed to load cart'));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      final currentCart = (state as CartLoaded).cart;
      final List<CartItem> updatedItems = List.from(currentCart.items);
      
      final index = updatedItems.indexWhere((i) => i.productId == event.item.productId);
      if (index != -1) {
        final existingItem = updatedItems[index];
        updatedItems[index] = CartItem(
          productId: existingItem.productId,
          productName: existingItem.productName,
          productImage: existingItem.productImage,
          quantity: existingItem.quantity + event.item.quantity,
          price: existingItem.price,
        );
      } else {
        updatedItems.add(event.item);
      }

      final updatedCart = _calculateCart(updatedItems);
      await _saveCart(updatedCart);
      emit(CartLoaded(updatedCart));
    }
  }

  Future<void> _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      final currentCart = (state as CartLoaded).cart;
      final updatedItems = currentCart.items.where((i) => i.productId != event.productId).toList();
      
      final updatedCart = _calculateCart(updatedItems);
      await _saveCart(updatedCart);
      emit(CartLoaded(updatedCart));
    }
  }

  Future<void> _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      final currentCart = (state as CartLoaded).cart;
      final updatedItems = currentCart.items.map((i) {
        if (i.productId == event.productId) {
          return CartItem(
            productId: i.productId,
            productName: i.productName,
            productImage: i.productImage,
            quantity: event.quantity,
            price: i.price,
          );
        }
        return i;
      }).where((i) => i.quantity > 0).toList();

      final updatedCart = _calculateCart(updatedItems);
      await _saveCart(updatedCart);
      emit(CartLoaded(updatedCart));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    final emptyCart = CartModel.empty();
    await _saveCart(emptyCart);
    emit(CartLoaded(emptyCart));
  }

  CartModel _calculateCart(List<CartItem> items) {
    double subtotal = 0;
    for (var item in items) {
      subtotal += item.total;
    }
    double deliveryFee = subtotal > 500 ? 0 : 40;
    double tax = subtotal * 0.12; // 12% GST example

    return CartModel(
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      tax: tax,
    );
  }

  Future<void> _saveCart(CartModel cart) async {
    await _localStorage.saveString(_cartKey, jsonEncode(cart.toJson()));
  }
}
