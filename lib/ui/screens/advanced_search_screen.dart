import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../models/search_filters.dart';
import '../../models/house_model.dart';
import '../../application/search_provider.dart';
import '../theme/colors.dart';
import '../theme/type.dart';

class AdvancedSearchScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  final _locationController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  
  PropertyType? _selectedPropertyType;
  ListingType? _selectedListingType;
  int? _minBedrooms;
  int? _maxBedrooms;
  int? _minBathrooms;
  int? _maxBathrooms;
  int? _minSize;
  int? _maxSize;
  List<String> _selectedAmenities = [];
  double _maxDistance = 50.0;
  int? _minYearBuilt;
  int? _maxYearBuilt;

  final List<String> _availableAmenities = [
    'Swimming Pool',
    'Gym/Fitness Center',
    'Parking Garage',
    'Balcony/Patio',
    'Fireplace',
    'Air Conditioning',
    'Dishwasher',
    'Washer/Dryer',
    'Pet Friendly',
    'Garden/Yard',
    'Security System',
    'Elevator',
    'Hardwood Floors',
    'Walk-in Closet',
    'Updated Kitchen',
    'Master Suite',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced Search'),
        backgroundColor: AppColors.strong,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location section
            _buildSection(
              'Location',
              [
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'City, neighborhood, or ZIP code',
                    prefixIcon: Icon(Icons.location_on, color: AppColors.medium),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.strong),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text('Max Distance: ${_maxDistance.round()} km', style: AppTypography.body),
                Slider(
                  value: _maxDistance,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  activeColor: AppColors.strong,
                  onChanged: (value) => setState(() => _maxDistance = value),
                ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            // Price section
            _buildSection(
              'Price Range',
              [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minPriceController,
                        decoration: InputDecoration(
                          labelText: 'Min Price',
                          prefixText: '\$',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceController,
                        decoration: InputDecoration(
                          labelText: 'Max Price',
                          prefixText: '\$',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            // Property type section
            _buildSection(
              'Property Type',
              [
                DropdownButtonFormField<PropertyType>(
                  value: _selectedPropertyType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  hint: Text('Select property type'),
                  items: PropertyType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_formatPropertyType(type)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedPropertyType = value),
                ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            // Listing type section
            _buildSection(
              'Listing Type',
              [
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<ListingType>(
                        title: Text('For Sale'),
                        value: ListingType.sale,
                        groupValue: _selectedListingType,
                        activeColor: AppColors.strong,
                        onChanged: (value) => setState(() => _selectedListingType = value),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<ListingType>(
                        title: Text('For Rent'),
                        value: ListingType.rent,
                        groupValue: _selectedListingType,
                        activeColor: AppColors.strong,
                        onChanged: (value) => setState(() => _selectedListingType = value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            // Bedrooms section
            _buildSection(
              'Bedrooms',
              [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _minBedrooms,
                        decoration: InputDecoration(
                          labelText: 'Min Bedrooms',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: List.generate(6, (index) => index).map((num) {
                          return DropdownMenuItem(
                            value: num,
                            child: Text(num == 0 ? 'Studio' : '$num+'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _minBedrooms = value),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _maxBedrooms,
                        decoration: InputDecoration(
                          labelText: 'Max Bedrooms',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: List.generate(6, (index) => index + 1).map((num) {
                          return DropdownMenuItem(
                            value: num,
                            child: Text('$num'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _maxBedrooms = value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            // Bathrooms section
            _buildSection(
              'Bathrooms',
              [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _minBathrooms,
                        decoration: InputDecoration(
                          labelText: 'Min Bathrooms',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: List.generate(5, (index) => index + 1).map((num) {
                          return DropdownMenuItem(
                            value: num,
                            child: Text('$num+'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _minBathrooms = value),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _maxBathrooms,
                        decoration: InputDecoration(
                          labelText: 'Max Bathrooms',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: List.generate(5, (index) => index + 1).map((num) {
                          return DropdownMenuItem(
                            value: num,
                            child: Text('$num'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _maxBathrooms = value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            // Size section
            _buildSection(
              'Property Size (sq ft)',
              [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Min Size',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _minSize = int.tryParse(value),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Max Size',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _maxSize = int.tryParse(value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            // Year built section
            _buildSection(
              'Year Built',
              [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Min Year',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _minYearBuilt = int.tryParse(value),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Max Year',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _maxYearBuilt = int.tryParse(value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 3.h),
            
            // Amenities section
            _buildSection(
              'Amenities',
              [
                Wrap(
                  spacing: 2.w,
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
                      selectedColor: AppColors.strong.withOpacity(0.2),
                      checkmarkColor: AppColors.strong,
                      side: BorderSide(
                        color: isSelected ? AppColors.strong : AppColors.medium,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            
            SizedBox(height: 4.h),
            
            // Search button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.strong,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Search Properties', style: AppTypography.title02),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.title02),
        SizedBox(height: 1.h),
        ...children,
      ],
    );
  }

  String _formatPropertyType(PropertyType type) {
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
      case PropertyType.duplex:
        return 'Duplex';
      case PropertyType.land:
        return 'Land';
    }
  }

  void _clearFilters() {
    setState(() {
      _locationController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedPropertyType = null;
      _selectedListingType = null;
      _minBedrooms = null;
      _maxBedrooms = null;
      _minBathrooms = null;
      _maxBathrooms = null;
      _minSize = null;
      _maxSize = null;
      _selectedAmenities.clear();
      _maxDistance = 50.0;
      _minYearBuilt = null;
      _maxYearBuilt = null;
    });
  }

  void _performSearch() {
    final filters = SearchFilters(
      location: _locationController.text.isEmpty ? null : _locationController.text,
      minPrice: _minPriceController.text.isEmpty ? null : double.tryParse(_minPriceController.text),
      maxPrice: _maxPriceController.text.isEmpty ? null : double.tryParse(_maxPriceController.text),
      propertyType: _selectedPropertyType,
      listingType: _selectedListingType,
      minBedrooms: _minBedrooms,
      maxBedrooms: _maxBedrooms,
      minBathrooms: _minBathrooms,
      maxBathrooms: _maxBathrooms,
      minSize: _minSize,
      maxSize: _maxSize,
      amenities: _selectedAmenities,
      maxDistance: _maxDistance,
      minYearBuilt: _minYearBuilt,
      maxYearBuilt: _maxYearBuilt,
    );

    // Apply filters to search
    ref.read(searchFiltersProvider.notifier).state = filters;
    
    // Navigate back to overview screen
    Navigator.pop(context);
    
    // Show search results
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Search filters applied'),
        action: SnackBarAction(
          label: 'Clear',
          onPressed: () {
            ref.read(searchFiltersProvider.notifier).state = SearchFilters();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }
}