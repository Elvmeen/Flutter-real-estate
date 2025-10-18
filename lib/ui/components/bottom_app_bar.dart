import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/selected_index_provider.dart';
import '../../application/unread_badges_provider.dart';
import '../theme/colors.dart';

class BottomAppBarMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final unreadMessages = ref.watch(unreadBadgesProvider).messages;
    final unreadAlerts = ref.watch(unreadBadgesProvider).alerts;

    return BottomNavigationBar(
      items: [
        // Icons in the bottomBar
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text(unreadMessages.toString()),
            isLabelVisible: unreadMessages > 0,
            child: Icon(Icons.message),
          ),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text(unreadAlerts.toString()),
            isLabelVisible: unreadAlerts > 0,
            child: Icon(Icons.notifications),
          ),
          label: 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Agents',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calculate),
          label: 'Calculator',
        ),
      ],
      // Get index from the provider
      currentIndex: selectedIndex,
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.strong,
      unselectedItemColor: AppColors.light,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 10,
      onTap: (index) {
        // Change the index in the provider
        ref.read(selectedIndexProvider.notifier).state = index;
      },
    );
  }
}
