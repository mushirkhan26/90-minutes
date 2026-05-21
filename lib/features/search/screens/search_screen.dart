import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search for fashion...',
            border: InputBorder.none,
          ),
          onChanged: (query) {
            context.read<SearchBloc>().add(SearchQueryChanged(query));
          },
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SearchLoaded) {
            if (state.results.isEmpty) {
              return const Center(child: Text('No results found'));
            }
            return ListView.builder(
              itemCount: state.results.length,
              itemBuilder: (context, index) {
                final product = state.results[index];
                return ListTile(
                  leading: Image.network(product.images.first, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(product.name),
                  subtitle: Text('₹${product.price}'),
                  onTap: () {
                    // Navigate to details
                  },
                );
              },
            );
          } else if (state is SearchError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Start searching for trends'));
        },
      ),
    );
  }
}
