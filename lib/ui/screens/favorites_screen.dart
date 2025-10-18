import 'package:flutter/material.dart';
import 'package:flutter_real_estate/application/favorites_provider.dart';
import 'package:flutter_real_estate/ui/components/card_house.dart';
import 'package:flutter_real_estate/ui/theme/colors.dart';
import 'package:flutter_real_estate/ui/theme/type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

class FavoritesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Favorites',
            style: AppTypography.title01,
          ),
          SizedBox(height: 1.h),
          Text(
            '${favorites.length} ${favorites.length == 1 ? 'property' : 'properties'} saved',
            style: AppTypography.detail.copyWith(color: AppColors.medium),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: favorites.isEmpty
                ? Center(
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
                          style: AppTypography.title02.copyWith(color: AppColors.medium),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Start adding properties to your favorites!',
                          style: AppTypography.body.copyWith(color: AppColors.medium),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      return CardHouse(house: favorites[index], showDistance: true);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
