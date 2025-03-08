import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

/// A widget that provides address autocomplete functionality using OpenStreetMap Nominatim
class AddressAutocomplete extends StatefulWidget {
  /// Initial value for the address field
  final String? initialValue;
  
  /// Callback when an address is selected
  final Function(String) onAddressSelected;
  
  /// Decoration for the text field
  final InputDecoration? decoration;
  
  /// Validator function
  final String? Function(String?)? validator;

  /// Constructor
  const AddressAutocomplete({
    super.key,
    this.initialValue,
    required this.onAddressSelected,
    this.decoration,
    this.validator,
  });

  @override
  State<AddressAutocomplete> createState() => _AddressAutocompleteState();
}

class _AddressAutocompleteState extends State<AddressAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  bool _useLocalFallback = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Get address suggestions from OpenStreetMap Nominatim
  Future<List<NominatimPlace>> _getSuggestions(String query) async {
    if (query.length < 3) return [];
    
    setState(() => _isLoading = true);
    
    // If we're using local fallback due to API issues
    if (_useLocalFallback) {
      return _getLocalSuggestions(query);
    }
    
    try {
      // Add 'South Africa' to focus search on South African addresses
      final searchQuery = '$query, South Africa';
      
      // Nominatim API URL with parameters
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?format=json'
        '&q=${Uri.encodeComponent(searchQuery)}'
        '&limit=10'
        '&addressdetails=1'
        '&countrycodes=za'
      );
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'ProQuote App', // Required by Nominatim usage policy
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        // Switch to local fallback on timeout
        setState(() {
          _useLocalFallback = true;
          _errorMessage = 'Network timeout. Using local suggestions.';
        });
        throw TimeoutException('API request timed out');
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final results = data.map((place) => NominatimPlace.fromJson(place)).toList();
        
        // If no results from API, use local fallback
        if (results.isEmpty) {
          return _getLocalSuggestions(query);
        }
        
        return results;
      } else if (response.statusCode == 429) {
        // Rate limited - switch to local fallback
        setState(() {
          _useLocalFallback = true;
          _errorMessage = 'Rate limited. Using local suggestions.';
        });
        return _getLocalSuggestions(query);
      }
      
      return [];
    } catch (e) {
      debugPrint('Error fetching address suggestions: $e');
      
      // Switch to local fallback on error
      setState(() {
        _useLocalFallback = true;
        _errorMessage = 'Network error. Using local suggestions.';
      });
      
      return _getLocalSuggestions(query);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // Local fallback for suggestions when API is unavailable
  Future<List<NominatimPlace>> _getLocalSuggestions(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // South African cities
    final cities = [
      'Johannesburg', 'Cape Town', 'Durban', 'Pretoria', 'Bloemfontein',
      'Port Elizabeth', 'East London', 'Kimberley', 'Polokwane', 'Nelspruit',
      'Rustenburg', 'Pietermaritzburg', 'Stellenbosch', 'George', 'Upington'
    ];
    
    // Filter cities that contain the query
    final filteredCities = cities
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .toList();
    
    // Generate mock suggestions
    final suggestions = <NominatimPlace>[];
    
    for (final city in filteredCities) {
      suggestions.add(
        NominatimPlace(
          placeId: '${city.hashCode}',
          displayName: '$query Street, $city, South Africa',
          lat: 0,
          lon: 0,
          address: {'city': city, 'country': 'South Africa'},
        ),
      );
      suggestions.add(
        NominatimPlace(
          placeId: '${city.hashCode + 1}',
          displayName: '$query Avenue, $city, South Africa',
          lat: 0,
          lon: 0,
          address: {'city': city, 'country': 'South Africa'},
        ),
      );
      suggestions.add(
        NominatimPlace(
          placeId: '${city.hashCode + 2}',
          displayName: '$query Road, $city, South Africa',
          lat: 0,
          lon: 0,
          address: {'city': city, 'country': 'South Africa'},
        ),
      );
    }
    
    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TypeAheadField<NominatimPlace>(
          controller: _controller,
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: widget.decoration?.copyWith(
                suffixIcon: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ) 
                    : const Icon(Icons.location_on),
              ) ?? const InputDecoration(
                labelText: 'Address',
                hintText: 'Start typing to search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            );
          },
          suggestionsCallback: _getSuggestions,
          itemBuilder: (context, place) {
            return ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(place.displayName),
              dense: true,
            );
          },
          onSelected: (place) {
            _controller.text = place.displayName;
            widget.onAddressSelected(place.displayName);
          },
          debounceDuration: const Duration(milliseconds: 500),
        ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _errorMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

/// Model class for Nominatim place data
class NominatimPlace {
  final String placeId;
  final String displayName;
  final double lat;
  final double lon;
  final Map<String, dynamic> address;

  NominatimPlace({
    required this.placeId,
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.address,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    return NominatimPlace(
      placeId: json['place_id'].toString(),
      displayName: json['display_name'] ?? '',
      lat: double.tryParse(json['lat'] ?? '0') ?? 0,
      lon: double.tryParse(json['lon'] ?? '0') ?? 0,
      address: json['address'] ?? {},
    );
  }
}

/// A more advanced implementation that could be used in the future
/// This would connect to a real places API
class PlacesService {
  static Future<List<String>> getPlacePredictions(String input) async {
    // This is where you would implement a real API call
    // For now, we'll just return mock data
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (input.length < 3) return [];
    
    return [
      '$input Street, Johannesburg',
      '$input Avenue, Cape Town',
      '$input Road, Durban',
      '$input Lane, Pretoria',
      '$input Boulevard, Bloemfontein',
    ];
  }
} 