import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../models/house_model.dart';
import '../../models/search_filter_model.dart';
import '../theme/colors.dart';
import '../theme/type.dart';

// Provider for managing alerts
final alertsProvider = StateNotifierProvider<AlertsNotifier, List<PropertyAlert>>((ref) {
  return AlertsNotifier();
});

class PropertyAlert {
  final String id;
  final String name;
  final SearchFilter filter;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTriggered;
  final int matchCount;

  PropertyAlert({
    required this.id,
    required this.name,
    required this.filter,
    this.isActive = true,
    required this.createdAt,
    this.lastTriggered,
    this.matchCount = 0,
  });

  PropertyAlert copyWith({
    String? id,
    String? name,
    SearchFilter? filter,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastTriggered,
    int? matchCount,
  }) {
    return PropertyAlert(
      id: id ?? this.id,
      name: name ?? this.name,
      filter: filter ?? this.filter,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      matchCount: matchCount ?? this.matchCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filter': filter.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
      'matchCount': matchCount,
    };
  }

  factory PropertyAlert.fromJson(Map<String, dynamic> json) {
    return PropertyAlert(
      id: json['id'],
      name: json['name'],
      filter: SearchFilter.fromJson(json['filter']),
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      lastTriggered: json['lastTriggered'] != null 
          ? DateTime.parse(json['lastTriggered']) 
          : null,
      matchCount: json['matchCount'],
    );
  }
}

class AlertsNotifier extends StateNotifier<List<PropertyAlert>> {
  AlertsNotifier() : super([]);

  void addAlert(PropertyAlert alert) {
    state = [...state, alert];
  }

  void updateAlert(String alertId, PropertyAlert updatedAlert) {
    state = state.map((alert) => alert.id == alertId ? updatedAlert : alert).toList();
  }

  void deleteAlert(String alertId) {
    state = state.where((alert) => alert.id != alertId).toList();
  }

