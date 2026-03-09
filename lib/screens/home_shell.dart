import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../providers/auth_provider.dart' as ap;
import '../providers/listing_provider.dart';
import '../providers/interaction_provider.dart';
import '../services/location_service.dart';
import 'home_screen.dart';
import 'directory/reviews_screen.dart';
import 'bookmarks/bookmarks_screen.dart';
import 'settings/settings_screen.dart';
import 'map/map_view_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  void _navigateToDirectory() {
    setState(() {
      _currentIndex = 1; // Index of ReviewsScreen
    });
  }

  Future<void> _getUserLocation(ListingProvider listingProvider) async {
    listingProvider.setLoadingLocation(true);

    // Try to get user location
    final location = await LocationService.getCurrentLocation();

    if (location != null) {
      listingProvider.setUserLocation(location);
    } else {
      // Default to Kigali city center if location not available
      listingProvider.setUserLocation(const LatLng(-1.9536, 29.8739));
    }

    listingProvider.setLoadingLocation(false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listingProvider = context.read<ListingProvider>();
      final authProvider = context.read<ap.AuthProvider>();
      final interactionProvider = context.read<InteractionProvider>();

      // Subscribe to all listings
      listingProvider.subscribeAllListings();

      // Get user location
      _getUserLocation(listingProvider);

      // Load ratings after a short delay to let listings load
      Future.delayed(const Duration(milliseconds: 1500), () {
        final listings = listingProvider.allListings;
        if (listings.isNotEmpty) {
          final listingIds = listings.map((l) => l.id).toList();
          interactionProvider.loadRatingsForListings(listingIds);
        }
      });

      if (authProvider.currentUid != null) {
        listingProvider.subscribeMyListings(authProvider.currentUid!);
        interactionProvider.subscribeToBookmarks(authProvider.currentUid!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToDirectory: _navigateToDirectory),
      const ReviewsScreen(),
      const BookmarksScreen(),
      const MapViewScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.rate_review_outlined),
            selectedIcon: Icon(Icons.rate_review_rounded),
            label: 'Reviews',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Bookmarks',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
