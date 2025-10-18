import 'package:flutter/material.dart';
import 'package:dreamhome_real_estate/ui/components/error_state.dart';
import 'package:dreamhome_real_estate/ui/components/list_card_house.dart';
import 'package:dreamhome_real_estate/ui/components/strings.dart';
import 'package:dreamhome_real_estate/ui/theme/type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../application/search_provider.dart';
import '../../application/selected_sort_provider.dart';
import '../../application/text_searchbar_provider.dart';
import '../components/filter_card.dart';
import '../theme/colors.dart';
import 'advanced_search_screen.dart';

class OverviewScreen extends ConsumerWidget {
  // Controller for the search bar input field.
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the filtered properties from the search provider.
    final propertiesValue = ref.watch(filteredPropertiesProvider);
    final searchFilters = ref.watch(searchFiltersProvider);

    // A provider for tracking if the search bar is empty or not.
    final textSearchBarIsEmptyProvider = StateProvider<bool>((ref) => true);

    return Column(children: [
      // Search bar section
      Padding(
        padding: EdgeInsets.only(top: 0.75.h, bottom: 1.5.h, right: 4.2.w, left: 4.2.w),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 4.w, top: 0.4.h),
            child: TextField(
              controller: searchController,
              cursorColor: AppColors.medium,
              style: AppTypography.input,
              decoration: InputDecoration(
                hintText: Strings.searchBarHint,
                hintStyle: AppTypography.hint,
                suffixIcon: Consumer(
                  builder: (context, ref, _) =>
                      // Show search or clear button based on textSearchbarIsEmptyProvider.
                      ref.watch(textSearchBarIsEmptyProvider)
                          ? IconButton(
                              icon: const Icon(Icons.search, color: AppColors.medium),
                              onPressed: () {},
                            )
                          : IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.strong),
                              onPressed: () {
                                // Clear the search text when the clear button is pressed.
                                ref.read(textSearchBarProvider.notifier).update((_) => '');
                                ref.read(searchQueryProvider.notifier).state = '';
                                searchController.clear();
                                FocusScopeNode currentFocus = FocusScope.of(context);

                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                  ref.read(textSearchBarIsEmptyProvider.notifier).update((state) => true);
                                }
                              },
                            ),
                ),
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                // Update the search text when the user presses enter.
                ref.read(textSearchBarProvider.notifier).update((_) => value);
                ref.read(searchQueryProvider.notifier).state = value;
              },
              onChanged: (value) {
                // Update the state of the search bar.
                ref.read(textSearchBarIsEmptyProvider.notifier).update((state) => value.isEmpty);
              },
            ),
          ),
        ),
      ),
      
      // Advanced search and filters section
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdvancedSearchScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.tune, size: 18),
                label: Text('Advanced Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: searchFilters.hasActiveFilters 
                      ? AppColors.strong 
                      : AppColors.lightGray,
                  foregroundColor: searchFilters.hasActiveFilters 
                      ? Colors.white 
                      : AppColors.strong,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            if (searchFilters.hasActiveFilters) ...[
              SizedBox(width: 2.w),
              IconButton(
                onPressed: () {
                  ref.read(searchFiltersProvider.notifier).state = SearchFilters();
                },
                icon: Icon(Icons.clear, color: AppColors.strong),
                tooltip: 'Clear filters',
              ),
            ],
          ],
        ),
      ),
      
      // House list section
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: SizedBox(
          // Change your height based on preference
          height: 40,
          width: double.infinity,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: const Text(Strings.sortText, textAlign: TextAlign.left),
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) => ListView(
                    // Set the scroll direction to horizontal
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      for (final (index, item) in Strings.filters.indexed)
                        FilterCard(
                            text: item,
                            cardId: index,
                            selectedId: ref.watch(selectedSortProvider).id)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        child: propertiesValue.when(
          // This is set to `false` to make sure the loading state is shown when
          // the data is refreshed or tried to load again
          skipLoadingOnRefresh: false,
          data: (properties) {
            if (properties.isEmpty && (searchFilters.hasActiveFilters || ref.read(searchQueryProvider).isNotEmpty)) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: AppColors.medium),
                    SizedBox(height: 2.h),
                    Text('No properties found', style: AppTypography.title02),
                    SizedBox(height: 1.h),
                    Text('Try adjusting your search criteria', style: AppTypography.body),
                    SizedBox(height: 2.h),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(searchFiltersProvider.notifier).state = SearchFilters();
                        ref.read(searchQueryProvider.notifier).state = '';
                        ref.read(textSearchBarProvider.notifier).state = '';
                        searchController.clear();
                      },
                      child: Text('Clear all filters'),
                    ),
                  ],
                ),
              );
            }
            
            // Convert PropertyData back to HouseData for compatibility with existing components
            final houses = properties.map((property) => HouseData(
              id: property.id,
              price: property.price,
              image: property.images.isNotEmpty ? property.images.first : '',
              zip: property.zip,
              bathrooms: property.bathrooms,
              bedrooms: property.bedrooms,
              size: property.size,
              city: property.city,
              description: property.description,
              latitude: property.latitude.toInt(),
              longitude: property.longitude.toInt(),
              distance: property.distance,
            )).toList();
            
            return ListCardHouse(houseList: houses);
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(child: ErrorState()),
        ),
      ),
    ]);
  }
}

