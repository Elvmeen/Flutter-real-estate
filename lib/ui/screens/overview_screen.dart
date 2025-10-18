import 'package:flutter/material.dart';
import 'package:flutter_real_estate/ui/components/error_state.dart';
import 'package:flutter_real_estate/ui/components/list_card_house.dart';
import 'package:flutter_real_estate/ui/components/strings.dart';
import 'package:flutter_real_estate/ui/theme/type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../application/list_houses_provider.dart';
import '../../application/selected_sort_provider.dart';
import '../../application/text_searchbar_provider.dart';
import '../../application/advanced_filter_provider.dart';
import '../../application/alerts_provider.dart';
import '../components/filter_card.dart';
import '../theme/colors.dart';

class OverviewScreen extends ConsumerWidget {
  // Controller for the search bar input field.
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the list of houses from the provider.
    final houseDataValue = ref.watch(listHousesProvider);

    // A provider for tracking if the search bar is empty or not.
    final textSearchBarIsEmptyProvider = StateProvider<bool>((ref) => true);

    return Column(children: [
      Consumer(builder: (context, ref, _) {
        final show = ref.watch(newListingsAlertProvider);
        if (!show) return const SizedBox.shrink();
        return Container(
          color: Colors.amber.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.new_releases),
              const SizedBox(width: 8),
              const Expanded(child: Text(Strings.newListingsAvailable)),
              TextButton(
                onPressed: () => ref.read(newListingsAlertProvider.notifier).dismiss(),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        );
      }),
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
              },
              onChanged: (value) {
                // Update the state of the search bar.
                ref.read(textSearchBarIsEmptyProvider.notifier).update((state) => value.isEmpty);
              },
            ),
          ),
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
              IconButton(
                tooltip: 'Advanced filters',
                icon: const Icon(Icons.tune),
                onPressed: () => _openAdvancedFilters(context, ref),
              )
            ],
          ),
        ),
      ),
      Expanded(
        child: houseDataValue.when(
          // This is set to `false` to make sure the loading state is shown when
          // the data is refreshed or tried to load again
          skipLoadingOnRefresh: false,
          data: (houses) {
            // Notify alert system for new data count
            ref.read(newListingsAlertProvider.notifier).checkForNewListings(houses.length);
            final filter = ref.watch(advancedFilterProvider);
            final filtered = filter.isActive
                ? houses.where((h) {
                    if (filter.minPrice != null && h.price < filter.minPrice!) return false;
                    if (filter.maxPrice != null && h.price > filter.maxPrice!) return false;
                    if (filter.minBedrooms != null && h.bedrooms < filter.minBedrooms!) {
                      return false;
                    }
                    if (filter.minBathrooms != null && h.bathrooms < filter.minBathrooms!) {
                      return false;
                    }
                    if (filter.maxDistanceKm != null &&
                        h.distance > (filter.maxDistanceKm!)) return false;
                    return true;
                  }).toList()
                : houses;
            return ListCardHouse(houseList: filtered);
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(child: ErrorState()),
        ),
      ),
    ]);
  }
  void _openAdvancedFilters(BuildContext context, WidgetRef ref) {
    final current = ref.read(advancedFilterProvider);
    final minPriceController =
        TextEditingController(text: current.minPrice?.toString() ?? '');
    final maxPriceController =
        TextEditingController(text: current.maxPrice?.toString() ?? '');
    final minBedsController =
        TextEditingController(text: current.minBedrooms?.toString() ?? '');
    final minBathsController =
        TextEditingController(text: current.minBathrooms?.toString() ?? '');
    final maxDistanceController =
        TextEditingController(text: current.maxDistanceKm?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: const [
                  Text('Advanced Filters', style: AppTypography.title02),
                ],
              ),
              const SizedBox(height: 12),
              _numField('Min price', minPriceController),
              _numField('Max price', maxPriceController),
              _numField('Min bedrooms', minBedsController),
              _numField('Min bathrooms', minBathsController),
              _numField('Max distance (km)', maxDistanceController),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(advancedFilterProvider.notifier).clear();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final f = AdvancedFilter(
                          minPrice: int.tryParse(minPriceController.text),
                          maxPrice: int.tryParse(maxPriceController.text),
                          minBedrooms: int.tryParse(minBedsController.text),
                          minBathrooms: int.tryParse(minBathsController.text),
                          maxDistanceKm: double.tryParse(maxDistanceController.text),
                        );
                        ref.read(advancedFilterProvider.notifier).apply(f);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _numField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        controller: controller,
      ),
    );
  }
}

