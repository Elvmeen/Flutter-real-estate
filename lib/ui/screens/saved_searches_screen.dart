import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/filters_provider.dart';
import '../../application/saved_searches_provider.dart';
import '../../application/text_searchbar_provider.dart';

class SavedSearchesScreen extends ConsumerWidget {
  const SavedSearchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedSearchesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Searches')),
      body: saved.isEmpty
          ? const Center(child: Text('No saved searches'))
          : ListView.builder(
              itemCount: saved.length,
              itemBuilder: (context, index) {
                final s = saved[index];
                return ListTile(
                  title: Text(s.queryText.isEmpty ? 'Any location' : s.queryText),
                  subtitle: Text('Price ${s.minPrice} - ${s.maxPrice} | Beds ≥ ${s.minBeds} | Baths ≥ ${s.minBaths}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ref.read(savedSearchesProvider.notifier).removeAt(index),
                  ),
                  onTap: () {
                    ref.read(textSearchBarProvider.notifier).update((_) => s.queryText);
                    ref.read(minPriceProvider.notifier).update((_) => s.minPrice);
                    ref.read(maxPriceProvider.notifier).update((_) => s.maxPrice);
                    ref.read(minBedsProvider.notifier).update((_) => s.minBeds);
                    ref.read(minBathsProvider.notifier).update((_) => s.minBaths);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
    );
  }
}
