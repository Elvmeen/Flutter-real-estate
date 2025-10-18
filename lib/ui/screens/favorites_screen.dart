import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/favorites_provider.dart';
import '../../application/list_houses_provider.dart';
import '../../models/house_model.dart';
import '../components/empty_list_warning.dart';
import '../components/list_card_house.dart';

class FavoritesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final housesAsync = ref.watch(listHousesProvider);

    return housesAsync.when(
      data: (houses) {
        final favoriteHouses = houses.where((h) => favorites.contains(h.id)).toList();
        if (favoriteHouses.isEmpty) return const EmptyListWarning();
        return ListCardHouse(houseList: favoriteHouses);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => const EmptyListWarning(),
    );
  }
}
