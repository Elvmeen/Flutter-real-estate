import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdvancedFilter {
  final int? minPrice;
  final int? maxPrice;
  final int? minBedrooms;
  final int? minBathrooms;
  final double? maxDistanceKm;

  const AdvancedFilter({
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.minBathrooms,
    this.maxDistanceKm,
  });

  bool get isActive => minPrice != null ||
      maxPrice != null ||
      (minBedrooms ?? 0) > 0 ||
      (minBathrooms ?? 0) > 0 ||
      (maxDistanceKm ?? 0) > 0;

  AdvancedFilter copyWith({
    int? minPrice,
    int? maxPrice,
    int? minBedrooms,
    int? minBathrooms,
    double? maxDistanceKm,
  }) {
    return AdvancedFilter(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
    );
  }

  static const empty = AdvancedFilter();
}

class AdvancedFilterNotifier extends StateNotifier<AdvancedFilter> {
  AdvancedFilterNotifier() : super(AdvancedFilter.empty);

  void setMinPrice(int? value) => state = state.copyWith(minPrice: value);
  void setMaxPrice(int? value) => state = state.copyWith(maxPrice: value);
  void setMinBedrooms(int? value) => state = state.copyWith(minBedrooms: value);
  void setMinBathrooms(int? value) => state = state.copyWith(minBathrooms: value);
  void setMaxDistanceKm(double? value) => state = state.copyWith(maxDistanceKm: value);

  void apply(AdvancedFilter filter) => state = filter;

  void clear() => state = AdvancedFilter.empty;
}

final advancedFilterProvider =
    StateNotifierProvider<AdvancedFilterNotifier, AdvancedFilter>((ref) {
  return AdvancedFilterNotifier();
});
