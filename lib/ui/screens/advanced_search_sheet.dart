import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchFiltersProvider = StateProvider<SearchFilters>((ref) => SearchFilters());

class SearchFilters {
  final RangeValues price;
  final int minBeds;
  final int minBaths;
  final RangeValues size;
  final double maxDistanceKm;

  SearchFilters({
    this.price = const RangeValues(0, 1000000),
    this.minBeds = 0,
    this.minBaths = 0,
    this.size = const RangeValues(0, 300),
    this.maxDistanceKm = 1000,
  });

  SearchFilters copyWith({
    RangeValues? price,
    int? minBeds,
    int? minBaths,
    RangeValues? size,
    double? maxDistanceKm,
  }) {
    return SearchFilters(
      price: price ?? this.price,
      minBeds: minBeds ?? this.minBeds,
      minBaths: minBaths ?? this.minBaths,
      size: size ?? this.size,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
    );
  }
}

class AdvancedSearchSheet extends ConsumerWidget {
  const AdvancedSearchSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text('Advanced search', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Price range'),
          RangeSlider(
            values: filters.price,
            min: 0,
            max: 2000000,
            divisions: 200,
            labels: RangeLabels(filters.price.start.toStringAsFixed(0), filters.price.end.toStringAsFixed(0)),
            onChanged: (v) => ref.read(searchFiltersProvider.notifier).state = filters.copyWith(price: v),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _intField('Min beds', filters.minBeds, (v) => ref.read(searchFiltersProvider.notifier).state = filters.copyWith(minBeds: v))),
            const SizedBox(width: 12),
            Expanded(child: _intField('Min baths', filters.minBaths, (v) => ref.read(searchFiltersProvider.notifier).state = filters.copyWith(minBaths: v))),
          ]),
          const SizedBox(height: 8),
          const Text('Size (m²)'),
          RangeSlider(
            values: filters.size,
            min: 0,
            max: 1000,
            divisions: 100,
            labels: RangeLabels(filters.size.start.toStringAsFixed(0), filters.size.end.toStringAsFixed(0)),
            onChanged: (v) => ref.read(searchFiltersProvider.notifier).state = filters.copyWith(size: v),
          ),
          const SizedBox(height: 8),
          const Text('Max distance (km)'),
          Slider(
            value: filters.maxDistanceKm,
            min: 1,
            max: 1000,
            divisions: 100,
            label: filters.maxDistanceKm.toStringAsFixed(0),
            onChanged: (v) => ref.read(searchFiltersProvider.notifier).state = filters.copyWith(maxDistanceKm: v),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply filters'),
          )
        ],
      ),
    );
  }

  Widget _intField(String label, int value, void Function(int) onChanged) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      onChanged: (s) => onChanged(int.tryParse(s) ?? value),
    );
  }
}
