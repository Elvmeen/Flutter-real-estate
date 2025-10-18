import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dreamhome_real_estate/models/house_model.dart';
import 'package:dreamhome_real_estate/ui/components/strings.dart';
import 'package:dreamhome_real_estate/ui/components/top_app_bar.dart';
import 'package:dreamhome_real_estate/ui/theme/type.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../utils/constants.dart';
import '../../application/favorites_provider.dart';
import '../theme/colors.dart';

class DetailScreen extends ConsumerStatefulWidget {
  // Constructor to initialize the DetailScreen widget with the selected property.
  DetailScreen({Key? key, required this.selectedItem}) : super(key: key);

  // Property data for the selected property.
  final PropertyData selectedItem;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  VideoPlayerController? _videoController;
  int _currentImageIndex = 0;

  // Function to open the maps app with a given latitude and longitude.
  void launchMapsApp(double latitude, double longitude) async {
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

  @override
  void initState() {
    super.initState();
    if (widget.selectedItem.videoUrl != null) {
      _videoController = VideoPlayerController.network(widget.selectedItem.videoUrl!)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = ref.watch(favoritesProvider).contains(widget.selectedItem.id);
    
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  ref.read(favoritesProvider.notifier).toggleFavorite(widget.selectedItem.id);
                },
              ),
            ),
            Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareProperty(),
              ),
            ),
          ],
        ),
        body: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Enhanced media section with carousel
              SizedBox(
                height: MediaQuery.of(context).orientation == Orientation.portrait ? 300 : 250,
                child: _buildMediaCarousel(),
              ),
              Expanded(
                child: Container(
                  // Decorative container for property details.
                  transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 4.h, bottom: 1.h),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text(
                                // Format the property price with commas.
                                '\$${selectedItem.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                style: AppTypography.title01,
                              )),
                              // Add all icons with their associated values
                              SizedBox(width: 1.w),
                              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                SvgPicture.asset(
                                  'assets/icons/ic_bed.svg',
                                  width: 2.h,
                                  height: 2.h,
                                  colorFilter: ColorFilter.mode(AppColors.medium, BlendMode.srcIn),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  selectedItem.bedrooms.toString(),
                                  style: AppTypography.detail,
                                ),
                                SizedBox(width: 4.w),
                                SvgPicture.asset(
                                  'assets/icons/ic_bath.svg',
                                  width: 2.h,
                                  height: 2.h,
                                  colorFilter: ColorFilter.mode(AppColors.medium, BlendMode.srcIn),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  selectedItem.bathrooms.toString(),
                                  style: AppTypography.detail,
                                ),
                                SizedBox(width: 4.w),
                                SvgPicture.asset(
                                  'assets/icons/ic_layers.svg',
                                  width: 2.h,
                                  height: 2.h,
                                  colorFilter: ColorFilter.mode(AppColors.medium, BlendMode.srcIn),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  selectedItem.size.toString(),
                                  style: AppTypography.detail,
                                ),
                                SizedBox(width: 4.w),
                                Visibility(
                                  visible: selectedItem.distance == 0.0 ? false : true,
                                  child: SvgPicture.asset(
                                    'assets/icons/ic_location.svg',
                                    width: 2.h,
                                    height: 2.h,
                                    colorFilter:
                                        ColorFilter.mode(AppColors.medium, BlendMode.srcIn),
                                  ),
                                ),
                                SizedBox(width: 1.w),
                                Visibility(
                                  visible: selectedItem.distance == 0.0 ? false : true,
                                  child: Text(
                                    '${selectedItem.distance} km',
                                    style: AppTypography.detail,
                                  ),
                                ),
                              ]),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          
                          // Property details section
                          _buildPropertyDetails(),
                          
                          SizedBox(height: 3.h),
                          
                          // Amenities section
                          if (widget.selectedItem.amenities.isNotEmpty) ...[
                            const Text(
                              "Amenities",
                              style: AppTypography.title02,
                            ),
                            SizedBox(height: 2.h),
                            _buildAmenitiesGrid(),
                            SizedBox(height: 3.h),
                          ],
                          
                          // Agent section
                          _buildAgentSection(),
                          
                          SizedBox(height: 3.h),
                          
                          const Text(
                            "Description",
                            style: AppTypography.title02,
                          ),
                          SizedBox(height: 2.h),
                          // Display the property description.
                          Text(
                            widget.selectedItem.description,
                            style: AppTypography.body,
                          ),
                          SizedBox(height: 2.h),
                          const Text(
                            "Location",
                            style: AppTypography.title02,
                          ),
                          SizedBox(height: 2.h),
                          SizedBox(
                            height: 34.h,
                            child: GoogleMap(
                              // Display the property location on a map.
                              initialCameraPosition: CameraPosition(
                                target: LatLng(widget.selectedItem.latitude,
                                    widget.selectedItem.longitude),
                                zoom: 12,
                              ),
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                              markers: {
                                // Place a marker at the property location.
                                Marker(
                                    markerId: const MarkerId(Strings.mapsLocationId),
                                    position: LatLng(widget.selectedItem.latitude,
                                        widget.selectedItem.longitude),
                                    infoWindow: const InfoWindow(title: Strings.mapsText),
                                    onTap: () {
                                      launchMapsApp(widget.selectedItem.latitude,
                                          widget.selectedItem.longitude);
                                    }),
                              },
                            ),
                          ),
                          
                          SizedBox(height: 3.h),
                          
                          // Action buttons
                          _buildActionButtons(),
                          
                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]));
  }

  Widget _buildMediaCarousel() {
    final allMedia = <Widget>[];
    
    // Add images
    for (int i = 0; i < widget.selectedItem.images.length; i++) {
      final imageUrl = widget.selectedItem.images[i];
      allMedia.add(
        GestureDetector(
          onTap: () => _openImageGallery(i),
          child: Hero(
            tag: '${widget.selectedItem.id}_image_$i',
            child: CachedNetworkImage(
              imageUrl: imageUrl.startsWith('http') 
                  ? imageUrl 
                  : Constants.baseAPIUrl + imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.lightGray,
                child: Icon(Icons.error, color: AppColors.medium),
              ),
            ),
          ),
        ),
      );
    }
    
    // Add video if available
    if (widget.selectedItem.videoUrl != null && _videoController != null) {
      allMedia.add(_buildVideoPlayer());
    }
    
    // Add virtual tour if available
    if (widget.selectedItem.virtualTourUrl != null) {
      allMedia.add(_buildVirtualTourThumbnail());
    }

    return Stack(
      children: [
        CarouselSlider(
          items: allMedia,
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            enableInfiniteScroll: allMedia.length > 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
        ),
        
        // Media indicators
        if (allMedia.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: allMedia.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
          ),
        
        // Media type indicators
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${allMedia.length}',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () {
              setState(() {
                _videoController!.value.isPlaying
                    ? _videoController!.pause()
                    : _videoController!.play();
              });
            },
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_circle, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('Video', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVirtualTourThumbnail() {
    return GestureDetector(
      onTap: () => _openVirtualTour(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.strong.withOpacity(0.8),
              AppColors.strong,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.view_in_ar, color: Colors.white, size: 64),
              SizedBox(height: 2.h),
              Text(
                'Virtual Tour',
                style: AppTypography.title02.copyWith(color: Colors.white),
              ),
              SizedBox(height: 1.h),
              Text(
                'Tap to explore in 360°',
                style: AppTypography.body.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Property Details', style: AppTypography.title02),
            SizedBox(height: 2.h),
            
            _buildDetailRow('Property Type', widget.selectedItem.propertyType.toString().split('.').last),
            _buildDetailRow('Listing Type', widget.selectedItem.listingType.toString().split('.').last),
            _buildDetailRow('Year Built', widget.selectedItem.yearBuilt.toString()),
            if (widget.selectedItem.lotSize != null)
              _buildDetailRow('Lot Size', '${widget.selectedItem.lotSize} acres'),
            if (widget.selectedItem.parkingType != null)
              _buildDetailRow('Parking', widget.selectedItem.parkingType!),
            if (widget.selectedItem.garageSpaces != null)
              _buildDetailRow('Garage', '${widget.selectedItem.garageSpaces} spaces'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(value, style: AppTypography.detail),
        ],
      ),
    );
  }

  Widget _buildAmenitiesGrid() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: widget.selectedItem.amenities.map((amenity) {
        return Chip(
          label: Text(amenity, style: AppTypography.detail),
          backgroundColor: AppColors.strong.withOpacity(0.1),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  Widget _buildAgentSection() {
    final agent = widget.selectedItem.agent;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Listed by', style: AppTypography.title02),
            SizedBox(height: 2.h),
            
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.lightGray,
                  backgroundImage: agent.profileImage != null
                      ? CachedNetworkImageProvider(agent.profileImage!)
                      : null,
                  child: agent.profileImage == null
                      ? Icon(Icons.person, color: AppColors.medium)
                      : null,
                ),
                SizedBox(width: 3.w),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(agent.name, style: AppTypography.title02),
                      Text(agent.company, style: AppTypography.detail),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 1.w),
                          Text(
                            '${agent.rating.toStringAsFixed(1)} (${agent.reviewCount} reviews)',
                            style: AppTypography.detail,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _callAgent(agent.phone),
                      icon: Icon(Icons.phone, color: AppColors.strong),
                    ),
                    IconButton(
                      onPressed: () => _messageAgent(agent),
                      icon: Icon(Icons.message, color: AppColors.strong),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _scheduleTour(),
            icon: Icon(Icons.schedule),
            label: Text('Schedule Tour'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.strong,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _makeOffer(),
            icon: Icon(Icons.attach_money),
            label: Text('Make Offer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.strong,
              side: BorderSide(color: AppColors.strong),
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openImageGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGalleryScreen(
          images: widget.selectedItem.images,
          initialIndex: initialIndex,
          propertyId: widget.selectedItem.id,
        ),
      ),
    );
  }

  void _openVirtualTour() async {
    if (widget.selectedItem.virtualTourUrl != null) {
      final uri = Uri.parse(widget.selectedItem.virtualTourUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  void _shareProperty() {
    // Implement property sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Property shared!')),
    );
  }

  void _callAgent(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _messageAgent(AgentData agent) {
    // Navigate to messaging with this agent
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting conversation with ${agent.name}')),
    );
  }

  void _scheduleTour() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule Tour'),
        content: Text('Would you like to schedule a tour of this property?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tour request sent to agent!')),
              );
            },
            child: Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _makeOffer() {
    showDialog(
      context: context,
      builder: (context) => MakeOfferDialog(property: widget.selectedItem),
    );
  }
}

class ImageGalleryScreen extends StatelessWidget {
  final List<String> images;
  final int initialIndex;
  final int propertyId;

  const ImageGalleryScreen({
    Key? key,
    required this.images,
    required this.initialIndex,
    required this.propertyId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          final imageUrl = images[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(
              imageUrl.startsWith('http') 
                  ? imageUrl 
                  : Constants.baseAPIUrl + imageUrl,
            ),
            initialScale: PhotoViewComputedScale.contained,
            heroAttributes: PhotoViewHeroAttributes(tag: '${propertyId}_image_$index'),
          );
        },
        itemCount: images.length,
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            color: Colors.white,
          ),
        ),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}

class MakeOfferDialog extends StatefulWidget {
  final PropertyData property;

  const MakeOfferDialog({Key? key, required this.property}) : super(key: key);

  @override
  State<MakeOfferDialog> createState() => _MakeOfferDialogState();
}

class _MakeOfferDialogState extends State<MakeOfferDialog> {
  final _offerController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Make an Offer'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Property: ${widget.property.address}',
              style: AppTypography.body,
            ),
            Text(
              'Listed at: \$${widget.property.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: AppTypography.detail,
            ),
            SizedBox(height: 2.h),
            
            TextField(
              controller: _offerController,
              decoration: InputDecoration(
                labelText: 'Your Offer Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 2.h),
            
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Message to Agent (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
          onPressed: _submitOffer,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.strong),
          child: Text('Submit Offer'),
        ),
      ],
    );
  }

  void _submitOffer() {
    if (_offerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an offer amount')),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Offer submitted to agent!')),
    );
  }

  @override
  void dispose() {
    _offerController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
