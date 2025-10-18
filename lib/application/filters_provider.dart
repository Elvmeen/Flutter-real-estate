import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final minPriceProvider = StateProvider<int>((ref) => 0);
final maxPriceProvider = StateProvider<int>((ref) => 10000000);
final minBedsProvider = StateProvider<int>((ref) => 0);
final minBathsProvider = StateProvider<int>((ref) => 0);

class FiltersSummary {
  final int minPrice;
  final int maxPrice;
  final int minBeds;
  final int minBaths;
  const FiltersSummary({required this.minPrice, required this.maxPrice, required this.minBeds, required this.minBaths});
}

final filtersSummaryProvider = Provider<FiltersSummary>((ref) {
  return FiltersSummary(
    minPrice: ref.watch(minPriceProvider),
    maxPrice: ref.watch(maxPriceProvider),
    minBeds: ref.watch(minBedsProvider),
    minBaths: ref.watch(minBathsProvider),
  );
});
