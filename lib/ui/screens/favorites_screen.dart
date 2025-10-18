import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/favorites_provider.dart';
import '../../application/list_houses_provider.dart';
import '../../models/house_model.dart';
import '../components/card_house.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final housesAsync = ref.watch(listHousesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: housesAsync.when(
        data: (houses) {
          final items = _filterFavorites(houses, favorites);
          if (items.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final house = items[index];
              return CardHouse(house: house, showDistance: true);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
      ),
    );
  }

  List<HouseData> _filterFavorites(List<HouseData> all, Set<int> favIds) {
    return all.where((h) => favIds.contains(h.id)).toList();
  }
}
