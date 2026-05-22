import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/product_model.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final List<String> _recentSearches = ['Oversized T-shirts', 'Anarkali Suits', 'Running Shoes'];

  SearchBloc() : super(SearchInitial(recentSearches: const ['Oversized T-shirts', 'Anarkali Suits', 'Running Shoes'])) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<RemoveRecentSearch>(_onRemoveRecentSearch);
    on<ClearRecentSearches>(_onClearRecentSearches);
  }

  Future<void> _onSearchQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty) {
      emit(SearchInitial(recentSearches: List.from(_recentSearches)));
      return;
    }

    emit(SearchLoading());
    
    // Add to history if query is long enough and not already there
    if (event.query.length > 2 && !_recentSearches.contains(event.query)) {
      // For a real app, you might want to wait for "Enter" or a specific action to add to history
      // but for this mock, we'll just track it if it's new.
    }

    await Future.delayed(const Duration(milliseconds: 500));
    // ... rest of logic

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

  void _onRemoveRecentSearch(RemoveRecentSearch event, Emitter<SearchState> emit) {
    _recentSearches.remove(event.query);
    if (state is SearchInitial) {
      emit(SearchInitial(recentSearches: List.from(_recentSearches)));
    }
  }

  void _onClearRecentSearches(ClearRecentSearches event, Emitter<SearchState> emit) {
    _recentSearches.clear();
    if (state is SearchInitial) {
      emit(SearchInitial(recentSearches: const []));
    }
  }
}
