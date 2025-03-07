import 'package:flutter/material.dart';

/// A widget that provides address autocomplete functionality
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
  final FocusNode _focusNode = FocusNode();
  final List<String> _suggestions = [];
  bool _showSuggestions = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? '';
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  Future<void> _getSuggestions(String query) async {
    if (query.length < 3) {
      setState(() {
        _suggestions.clear();
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // In a real app, this would call a geocoding API
    // For now, we'll just simulate some suggestions
    await Future.delayed(const Duration(milliseconds: 300));
    
    final mockSuggestions = [
      '$query Street, Johannesburg',
      '$query Avenue, Cape Town',
      '$query Road, Durban',
      '$query Lane, Pretoria',
      '$query Boulevard, Bloemfontein',
    ];
    
    setState(() {
      _suggestions.clear();
      _suggestions.addAll(mockSuggestions);
      _showSuggestions = _suggestions.isNotEmpty;
      _isLoading = false;
    });
  }

  void _selectAddress(String address) {
    _controller.text = address;
    widget.onAddressSelected(address);
    setState(() {
      _showSuggestions = false;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
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
          onChanged: (value) {
            _getSuggestions(value);
          },
          validator: widget.validator,
        ),
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  title: Text(_suggestions[index]),
                  leading: const Icon(Icons.location_on, size: 18),
                  onTap: () => _selectAddress(_suggestions[index]),
                );
              },
            ),
          ),
      ],
    );
  }
} 