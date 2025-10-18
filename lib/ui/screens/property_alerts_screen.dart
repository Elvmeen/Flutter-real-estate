import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../application/favorites_provider.dart';
import '../../models/favorites_model.dart';
import '../../models/search_filters.dart';
import '../../models/house_model.dart';
import '../theme/colors.dart';
import '../theme/type.dart';

class PropertyAlertsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(propertyAlertsProvider);

    return Column(
      children: [
        // Header with add button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Property Alerts',
                style: AppTypography.title02,
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateAlertDialog(context, ref),
                icon: Icon(Icons.add, size: 18),
                label: Text('New Alert'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.strong,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Alerts list
        Expanded(
          child: alerts.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return AlertCard(alert: alert);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.medium,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Property Alerts',
            style: AppTypography.title02,
          ),
          SizedBox(height: 1.h),
          Text(
            'Create alerts to get notified when properties matching your criteria become available.',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () => _showCreateAlertDialog(context, null),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.strong,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Create Your First Alert'),
          ),
        ],
      ),
    );
  }

  void _showCreateAlertDialog(BuildContext context, WidgetRef? ref) {
    showDialog(
      context: context,
      builder: (context) => CreateAlertDialog(),
    );
  }
}

class AlertCard extends ConsumerWidget {
  final PropertyAlert alert;

