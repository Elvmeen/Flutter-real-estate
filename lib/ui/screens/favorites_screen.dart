import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/favorites_provider.dart';
import '../../application/list_houses_provider.dart';
import '../../models/house_model.dart';
import '../components/empty_list_warning.dart';
import '../components/list_card_house.dart';
import '../components/strings.dart';

class FavoritesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoriteHousesProvider);
    final houseDataValue = ref.watch(listHousesProvider);

    return houseDataValue.when(
      data: (houses) {
        final favorites = houses.where((h) => favoriteIds.contains(h.id)).toList();
        if (favorites.isEmpty) {
          return const Center(child: Text(Strings.favoritesEmpty));
        }
        return ListCardHouse(houseList: favorites);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => const Center(child: EmptyListWarning()),
    );
  }
}
