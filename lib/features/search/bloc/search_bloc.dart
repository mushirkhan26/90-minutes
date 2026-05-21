import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/product_model.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
  }

  Future<void> _onSearchQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    // MOCK DATA for Static Preview
    final List<ProductModel> mockResults = [
      ProductModel(
        id: 's1',
        name: 'Summer T-shirt',
        description: 'Cotton t-shirt for summer.',
        price: 499.0,
        categoryId: 'men',
        images: ['https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500'],
        stock: 10,
        unit: 'pcs',
      ),
      ProductModel(
        id: 's2',
        name: 'Denim Jeans',
        description: 'Blue denim jeans.',
        price: 1599.0,
        categoryId: 'men',
        images: ['https://images.unsplash.com/photo-1542272604-787c3835535d?w=500'],
        stock: 5,
        unit: 'pcs',
      ),
    ].where((p) => p.name.toLowerCase().contains(event.query.toLowerCase())).toList();

    emit(SearchLoaded(mockResults));
  }
}