  void toggleAlert(String alertId) {
    state = state.map((alert) {
      if (alert.id == alertId) {
        return alert.copyWith(isActive: !alert.isActive);
      }
      return alert;
    }).toList();
  }
}

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    // Add some sample alerts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addSampleAlerts();
    });
  }

  void _addSampleAlerts() {
    final alerts = [
      PropertyAlert(
        id: '1',
        name: 'Houses under \$500k in Downtown',
        filter: SearchFilter(
          maxPrice: 500000,
          propertyTypes: [PropertyType.house],
          location: 'Downtown',
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        lastTriggered: DateTime.now().subtract(const Duration(hours: 2)),
        matchCount: 3,
      ),
      PropertyAlert(
        id: '2',
        name: 'Apartments with Pool',
        filter: SearchFilter(
          propertyTypes: [PropertyType.apartment],
          amenities: ['Swimming Pool'],
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        lastTriggered: DateTime.now().subtract(const Duration(days: 1)),
        matchCount: 7,
      ),
      PropertyAlert(
        id: '3',
        name: 'Luxury Properties over \$1M',
        filter: SearchFilter(
          minPrice: 1000000,
          propertyTypes: [PropertyType.house, PropertyType.villa, PropertyType.penthouse],
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        matchCount: 0,
      ),
    ];

    for (final alert in alerts) {
      ref.read(alertsProvider.notifier).addAlert(alert);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Alerts'),
        backgroundColor: AppColors.strong,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateAlertDialog(),
          ),
        ],
      ),
      body: alerts.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _buildAlertCard(alert);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 20.w,
            color: AppColors.medium,
          ),
          SizedBox(height: 4.h),
          Text(
            'No Alerts Yet',
            style: AppTypography.title02.copyWith(
              color: AppColors.strong,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Create property alerts to get notified when new listings match your criteria.',
            style: AppTypography.body.copyWith(
              color: AppColors.medium,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () => _showCreateAlertDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.strong,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Create Alert'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(PropertyAlert alert) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    alert.name,
                    style: AppTypography.title02.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: alert.isActive,
                  onChanged: (value) {
                    ref.read(alertsProvider.notifier).toggleAlert(alert.id);
                  },
                  activeColor: AppColors.strong,
                ),
              ],
            ),
            SizedBox(height: 1.h),
            
            // Filter summary
            _buildFilterSummary(alert.filter),
            SizedBox(height: 1.h),

            // Stats
            Row(
              children: [
                Icon(Icons.notifications, size: 4.w, color: AppColors.medium),
                SizedBox(width: 1.w),
                Text(
                  '${alert.matchCount} matches',
                  style: AppTypography.body.copyWith(
                    color: AppColors.medium,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.access_time, size: 4.w, color: AppColors.medium),
                SizedBox(width: 1.w),
                Text(
                  _formatLastTriggered(alert.lastTriggered),
                  style: AppTypography.body.copyWith(
                    color: AppColors.medium,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleAlertAction(value, alert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Text('Duplicate'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSummary(SearchFilter filter) {
    final summary = <String>[];

    if (filter.location != null) {
      summary.add('Location: ${filter.location}');
    }
    if (filter.minPrice != null || filter.maxPrice != null) {
      final priceRange = [];
      if (filter.minPrice != null) priceRange.add('\$${filter.minPrice!.toStringAsFixed(0)}');
      priceRange.add('to');
      if (filter.maxPrice != null) priceRange.add('\$${filter.maxPrice!.toStringAsFixed(0)}');
      summary.add('Price: ${priceRange.join(' ')}');
    }
    if (filter.propertyTypes.isNotEmpty) {
      summary.add('Types: ${filter.propertyTypes.map((t) => _getPropertyTypeName(t)).join(', ')}');
    }
    if (filter.minBedrooms != null || filter.maxBedrooms != null) {
      final bedroomRange = [];
      if (filter.minBedrooms != null) bedroomRange.add('${filter.minBedrooms}+');
      if (filter.maxBedrooms != null) bedroomRange.add('up to ${filter.maxBedrooms}');
      summary.add('Bedrooms: ${bedroomRange.join(' ')}');
    }
    if (filter.amenities.isNotEmpty) {
      summary.add('Amenities: ${filter.amenities.take(2).join(', ')}${filter.amenities.length > 2 ? '...' : ''}');
    }

    return Wrap(
      spacing: 1.w,
      runSpacing: 0.5.h,
      children: summary.map((item) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item,
            style: AppTypography.detail.copyWith(
              color: AppColors.strong,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getPropertyTypeName(PropertyType type) {
    switch (type) {
      case PropertyType.house:
        return 'House';
      case PropertyType.apartment:
        return 'Apartment';
      case PropertyType.condo:
        return 'Condo';
      case PropertyType.townhouse:
        return 'Townhouse';
      case PropertyType.villa:
        return 'Villa';
      case PropertyType.studio:
        return 'Studio';
      case PropertyType.loft:
        return 'Loft';
      case PropertyType.duplex:
        return 'Duplex';
      case PropertyType.penthouse:
        return 'Penthouse';
      case PropertyType.land:
        return 'Land';
      case PropertyType.commercial:
        return 'Commercial';
    }
  }

  String _formatLastTriggered(DateTime? lastTriggered) {
    if (lastTriggered == null) return 'Never triggered';
    
    final now = DateTime.now();
    final difference = now.difference(lastTriggered);

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

  void _handleAlertAction(String action, PropertyAlert alert) {
    switch (action) {
      case 'edit':
        _showCreateAlertDialog(alert: alert);
        break;
      case 'duplicate':
        _duplicateAlert(alert);
        break;
      case 'delete':
        _showDeleteConfirmation(alert);
        break;
    }
  }

  void _duplicateAlert(PropertyAlert alert) {
    final newAlert = alert.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${alert.name} (Copy)',
      createdAt: DateTime.now(),
      matchCount: 0,
      lastTriggered: null,
    );
    ref.read(alertsProvider.notifier).addAlert(newAlert);
  }

  void _showDeleteConfirmation(PropertyAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert'),
        content: Text('Are you sure you want to delete "${alert.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(alertsProvider.notifier).deleteAlert(alert.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alert deleted'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateAlertDialog({PropertyAlert? alert}) {
    final nameController = TextEditingController(text: alert?.name ?? '');
    final isEdit = alert != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Alert' : 'Create Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Alert Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              isEdit 
                  ? 'Alert filters are configured in the advanced search screen.'
                  : 'Configure your alert filters in the advanced search screen.',
              style: AppTypography.body.copyWith(
                color: AppColors.medium,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _navigateToAdvancedSearch(nameController.text.trim(), alert);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.strong,
              foregroundColor: AppColors.white,
            ),
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _navigateToAdvancedSearch(String name, PropertyAlert? existingAlert) {
    // Navigate to advanced search screen with pre-filled filters
    // This would be implemented to pass the existing filter or create a new one
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdvancedSearchScreen(),
      ),
    );
  }
}