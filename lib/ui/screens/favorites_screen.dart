import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../models/house_model.dart';
import '../components/card_house.dart';
import '../theme/colors.dart';
import '../theme/type.dart';

// Provider for managing favorites
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<HouseData>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<List<HouseData>> {
  FavoritesNotifier() : super([]);

  void addToFavorites(HouseData property) {
    if (!state.any((p) => p.id == property.id)) {
      state = [...state, property.copyWith(isFavorite: true)];
    }
  }

  void removeFromFavorites(int propertyId) {
    state = state.where((p) => p.id != propertyId).toList();
  }

  void toggleFavorite(HouseData property) {
    if (state.any((p) => p.id == property.id)) {
      removeFromFavorites(property.id);
    } else {
      addToFavorites(property);
    }
  }

  bool isFavorite(int propertyId) {
    return state.any((p) => p.id == propertyId);
  }
}

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String _sortBy = 'Recently Added';
  String _filterBy = 'All';

  final List<String> _sortOptions = [
    'Recently Added',
    'Price: Low to High',
    'Price: High to Low',
    'Size: Small to Large',
    'Size: Large to Small',
    'Bedrooms',
    'Bathrooms',
  ];

  final List<String> _filterOptions = [
    'All',
    'For Sale',
    'For Rent',
    'Sold',
    'Rented',
  ];

  List<HouseData> get _filteredAndSortedFavorites {
    var favorites = ref.watch(favoritesProvider);
    
    // Filter by status
    if (_filterBy != 'All') {
      final status = PropertyStatus.values.firstWhere(
        (s) => s.name.toLowerCase().replaceAll(' ', '') == _filterBy.toLowerCase().replaceAll(' ', ''),
        orElse: () => PropertyStatus.forSale,
      );
      favorites = favorites.where((p) => p.status == status).toList();
    }

    // Sort favorites
    switch (_sortBy) {
      case 'Recently Added':
        // Keep original order (most recently added first)
        break;
      case 'Price: Low to High':
        favorites.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        favorites.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Size: Small to Large':
        favorites.sort((a, b) => a.size.compareTo(b.size));
        break;
      case 'Size: Large to Small':
        favorites.sort((a, b) => b.size.compareTo(a.size));
        break;
      case 'Bedrooms':
        favorites.sort((a, b) => b.bedrooms.compareTo(a.bedrooms));
        break;
      case 'Bathrooms':
        favorites.sort((a, b) => b.bathrooms.compareTo(a.bathrooms));
        break;
    }

    return favorites;
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _filteredAndSortedFavorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: AppColors.strong,
        foregroundColor: AppColors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => _sortOptions.map((option) {
              return PopupMenuItem(
                value: option,
                child: Row(
                  children: [
                    if (_sortBy == option)
                      const Icon(Icons.check, color: AppColors.strong),
                    SizedBox(width: _sortBy == option ? 2.w : 6.w),
                    Text(option),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter and Sort Bar
          Container(
            padding: EdgeInsets.all(4.w),
            color: AppColors.lightGray,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterBy,
                    decoration: const InputDecoration(
                      labelText: 'Filter',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                    items: _filterOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _filterBy = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: const InputDecoration(
                      labelText: 'Sort',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                    items: _sortOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Favorites List
          Expanded(
            child: favorites.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final property = favorites[index];
                      return _buildFavoriteCard(property);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 20.w,
            color: AppColors.medium,
          ),
          SizedBox(height: 4.h),
          Text(
            'No Favorites Yet',
            style: AppTypography.title02.copyWith(
              color: AppColors.strong,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Start exploring properties and tap the heart icon to save your favorites.',
            style: AppTypography.body.copyWith(
              color: AppColors.medium,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () {
              // Navigate to home screen
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.strong,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Browse Properties'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(HouseData property) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            // Property Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://via.placeholder.com/120x90',
                width: 30.w,
                height: 22.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 3.w),

            // Property Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${property.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: AppTypography.title02.copyWith(
                      color: AppColors.strong,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${property.zip} ${property.city}',
                    style: AppTypography.body,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${property.bedrooms} bed • ${property.bathrooms} bath • ${property.size} sq ft',
                    style: AppTypography.body.copyWith(
                      color: AppColors.medium,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor(property.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(property.status),
                          style: AppTypography.detail.copyWith(
                            color: _getStatusColor(property.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(property.datePosted),
                        style: AppTypography.detail.copyWith(
                          color: AppColors.medium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    ref.read(favoritesProvider.notifier).removeFromFavorites(property.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Removed from favorites'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.favorite,
                    color: AppColors.strong,
                  ),
                ),
                IconButton(
                  onPressed: () => _showPropertyActions(property),
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.medium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.forSale:
        return Colors.green;
      case PropertyStatus.forRent:
        return Colors.blue;
      case PropertyStatus.sold:
        return Colors.red;
      case PropertyStatus.rented:
        return Colors.orange;
      case PropertyStatus.pending:
        return Colors.amber;
      case PropertyStatus.offMarket:
        return Colors.grey;
    }
  }

  String _getStatusText(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.forSale:
        return 'For Sale';
      case PropertyStatus.forRent:
        return 'For Rent';
      case PropertyStatus.sold:
        return 'Sold';
      case PropertyStatus.rented:
        return 'Rented';
      case PropertyStatus.pending:
        return 'Pending';
      case PropertyStatus.offMarket:
        return 'Off Market';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Recently added';
    
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showPropertyActions(HouseData property) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to property details
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Property'),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Schedule Viewing'),
              onTap: () {
                Navigator.pop(context);
                // Implement schedule viewing functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Contact Agent'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to messaging
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Calculate Mortgage'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to mortgage calculator
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Remove from Favorites'),
              onTap: () {
                Navigator.pop(context);
                ref.read(favoritesProvider.notifier).removeFromFavorites(property.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Removed from favorites'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}