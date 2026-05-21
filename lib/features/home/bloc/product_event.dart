import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductsByCategory extends ProductEvent {
  final String category; // 'Men', 'Women', 'Kids'

  const FetchProductsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}
