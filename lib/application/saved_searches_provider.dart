import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedSearch {
  final String queryText;
  final int minPrice;
  final int maxPrice;
  final int minBeds;
  final int minBaths;

  const SavedSearch({
    required this.queryText,
    required this.minPrice,
    required this.maxPrice,
    required this.minBeds,
    required this.minBaths,
  });

  Map<String, dynamic> toJson() => {
        'queryText': queryText,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'minBeds': minBeds,
        'minBaths': minBaths,
      };

  factory SavedSearch.fromJson(Map<String, dynamic> json) => SavedSearch(
        queryText: json['queryText'] as String? ?? '',
        minPrice: json['minPrice'] as int? ?? 0,
        maxPrice: json['maxPrice'] as int? ?? 100000000,
        minBeds: json['minBeds'] as int? ?? 0,
        minBaths: json['minBaths'] as int? ?? 0,
      );
}

final savedSearchesProvider =
    StateNotifierProvider<SavedSearchesController, List<SavedSearch>>((ref) {
  return SavedSearchesController()..load();
});

class SavedSearchesController extends StateNotifier<List<SavedSearch>> {
  SavedSearchesController() : super(const <SavedSearch>[]);

  static const String _prefsKey = 'saved_searches';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null && stored.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(stored) as List<dynamic>;
      state = decoded
          .map((e) => SavedSearch.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }
  }

  Future<void> save(SavedSearch s) async {
    final list = List<SavedSearch>.from(state);
    list.add(s);
    state = list;
    await _persist();
  }

  Future<void> removeAt(int index) async {
    final list = List<SavedSearch>.from(state);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      state = list;
      await _persist();
    }
  }

  Future<void> clear() async {
    state = const <SavedSearch>[];
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(state.map((e) => e.toJson()).toList(growable: false)),
    );
  }
}