  const AlertCard({Key? key, required this.alert}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    alert.name,
                    style: AppTypography.title02,
                  ),
                ),
                Switch(
                  value: alert.isActive,
                  onChanged: (value) {
                    ref.read(propertyAlertsProvider.notifier).toggleAlert(alert.id);
                  },
                  activeColor: AppColors.strong,
                ),
              ],
            ),
            
            SizedBox(height: 1.h),
            
            // Alert criteria summary
            Text(
              _buildCriteriaSummary(alert.filters),
              style: AppTypography.body,
            ),
            
            SizedBox(height: 1.h),
            
            // Frequency and last notified
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppColors.medium),
                SizedBox(width: 1.w),
                Text(
                  'Frequency: ${_getFrequencyText(alert.frequency)}',
                  style: AppTypography.detail,
                ),
              ],
            ),
            
            if (alert.lastNotified != null) ...[
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Icon(Icons.notifications, size: 16, color: AppColors.medium),
                  SizedBox(width: 1.w),
                  Text(
                    'Last notified: ${_formatDate(alert.lastNotified!)}',
                    style: AppTypography.detail,
                  ),
                ],
              ),
            ],
            
            SizedBox(height: 2.h),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _editAlert(context, alert),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.strong,
                      side: BorderSide(color: AppColors.strong),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Edit'),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _deleteAlert(context, ref, alert),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildCriteriaSummary(SearchFilters filters) {
    List<String> criteria = [];
    
    if (filters.location != null) {
      criteria.add('Location: ${filters.location}');
    }
    
    if (filters.minPrice != null || filters.maxPrice != null) {
      String priceRange = 'Price: ';
      if (filters.minPrice != null && filters.maxPrice != null) {
        priceRange += '\$${filters.minPrice!.toInt()} - \$${filters.maxPrice!.toInt()}';
      } else if (filters.minPrice != null) {
        priceRange += 'From \$${filters.minPrice!.toInt()}';
      } else {
        priceRange += 'Up to \$${filters.maxPrice!.toInt()}';
      }
      criteria.add(priceRange);
    }
    
    if (filters.propertyType != null) {
      criteria.add('Type: ${filters.propertyType.toString().split('.').last}');
    }
    
    if (filters.minBedrooms != null) {
      criteria.add('${filters.minBedrooms}+ bedrooms');
    }
    
    if (filters.minBathrooms != null) {
      criteria.add('${filters.minBathrooms}+ bathrooms');
    }
    
    return criteria.isEmpty ? 'All properties' : criteria.join(' • ');
  }

  String _getFrequencyText(AlertFrequency frequency) {
    switch (frequency) {
      case AlertFrequency.immediate:
        return 'Immediate';
      case AlertFrequency.daily:
        return 'Daily';
      case AlertFrequency.weekly:
        return 'Weekly';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Recently';
    }
  }

  void _editAlert(BuildContext context, PropertyAlert alert) {
    showDialog(
      context: context,
      builder: (context) => CreateAlertDialog(existingAlert: alert),
    );
  }

  void _deleteAlert(BuildContext context, WidgetRef ref, PropertyAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Alert'),
        content: Text('Are you sure you want to delete "${alert.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(propertyAlertsProvider.notifier).removeAlert(alert.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class CreateAlertDialog extends ConsumerStatefulWidget {
  final PropertyAlert? existingAlert;

  const CreateAlertDialog({Key? key, this.existingAlert}) : super(key: key);

  @override
  ConsumerState<CreateAlertDialog> createState() => _CreateAlertDialogState();
}

class _CreateAlertDialogState extends ConsumerState<CreateAlertDialog> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  PropertyType? _selectedPropertyType;
  ListingType? _selectedListingType;
  int? _minBedrooms;
  int? _minBathrooms;
  AlertFrequency _frequency = AlertFrequency.immediate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingAlert?.name ?? '');
    _locationController = TextEditingController(text: widget.existingAlert?.filters.location ?? '');
    _minPriceController = TextEditingController(
      text: widget.existingAlert?.filters.minPrice?.toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.existingAlert?.filters.maxPrice?.toString() ?? '',
    );
    _selectedPropertyType = widget.existingAlert?.filters.propertyType;
    _selectedListingType = widget.existingAlert?.filters.listingType;
    _minBedrooms = widget.existingAlert?.filters.minBedrooms;
    _minBathrooms = widget.existingAlert?.filters.minBathrooms;
    _frequency = widget.existingAlert?.frequency ?? AlertFrequency.immediate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingAlert == null ? 'Create Alert' : 'Edit Alert'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Alert Name',
                hintText: 'e.g., Family Home in Downtown',
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'City, neighborhood, or ZIP code',
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    decoration: InputDecoration(labelText: 'Min Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    decoration: InputDecoration(labelText: 'Max Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            DropdownButtonFormField<PropertyType>(
              value: _selectedPropertyType,
              decoration: InputDecoration(labelText: 'Property Type'),
              items: PropertyType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedPropertyType = value),
            ),
            SizedBox(height: 2.h),
            DropdownButtonFormField<AlertFrequency>(
              value: _frequency,
              decoration: InputDecoration(labelText: 'Notification Frequency'),
              items: AlertFrequency.values.map((freq) {
                return DropdownMenuItem(
                  value: freq,
                  child: Text(_getFrequencyText(freq)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _frequency = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveAlert,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.strong),
          child: Text(widget.existingAlert == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }

  void _saveAlert() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an alert name')),
      );
      return;
    }

    final filters = SearchFilters(
      location: _locationController.text.isEmpty ? null : _locationController.text,
      minPrice: _minPriceController.text.isEmpty ? null : double.tryParse(_minPriceController.text),
      maxPrice: _maxPriceController.text.isEmpty ? null : double.tryParse(_maxPriceController.text),
      propertyType: _selectedPropertyType,
      listingType: _selectedListingType,
      minBedrooms: _minBedrooms,
      minBathrooms: _minBathrooms,
    );

    final alert = PropertyAlert(
      id: widget.existingAlert?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user', // In real app, get from auth
      name: _nameController.text,
      filters: filters,
      isActive: true,
      createdAt: widget.existingAlert?.createdAt ?? DateTime.now(),
      frequency: _frequency,
    );

    if (widget.existingAlert == null) {
      ref.read(propertyAlertsProvider.notifier).addAlert(alert);
    } else {
      ref.read(propertyAlertsProvider.notifier).updateAlert(alert);
    }

    Navigator.pop(context);
  }

  String _getFrequencyText(AlertFrequency frequency) {
    switch (frequency) {
      case AlertFrequency.immediate:
        return 'Immediate';
      case AlertFrequency.daily:
        return 'Daily';
      case AlertFrequency.weekly:
        return 'Weekly';
    }
  }
}