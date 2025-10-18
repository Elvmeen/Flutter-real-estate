import 'package:flutter/material.dart';
import 'package:flutter_real_estate/application/favorites_provider.dart';
import 'package:flutter_real_estate/application/list_houses_provider.dart';
import 'package:flutter_real_estate/ui/components/card_house.dart';
import 'package:flutter_real_estate/ui/theme/colors.dart';
import 'package:flutter_real_estate/ui/theme/type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

class FavoritesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final housesDataValue = ref.watch(listHousesProvider);

    return housesDataValue.when(
      data: (allHouses) {
        final favoriteHouses = allHouses
            .where((house) => favorites.any((fav) => fav.propertyId == house.id))
            .toList();

        if (favoriteHouses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: AppColors.medium,
                ),
                SizedBox(height: 2.h),
                Text(
                  'No favorites yet',
                  style: AppTypography.title02,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Save properties to view them here',
                  style: AppTypography.body.copyWith(
                    color: AppColors.medium,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          itemCount: favoriteHouses.length,
          itemBuilder: (context, index) {
            return CardHouse(house: favoriteHouses[index], showDistance: false);
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: AppColors.medium),
            SizedBox(height: 2.h),
            Text(
              'Unable to load favorites',
              style: AppTypography.body,
            ),
          ],
        ),
      ),
    );
  }
}
