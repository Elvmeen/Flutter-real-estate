import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../models/house_model.dart';
import '../../models/search_filter_model.dart';
import '../components/strings.dart';
import '../theme/colors.dart';
import '../theme/type.dart';

class AdvancedSearchScreen extends ConsumerStatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  ConsumerState<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _minBedroomsController = TextEditingController();
  final _maxBedroomsController = TextEditingController();
  final _minBathroomsController = TextEditingController();
  final _maxBathroomsController = TextEditingController();
  final _minSizeController = TextEditingController();
  final _maxSizeController = TextEditingController();

  SearchFilter _currentFilter = SearchFilter();
  List<PropertyType> _selectedPropertyTypes = [];
  List<String> _selectedAmenities = [];
  PropertyStatus? _selectedStatus;
  bool _hasPool = false;
  bool _hasGarden = false;
  bool _hasGarage = false;

  final List<String> _availableAmenities = [
    'Swimming Pool',
    'Garden',
    'Garage',
    'Parking',
    'Balcony',
    'Terrace',
    'Fireplace',
    'Air Conditioning',
    'Heating',
    'Dishwasher',
    'Washing Machine',
    'Dryer',
    'Gym',
    'Security System',
    'Elevator',
    'Pet Friendly',
    'Furnished',
    'Near School',
    'Near Hospital',
    'Near Shopping',
    'Near Public Transport',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minBedroomsController.dispose();
    _maxBedroomsController.dispose();
    _minBathroomsController.dispose();
    _maxBathroomsController.dispose();
    _minSizeController.dispose();
    _maxSizeController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _currentFilter = SearchFilter(
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        minPrice: _minPriceController.text.isNotEmpty ? double.tryParse(_minPriceController.text) : null,
        maxPrice: _maxPriceController.text.isNotEmpty ? double.tryParse(_maxPriceController.text) : null,
        propertyTypes: _selectedPropertyTypes,
        amenities: _selectedAmenities,
        minBedrooms: _minBedroomsController.text.isNotEmpty ? int.tryParse(_minBedroomsController.text) : null,
        maxBedrooms: _maxBedroomsController.text.isNotEmpty ? int.tryParse(_maxBedroomsController.text) : null,
        minBathrooms: _minBathroomsController.text.isNotEmpty ? int.tryParse(_minBathroomsController.text) : null,
        maxBathrooms: _maxBathroomsController.text.isNotEmpty ? int.tryParse(_maxBathroomsController.text) : null,
        minSize: _minSizeController.text.isNotEmpty ? int.tryParse(_minSizeController.text) : null,
        maxSize: _maxSizeController.text.isNotEmpty ? int.tryParse(_maxSizeController.text) : null,
        status: _selectedStatus,
        hasPool: _hasPool,
        hasGarden: _hasGarden,
        hasGarage: _hasGarage,
      );
    });
  }

  void _clearFilters() {
    setState(() {
      _locationController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _minBedroomsController.clear();
      _maxBedroomsController.clear();
      _minBathroomsController.clear();
      _maxBathroomsController.clear();
      _minSizeController.clear();
      _maxSizeController.clear();
      _selectedPropertyTypes.clear();
      _selectedAmenities.clear();
      _selectedStatus = null;
      _hasPool = false;
      _hasGarden = false;
      _hasGarage = false;
      _currentFilter = SearchFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
        backgroundColor: AppColors.strong,
        foregroundColor: AppColors.white,
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location
              _buildSectionTitle('Location'),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'City, State, or ZIP code',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),

              // Price Range
              _buildSectionTitle('Price Range'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Min Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: TextFormField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Max Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Property Type
              _buildSectionTitle('Property Type'),
              Wrap(
                spacing: 1.w,
                children: PropertyType.values.map((type) {
                  final isSelected = _selectedPropertyTypes.contains(type);
                  return FilterChip(
                    label: Text(_getPropertyTypeDisplayName(type)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPropertyTypes.add(type);
                        } else {
                          _selectedPropertyTypes.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 2.h),

              // Status
              _buildSectionTitle('Status'),
              Wrap(
                spacing: 1.w,
                children: PropertyStatus.values.map((status) {
                  final isSelected = _selectedStatus == status;
                  return FilterChip(
                    label: Text(_getStatusDisplayName(status)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? status : null;
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 2.h),

              // Bedrooms
              _buildSectionTitle('Bedrooms'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minBedroomsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Min',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: TextFormField(
                      controller: _maxBedroomsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Max',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Bathrooms
              _buildSectionTitle('Bathrooms'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minBathroomsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Min',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: TextFormField(
                      controller: _maxBathroomsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Max',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Size
              _buildSectionTitle('Size (sq ft)'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minSizeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Min Size',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: TextFormField(
                      controller: _maxSizeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Max Size',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Features
              _buildSectionTitle('Features'),
              Wrap(
                spacing: 1.w,
                children: [
                  FilterChip(
                    label: const Text('Pool'),
                    selected: _hasPool,
                    onSelected: (selected) {
                      setState(() {
                        _hasPool = selected;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Garden'),
                    selected: _hasGarden,
                    onSelected: (selected) {
                      setState(() {
                        _hasGarden = selected;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Garage'),
                    selected: _hasGarage,
                    onSelected: (selected) {
                      setState(() {
                        _hasGarage = selected;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Amenities
              _buildSectionTitle('Amenities'),
              Wrap(
                spacing: 1.w,
                runSpacing: 1.h,
                children: _availableAmenities.map((amenity) {
                  final isSelected = _selectedAmenities.contains(amenity);
                  return FilterChip(
                    label: Text(amenity),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAmenities.add(amenity);
                        } else {
                          _selectedAmenities.remove(amenity);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 4.h),

              // Search Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context, _currentFilter);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.strong,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Search Properties',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        title,
        style: AppTypography.title02.copyWith(
          color: AppColors.strong,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getPropertyTypeDisplayName(PropertyType type) {
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

  String _getStatusDisplayName(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.forSale:
        return 'For Sale';
      case PropertyStatus.forRent:
        return 'For Rent';
      case PropertyStatus.sold:
        return 'Sold';
      case PropertyStatus.rented:
        return 'Rented';
      case PropertyStatus.pending:
        return 'Pending';
      case PropertyStatus.offMarket:
        return 'Off Market';
    }
  }
}