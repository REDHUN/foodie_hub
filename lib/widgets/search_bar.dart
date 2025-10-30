import 'package:flutter/material.dart';
import 'package:foodiehub/utils/constants.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String) onSearchChanged;

  const SearchBarWidget({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search for food, restaurants, etc...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
