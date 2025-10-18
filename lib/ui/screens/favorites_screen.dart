import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../application/favorites_provider.dart';
import '../../models/house_model.dart';
import '../components/card_house.dart';
import '../components/empty_list_warning.dart';
import '../components/error_state.dart';
import '../theme/colors.dart';
import '../theme/type.dart';
import 'property_alerts_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesValue = ref.watch(favoritePropertiesProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: AppColors.strong,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.medium,
              labelStyle: AppTypography.detail,
              tabs: [
                Tab(text: 'Favorites'),
                Tab(text: 'Alerts'),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                // Favorites tab
                _buildFavoritesTab(context, ref, favoritesValue),
                
                // Alerts tab
                PropertyAlertsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab(BuildContext context, WidgetRef ref, AsyncValue<List<PropertyData>> favoritesValue) {
    return favoritesValue.when(
      data: (favorites) {
        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: AppColors.medium,
                ),
                SizedBox(height: 2.h),
                Text(
                  'No Favorite Properties',
                  style: AppTypography.title02,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Start browsing properties and tap the heart icon to save your favorites here.',
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to overview screen
                    DefaultTabController.of(context)?.animateTo(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.strong,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Browse Properties'),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            // Header with count and sort options
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${favorites.length} Favorite${favorites.length != 1 ? 's' : ''}',
                    style: AppTypography.title02,
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.sort, color: AppColors.medium),
                    onSelected: (value) {
                      // Handle sort selection
                      ref.read(favoritesSortProvider.notifier).state = value;
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'date_added', child: Text('Date Added')),
                      PopupMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                      PopupMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                      PopupMenuItem(value: 'bedrooms', child: Text('Bedrooms')),
                    ],
                  ),
                ],
              ),
            ),
            
            // Favorites list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final property = favorites[index];
                  return Dismissible(
                    key: Key(property.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 4.w),
                      margin: EdgeInsets.only(bottom: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, color: Colors.white, size: 24),
                          Text('Remove', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    onDismissed: (direction) {
                      ref.read(favoritesProvider.notifier).removeFavorite(property.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Removed from favorites'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              ref.read(favoritesProvider.notifier).addFavorite(property.id);
                            },
                          ),
                        ),
                      );
                    },
                    child: FavoritePropertyCard(property: property),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: ErrorState()),
    );
  }
}

class FavoritePropertyCard extends ConsumerWidget {
  final PropertyData property;

  const FavoritePropertyCard({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to property details
          Navigator.pushNamed(context, '/property_details', arguments: property);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            children: [
              // Property image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 25.w,
                  height: 20.w,
                  color: AppColors.lightGray,
                  child: property.images.isNotEmpty
                      ? Image.network(
                          property.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              Icon(Icons.home, color: AppColors.medium),
                        )
                      : Icon(Icons.home, color: AppColors.medium),
                ),
              ),
              
              SizedBox(width: 3.w),
              
              // Property details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${property.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: AppTypography.title02,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      property.address,
                      style: AppTypography.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        _buildPropertyFeature(Icons.bed, property.bedrooms.toString()),
                        SizedBox(width: 3.w),
                        _buildPropertyFeature(Icons.bathtub, property.bathrooms.toString()),
                        SizedBox(width: 3.w),
                        _buildPropertyFeature(Icons.square_foot, '${property.size} sq ft'),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Favorite button
              IconButton(
                onPressed: () {
                  ref.read(favoritesProvider.notifier).removeFavorite(property.id);
                },
                icon: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyFeature(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.medium),
        SizedBox(width: 1.w),
        Text(value, style: AppTypography.detail),
      ],
    );
  }
}