import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme/app_colors.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;

  const SearchHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDarkGreen,
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryDarkGreen, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Search fashion, beauty & more...",
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (query) {
                  context.read<SearchBloc>().add(SearchQueryChanged(query));
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 22),
              onPressed: () {},
            ),
            Container(height: 24, width: 1, color: Colors.grey.shade300),
            IconButton(
              icon: const Icon(Icons.mic, color: AppColors.primaryDarkGreen, size: 24),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
