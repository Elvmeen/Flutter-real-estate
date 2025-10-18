import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate/models/house_model.dart';
import 'package:flutter_real_estate/ui/components/strings.dart';
import 'package:flutter_real_estate/ui/components/top_app_bar.dart';
import 'package:flutter_real_estate/ui/theme/type.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/constants.dart';
import '../theme/colors.dart';
import 'messaging_screen.dart';
import 'mortgage_calculator_screen.dart';

class EnhancedDetailScreen extends ConsumerStatefulWidget {
  final HouseData selectedItem;

  const EnhancedDetailScreen({Key? key, required this.selectedItem}) : super(key: key);

  @override
  ConsumerState<EnhancedDetailScreen> createState() => _EnhancedDetailScreenState();
}

class _EnhancedDetailScreenState extends ConsumerState<EnhancedDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _isFavorite = widget.selectedItem.isFavorite;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _launchMapsApp(double latitude, double longitude) async {
    String mapsUrl;
    if (Platform.isAndroid) {
      mapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    } else if (Platform.isIOS) {
      mapsUrl = 'http://maps.apple.com/?daddr=$latitude,$longitude';
    } else {
      throw 'Platform not supported.';
    }
    Uri uri = Uri.parse(mapsUrl);
    await launchUrl(uri);
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    // TODO: Update favorites provider
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TopAppBar(
        title: '',
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : AppColors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.white),
            onPressed: () => _shareProperty(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Image Gallery
          _buildImageGallery(),
          
          // Property Info
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Property Header
                  _buildPropertyHeader(),
                  
                  // Tab Bar
                  _buildTabBar(),
                  
                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(),
                        _buildPhotosTab(),
                        _buildVideosTab(),
                        _buildVirtualToursTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildImageGallery() {
    final images = widget.selectedItem.images.isNotEmpty 
        ? widget.selectedItem.images 
        : [widget.selectedItem.image];
    
    return SizedBox(
      height: 40.h,
      child: Stack(
        children: [
          PageView.builder(
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showImageGallery(images, index),
                child: CachedNetworkImage(
                  imageUrl: Constants.baseAPIUrl + images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              );
            },
          ),
          
          // Image Counter
          if (images.length > 1)
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPropertyHeader() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '\$${widget.selectedItem.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: AppTypography.title01.copyWith(
                    color: AppColors.strong,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.selectedItem.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(widget.selectedItem.status),
                  style: AppTypography.detail.copyWith(
                    color: _getStatusColor(widget.selectedItem.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            '${widget.selectedItem.zip} ${widget.selectedItem.city}',
            style: AppTypography.title02,
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              _buildPropertyFeature(Icons.bed, '${widget.selectedItem.bedrooms} bed'),
              SizedBox(width: 4.w),
              _buildPropertyFeature(Icons.bathtub, '${widget.selectedItem.bathrooms} bath'),
              SizedBox(width: 4.w),
              _buildPropertyFeature(Icons.square_foot, '${widget.selectedItem.size} sq ft'),
              if (widget.selectedItem.distance > 0) ...[
                SizedBox(width: 4.w),
                _buildPropertyFeature(Icons.location_on, '${widget.selectedItem.distance} km'),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 4.w, color: AppColors.medium),
        SizedBox(width: 1.w),
        Text(text, style: AppTypography.detail),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.strong,
        unselectedLabelColor: AppColors.medium,
        indicatorColor: AppColors.strong,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Photos'),
          Tab(text: 'Videos'),
          Tab(text: 'Tours'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text('Description', style: AppTypography.title02),
          SizedBox(height: 2.h),
          Text(widget.selectedItem.description, style: AppTypography.body),
          SizedBox(height: 3.h),

          // Property Details
          Text('Property Details', style: AppTypography.title02),
          SizedBox(height: 2.h),
          _buildPropertyDetails(),
          SizedBox(height: 3.h),

          // Amenities
          if (widget.selectedItem.amenities.isNotEmpty) ...[
            Text('Amenities', style: AppTypography.title02),
            SizedBox(height: 2.h),
            _buildAmenities(),
            SizedBox(height: 3.h),
          ],

          // Agent Info
          if (widget.selectedItem.agent != null) ...[
            Text('Agent', style: AppTypography.title02),
            SizedBox(height: 2.h),
            _buildAgentInfo(),
            SizedBox(height: 3.h),
          ],

          // Location
          Text('Location', style: AppTypography.title02),
          SizedBox(height: 2.h),
          SizedBox(
            height: 30.h,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.selectedItem.latitude.toDouble(),
                  widget.selectedItem.longitude.toDouble(),
                ),
                zoom: 12,
              ),
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('property'),
                  position: LatLng(
                    widget.selectedItem.latitude.toDouble(),
                    widget.selectedItem.longitude.toDouble(),
                  ),
                  infoWindow: const InfoWindow(title: 'Property Location'),
                  onTap: () {
                    _launchMapsApp(
                      widget.selectedItem.latitude.toDouble(),
                      widget.selectedItem.longitude.toDouble(),
                    );
                  },
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetails() {
    return Column(
      children: [
        _buildDetailRow('Property Type', _getPropertyTypeName(widget.selectedItem.propertyType)),
        _buildDetailRow('Year Built', widget.selectedItem.yearBuilt?.toString() ?? 'N/A'),
        _buildDetailRow('Property Style', widget.selectedItem.propertyStyle ?? 'N/A'),
        if (widget.selectedItem.lotSize != null)
          _buildDetailRow('Lot Size', '${widget.selectedItem.lotSize!.toStringAsFixed(1)} sq ft'),
        if (widget.selectedItem.parkingSpaces != null)
          _buildDetailRow('Parking', '${widget.selectedItem.parkingSpaces} spaces'),
        _buildDetailRow('Pool', widget.selectedItem.hasPool == true ? 'Yes' : 'No'),
        _buildDetailRow('Garden', widget.selectedItem.hasGarden == true ? 'Yes' : 'No'),
        _buildDetailRow('Garage', widget.selectedItem.hasGarage == true ? 'Yes' : 'No'),
        if (widget.selectedItem.heatingType != null)
          _buildDetailRow('Heating', widget.selectedItem.heatingType!),
        if (widget.selectedItem.coolingType != null)
          _buildDetailRow('Cooling', widget.selectedItem.coolingType!),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(value, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: widget.selectedItem.amenities.map((amenity) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            amenity,
            style: AppTypography.detail.copyWith(color: AppColors.strong),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAgentInfo() {
    final agent = widget.selectedItem.agent!;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 6.w,
              backgroundImage: agent.profileImage != null 
                  ? NetworkImage(agent.profileImage!) 
                  : null,
              child: agent.profileImage == null 
                  ? Icon(Icons.person, size: 6.w)
                  : null,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(agent.name, style: AppTypography.title02),
                  Text(agent.company ?? '', style: AppTypography.body),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 4.w),
                      SizedBox(width: 1.w),
                      Text('${agent.rating}', style: AppTypography.body),
                      SizedBox(width: 2.w),
                      Text('(${agent.totalSales} sales)', style: AppTypography.detail),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessagingScreen(agent: agent, property: widget.selectedItem),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.strong,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Contact'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosTab() {
    final images = widget.selectedItem.images.isNotEmpty 
        ? widget.selectedItem.images 
        : [widget.selectedItem.image];
    
    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showImageGallery(images, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: Constants.baseAPIUrl + images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideosTab() {
    if (widget.selectedItem.videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 20.w, color: AppColors.medium),
            SizedBox(height: 2.h),
            Text('No videos available', style: AppTypography.title02),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: widget.selectedItem.videos.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 2.h),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.play_circle_outline, size: 50),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Video ${index + 1}',
                  style: AppTypography.title02,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVirtualToursTab() {
    if (widget.selectedItem.virtualTours.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.view_in_ar, size: 20.w, color: AppColors.medium),
            SizedBox(height: 2.h),
            Text('No virtual tours available', style: AppTypography.title02),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: widget.selectedItem.virtualTours.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 2.h),
          child: ListTile(
            leading: const Icon(Icons.view_in_ar, color: AppColors.strong),
            title: Text('Virtual Tour ${index + 1}'),
            subtitle: const Text('Tap to start virtual tour'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Launch virtual tour
              _launchVirtualTour(widget.selectedItem.virtualTours[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.medium.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MortgageCalculatorScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.strong,
                side: const BorderSide(color: AppColors.strong),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (widget.selectedItem.agent != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagingScreen(
                        agent: widget.selectedItem.agent!,
                        property: widget.selectedItem,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.message),
              label: const Text('Contact Agent'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.strong,
                foregroundColor: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageGallery(List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGalleryScreen(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _shareProperty() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _launchVirtualTour(String tourUrl) {
    // Implement virtual tour launch
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Virtual tour functionality coming soon')),
    );
  }

  Color _getStatusColor(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.forSale:
        return Colors.green;
      case PropertyStatus.forRent:
        return Colors.blue;
      case PropertyStatus.sold:
        return Colors.red;
      case PropertyStatus.rented:
        return Colors.orange;
      case PropertyStatus.pending:
        return Colors.amber;
      case PropertyStatus.offMarket:
        return Colors.grey;
    }
  }

  String _getStatusText(PropertyStatus status) {
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
}

class ImageGalleryScreen extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const ImageGalleryScreen({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return PhotoView(
            imageProvider: CachedNetworkImageProvider(
              Constants.baseAPIUrl + images[index],
            ),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
      ),
    );
  }
}