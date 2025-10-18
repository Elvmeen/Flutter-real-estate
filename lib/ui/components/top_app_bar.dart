import 'package:flutter/material.dart';
import 'package:flutter_real_estate/ui/theme/type.dart';
import 'package:sizer/sizer.dart';

import '../screens/favorites_screen.dart';
import '../screens/agents_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/mortgage_calculator_screen.dart';
import '../screens/saved_searches_screen.dart';
import '../screens/filters_sheet.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TopAppBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return (AppBar(
      backgroundColor: Colors.transparent,
      // Set the background color to transparent
      elevation: 0.0,
      // Set elevation to 0.0 to remove the shadow
      bottomOpacity: 0.0,
      actions: [
        IconButton(
          tooltip: 'Filters',
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const FiltersSheet(),
            );
          },
          icon: const Icon(Icons.filter_list),
        ),
        IconButton(
          tooltip: 'Saved Searches',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SavedSearchesScreen()),
            );
          },
          icon: const Icon(Icons.notifications_outlined),
        ),
        IconButton(
          tooltip: 'Favorites',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            );
          },
          icon: const Icon(Icons.favorite_border),
        ),
        IconButton(
          tooltip: 'Agents',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AgentsScreen()),
            );
          },
          icon: const Icon(Icons.people_alt_outlined),
        ),
        IconButton(
          tooltip: 'Messages',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MessagesScreen()),
            );
          },
          icon: const Icon(Icons.chat_bubble_outline),
        ),
        IconButton(
          tooltip: 'Mortgage Calculator',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MortgageCalculatorScreen()),
            );
          },
          icon: const Icon(Icons.calculate_outlined),
        ),
      ],
      flexibleSpace: Container(
        margin: EdgeInsets.only(left: 4.5.w, top: 5.h),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: AppTypography.title01
          ),
        ),
      ),
    ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}