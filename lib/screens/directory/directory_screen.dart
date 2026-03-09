import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/interaction_provider.dart';
import '../../widgets/listing_card.dart';
import '../../models/listing_model.dart';
import 'listing_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();
    final interaction = context.watch<InteractionProvider>();

    // Filter listings based on category
    final cafes = provider.allListings
        .where((l) =>
            l.category == ListingCategory.cafe ||
            l.category == ListingCategory.restaurant)
        .toList();
    final pharmacies = provider.allListings
        .where((l) => l.category == ListingCategory.pharmacy)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reviews',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(text: 'Cafés (${cafes.length})'),
            Tab(text: 'Pharmacies (${pharmacies.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(cafes, interaction),
          _buildList(pharmacies, interaction),
        ],
      ),
    );
  }

  Widget _buildList(List<ListingModel> items, InteractionProvider interaction) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No results found',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final rating = interaction.getAverageRating(item.id);
        final reviewCount = interaction.getReviewCount(item.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ListingCard(
            listing: item,
            rating: rating,
            reviewCount: reviewCount,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListingDetailScreen(listing: item),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
