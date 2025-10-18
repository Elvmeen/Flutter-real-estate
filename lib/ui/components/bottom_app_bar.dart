import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/selected_index_provider.dart';
import '../../application/messaging_provider.dart';
import '../theme/colors.dart';

class BottomAppBarMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final unreadCount = ref.watch(unreadMessageCountProvider);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        // Home/Properties
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        // Agents
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Agents',
        ),
        // Favorites
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        // Messages
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(Icons.message),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Messages',
        ),
        // Calculator
        BottomNavigationBarItem(
          icon: Icon(Icons.calculate),
          label: 'Calculator',
        ),
        // About
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'About',
        ),
      ],
      // Get index from the provider
      currentIndex: selectedIndex,
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.strong,
      unselectedItemColor: AppColors.light,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(fontSize: 10),
      unselectedLabelStyle: TextStyle(fontSize: 10),
      onTap: (index) {
        // Change the index in the provider
        ref.read(selectedIndexProvider.notifier).state = index;
      },
    );
  }
}
