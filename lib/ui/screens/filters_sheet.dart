import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/filters_provider.dart';
import '../../application/saved_searches_provider.dart';
import '../../application/text_searchbar_provider.dart';

class FiltersSheet extends ConsumerWidget {
  const FiltersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filtersSummaryProvider);
    final minPrice = ref.watch(minPriceProvider);
    final maxPrice = ref.watch(maxPriceProvider);
    final minBeds = ref.watch(minBedsProvider);
    final minBaths = ref.watch(minBathsProvider);
    final queryText = ref.watch(textSearchBarProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(runSpacing: 12, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Text('Price ${filters.minPrice} - ${filters.maxPrice} | Beds ≥ ${filters.minBeds} | Baths ≥ ${filters.minBaths}')
            ],
          ),
          Row(children: [
            Expanded(child: _numField('Min Price', minPrice.toString(), (v) => ref.read(minPriceProvider.notifier).update((_) => int.tryParse(v) ?? 0))),
            const SizedBox(width: 12),
            Expanded(child: _numField('Max Price', maxPrice.toString(), (v) => ref.read(maxPriceProvider.notifier).update((_) => int.tryParse(v) ?? 10000000))),
          ]),
          Row(children: [
            Expanded(child: _numField('Min Beds', minBeds.toString(), (v) => ref.read(minBedsProvider.notifier).update((_) => int.tryParse(v) ?? 0))),
            const SizedBox(width: 12),
            Expanded(child: _numField('Min Baths', minBaths.toString(), (v) => ref.read(minBathsProvider.notifier).update((_) => int.tryParse(v) ?? 0))),
          ]),
          Row(children: [
            ElevatedButton.icon(
              onPressed: () {
                ref.read(minPriceProvider.notifier).update((_) => 0);
                ref.read(maxPriceProvider.notifier).update((_) => 10000000);
                ref.read(minBedsProvider.notifier).update((_) => 0);
                ref.read(minBathsProvider.notifier).update((_) => 0);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(savedSearchesProvider.notifier).save(SavedSearch(
                      queryText: queryText,
                      minPrice: minPrice,
                      maxPrice: maxPrice,
                      minBeds: minBeds,
                      minBaths: minBaths,
                    ));
                if (context.mounted) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Save Search'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Apply'),
            ),
          ])
        ]),
      ),
    );
  }

  Widget _numField(String label, String value, void Function(String) onChanged) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      onChanged: onChanged,
    );
  }
}
