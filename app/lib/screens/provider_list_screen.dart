import 'package:flutter/material.dart';
import 'package:proquote/models/provider.dart';
import 'package:proquote/utils/mock_data.dart';
import 'package:proquote/widgets/provider_card.dart';
import 'package:proquote/utils/constants.dart';
import 'package:proquote/widgets/app_header.dart';

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
            
    final title = widget.categoryFilter != null
        ? '${widget.categoryFilter} Providers'
        : 'Service Providers';

    return Scaffold(
      appBar: AppHeader(
        title: title,
        centerTitle: isLargeScreen,
        showBackButton: true,
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
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
                            const SizedBox(height: AppConstants.itemSpacing),
                            Text(
                              'No providers found',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            if (widget.categoryFilter != null)
                              Padding(
                                padding: const EdgeInsets.all(AppConstants.itemSpacing),
                                child: Text(
                                  'Try searching for a different category',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.screenPadding),
                        itemCount: _filteredProviders.length,
                        itemBuilder: (context, index) {
                          final provider = _filteredProviders[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppConstants.itemSpacing),
                            child: ProviderCard(
                              provider: provider,
                              onTap: () {
                                // Navigate to provider details
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Selected ${provider.name}'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
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