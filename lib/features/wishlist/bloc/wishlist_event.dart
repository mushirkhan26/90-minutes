import 'package:equatable/equatable.dart';
import '../../../core/models/product_model.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWishlist extends WishlistEvent {}

class ToggleWishlist extends WishlistEvent {
  final ProductModel product;

  const ToggleWishlist(this.product);

  @override
  List<Object?> get props => [product];
}

class ClearWishlist extends WishlistEvent {}
