import 'package:flutter/material.dart';
import 'package:proquote/models/provider.dart';
import 'package:proquote/utils/mock_data.dart';
import 'package:proquote/widgets/provider_card.dart';
import 'package:proquote/utils/constants.dart';

class ProviderListScreen extends StatefulWidget {
  final String? categoryFilter;

  const ProviderListScreen({
    super.key,
    this.categoryFilter,
  });

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  late List<ServiceProvider> _filteredProviders;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filterProviders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProviders() {
    _filteredProviders = MockData.providers.where((provider) {
      // Apply category filter if provided
      if (widget.categoryFilter != null &&
          !provider.serviceCategories.contains(widget.categoryFilter)) {
        return false;
      }

      // Apply search filter if provided
      if (_searchQuery.isNotEmpty) {
        return provider.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            provider.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            provider.location.toLowerCase().contains(_searchQuery.toLowerCase());
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to handle responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;
    
    // Calculate content width based on screen size
    final contentWidth = isLargeScreen 
        ? 900.0 
        : isMediumScreen 
            ? screenWidth * 0.9 
            : screenWidth;
            
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryFilter != null
            ? '${widget.categoryFilter} Providers'
            : 'Service Providers'),
        centerTitle: isLargeScreen,
      ),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(AppConstants.screenPadding),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search providers...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _filterProviders();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterProviders();
                    });
                  },
                ),
              ),

              // Filter chips
              if (widget.categoryFilter == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: MockData.serviceCategories.length,
                      itemBuilder: (context, index) {
                        final category = MockData.serviceCategories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category['name'] as String),
                            selected: false,
                            onSelected: (selected) {
                              // In a real app, this would filter by category
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProviderListScreen(
                                    categoryFilter: category['name'] as String,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Provider list
              Expanded(
                child: _filteredProviders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No providers found',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredProviders.length,
                        itemBuilder: (context, index) {
                          final provider = _filteredProviders[index];
                          return ProviderCard(
                            provider: provider,
                            onTap: () {
                              // Navigate to provider details
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 