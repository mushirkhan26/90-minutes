import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/product_model.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<FetchProductsByCategory>(_onFetchProductsByCategory);
  }

  Future<void> _onFetchProductsByCategory(
    FetchProductsByCategory event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    
    // Simulating network delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK DATA for Static Preview
    final List<ProductModel> mockProducts = [
      if (event.category == 'Men') ...[
        ProductModel(
          id: 'm1',
          name: 'Classic White Shirt',
          description: 'Premium cotton white shirt for men.',
          price: 1299.0,
          categoryId: 'men',
          images: ['https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500'],
          stock: 10,
          unit: 'pcs',
        ),
        ProductModel(
          id: 'm2',
          name: 'Slim Fit Denim',
          description: 'Stretchable blue denim jeans.',
          price: 2499.0,
          categoryId: 'men',
          images: ['https://images.unsplash.com/photo-1542272604-787c3835535d?w=500'],
          stock: 5,
          unit: 'pcs',
        ),
      ],
      if (event.category == 'Women') ...[
        ProductModel(
          id: 'w1',
          name: 'Floral Summer Dress',
          description: 'Light and airy floral dress.',
          price: 1899.0,
          categoryId: 'women',
          images: ['https://images.unsplash.com/photo-1572804013307-597758e99d88?w=500'],
          stock: 8,
          unit: 'pcs',
        ),
        ProductModel(
          id: 'w2',
          name: 'Designer Saree',
          description: 'Elegant silk saree for special occasions.',
          price: 4500.0,
          categoryId: 'women',
          images: ['https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=500'],
          stock: 3,
          unit: 'pcs',
        ),
      ],
      if (event.category == 'Kids') ...[
        ProductModel(
          id: 'k1',
          name: 'Cotton T-Shirt Set',
          description: 'Pack of 3 colorful t-shirts.',
          price: 899.0,
          categoryId: 'kids',
          images: ['https://images.unsplash.com/photo-1519233073524-79350369868c?w=500'],
          stock: 15,
          unit: 'set',
        ),
      ],
    ];

    emit(ProductLoaded(mockProducts, event.category));
  }
}
