import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewListingsAlertNotifier extends StateNotifier<bool> {
  NewListingsAlertNotifier() : super(false);

  static const String _lastCountKey = 'last_listing_count_v1';

  Future<void> checkForNewListings(int currentCount) async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_lastCountKey) ?? 0;
    if (currentCount > last) {
      state = true;
    }
    await prefs.setInt(_lastCountKey, currentCount);
  }

  void dismiss() => state = false;
}

final newListingsAlertProvider =
    StateNotifierProvider<NewListingsAlertNotifier, bool>((ref) {
  return NewListingsAlertNotifier();
});
