import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../directory/listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  final ListingModel? initialListing;

  const MapViewScreen({super.key, this.initialListing});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();
  String? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    // Center on initial listing if provided
    if (widget.initialListing != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          LatLng(widget.initialListing!.latitude,
              widget.initialListing!.longitude),
          15,
        );
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Color _getCategoryMarkerColor(String category) {
    switch (category) {
      // Healthcare
      case 'Hospital':
      case 'Clinic':
      case 'Pharmacy':
        return Colors.red;
      // Government
      case 'Police Station':
      case 'Government Office':
        return Colors.blue;
      // Dining
      case 'Restaurant':
      case 'Café':
        return Colors.orange;
      // Recreation
      case 'Park':
      case 'Tourist Attraction':
      case 'Gym/Fitness':
      case 'Spa/Wellness':
        return Colors.green;
      // Finance
      case 'Bank':
      case 'ATM':
        return Colors.purple;
      // Shopping
      case 'Supermarket':
      case 'Market':
      case 'Car Wash':
        return Colors.amber;
      case 'Petrol Station':
        return Colors.yellow.shade700;
      // Education & Religion
      case 'Library':
      case 'School':
      case 'Church':
      case 'Mosque':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  void _showListingDetails(ListingModel listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listing: listing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services Map'),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Consumer<ListingProvider>(
        builder: (context, listingProvider, _) {
          final listings = listingProvider.allListings;

          // Filter by selected category
          final filteredListings = _selectedCategoryFilter == null
              ? listings
              : listings
                  .where((l) => l.category == _selectedCategoryFilter)
                  .toList();

          // Create map markers
          final markers = filteredListings.map((listing) {
            final markerColor = _getCategoryMarkerColor(listing.category);
            final isSelected = widget.initialListing?.id == listing.id;
            return Marker(
              point: LatLng(listing.latitude, listing.longitude),
              width: isSelected ? 50 : 40,
              height: isSelected ? 50 : 40,
              child: GestureDetector(
                onTap: () => _showListingDetails(listing),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      painter: MarkerPainter(
                        color: markerColor,
                        isSelected: isSelected,
                      ),
                      size: Size(isSelected ? 50 : 40, isSelected ? 50 : 40),
                    ),
                    Icon(
                      ListingCategory.getCategoryIcon(listing.category),
                      color: Colors.white,
                      size: isSelected ? 24 : 20,
                    ),
                  ],
                ),
              ),
            );
          }).toList();

          return Stack(
            children: [
              // Map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(-1.9536, 29.8739),
                  initialZoom: 12,
                  minZoom: 5,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.kigali_services',
                    maxNativeZoom: 19,
                  ),
                  MarkerLayer(
                    markers: markers,
                  ),
                ],
              ),

              // Category filter chips
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _selectedCategoryFilter == null,
                          onSelected: (_) {
                            setState(() => _selectedCategoryFilter = null);
                          },
                        ),
                        const SizedBox(width: 4),
                        ...ListingCategory.categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: FilterChip(
                              label: Text(category),
                              selected: _selectedCategoryFilter == category,
                              backgroundColor: _getCategoryMarkerColor(category)
                                  .withOpacity(0.1),
                              selectedColor: _getCategoryMarkerColor(category),
                              labelStyle: TextStyle(
                                color: _selectedCategoryFilter == category
                                    ? Colors.white
                                    : null,
                              ),
                              onSelected: (_) {
                                setState(
                                    () => _selectedCategoryFilter = category);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // Zoom buttons
              Positioned(
                bottom: 24,
                right: 16,
                child: Column(
                  children: [
                    FloatingActionButton(
                      mini: true,
                      heroTag: 'zoom_in',
                      onPressed: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        );
                      },
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      mini: true,
                      heroTag: 'zoom_out',
                      onPressed: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        );
                      },
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      mini: true,
                      heroTag: 'center',
                      onPressed: () {
                        _mapController.move(
                          const LatLng(-1.9536, 29.8739),
                          12,
                        );
                      },
                      child: const Icon(Icons.location_searching),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 24,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    '${filteredListings.length} service${filteredListings.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Custom marker painter for map
class MarkerPainter extends CustomPainter {
  final Color color;
  final bool isSelected;

  MarkerPainter({required this.color, this.isSelected = false});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw circle top
    canvas.drawCircle(
      Offset(width / 2, height / 3),
      isSelected ? width / 2.5 : width / 3,
      Paint()..color = color,
    );

    // Draw triangle bottom
    final path = ui.Path();
    path.moveTo(width / 2 - width / 3, height / 3);
    path.lineTo(width / 2, height);
    path.lineTo(width / 2 + width / 3, height / 3);
    path.close();

    canvas.drawPath(
      path,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(MarkerPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isSelected != isSelected;
  }
}
