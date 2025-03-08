import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:proquote/providers/auth_provider.dart';
import 'package:proquote/providers/job_provider.dart';
import 'package:proquote/services/job_service.dart';
import 'package:proquote/widgets/address_autocomplete.dart';
import 'package:proquote/widgets/app_header.dart';
import 'package:proquote/models/job.dart';
import 'package:proquote/utils/constants.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:intl/intl.dart';

class CreateJobScreen extends StatefulWidget {
  final Job? jobToEdit;

  const CreateJobScreen({
    super.key,
    this.jobToEdit,
  });

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime _preferredDate = DateTime.now().add(const Duration(days: 3));
  String _selectedCategory = 'Plumbing'; // Default category
  bool _isSubmitting = false;
  String? _error;
  bool _isEditMode = false;
  
  // List of service categories
  final List<String> _categories = [
    'Plumbing',
    'Electrical',
    'Painting',
    'Cleaning',
    'Gardening',
    'Carpentry',
  ];

  @override
  void initState() {
    super.initState();
    
    // Check if we're in edit mode
    if (widget.jobToEdit != null) {
      _isEditMode = true;
      _titleController.text = widget.jobToEdit!.title;
      _descriptionController.text = widget.jobToEdit!.description;
      _locationController.text = widget.jobToEdit!.location;
      _selectedCategory = widget.jobToEdit!.category;
      
      // Parse the preferred date if available
      if (widget.jobToEdit!.preferredDate != null) {
        _preferredDate = widget.jobToEdit!.preferredDate!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _preferredDate) {
      setState(() {
        _preferredDate = picked;
      });
    }
  }

  Future<void> _submitJob() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _error = null;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final jobProvider = Provider.of<JobProvider>(context, listen: false);
        
        if (authProvider.currentUser == null) {
          throw Exception('You must be logged in to create a job');
        }
        
        final userId = authProvider.currentUser!.uid;
        
        if (_isEditMode && widget.jobToEdit != null) {
          // Update existing job
          final updatedJob = Job(
            id: widget.jobToEdit!.id,
            userId: userId,
            title: _titleController.text,
            description: _descriptionController.text,
            category: _selectedCategory,
            location: _locationController.text,
            preferredDate: _preferredDate,
            status: widget.jobToEdit!.status,
            createdAt: widget.jobToEdit!.createdAt,
            images: widget.jobToEdit!.images, // Keep existing images
            quoteIds: widget.jobToEdit!.quoteIds, // Keep existing quotes
          );
          
          final success = await jobProvider.updateJob(updatedJob);
          
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Job updated successfully')),
            );
            context.go('/job/${widget.jobToEdit!.id}');
          } else if (mounted) {
            throw Exception(jobProvider.error ?? 'Failed to update job');
          }
        } else {
          // Create new job
          final newJob = await jobProvider.createJob(
            userId: userId,
            title: _titleController.text,
            description: _descriptionController.text,
            category: _selectedCategory,
            location: _locationController.text,
            preferredDate: _preferredDate,
            images: [], // No images for now
          );
          
          if (newJob != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Job created successfully')),
            );
            context.go('/job/${newJob.id}');
          } else if (mounted) {
            throw Exception(jobProvider.error ?? 'Failed to create job');
          }
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
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
      appBar: AppHeader(
        title: _isEditMode ? 'Edit Job' : 'Create Job',
        showBackButton: true,
        centerTitle: isLargeScreen,
      ),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.screenPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message if any
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.itemSpacing),
                      child: Container(
                        padding: const EdgeInsets.all(AppConstants.itemSpacing),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Error',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  Text(_error!, style: TextStyle(color: Colors.red.shade700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Title
                  const Text('Job Title'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Fix leaking bathroom sink',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Category
                  const Text('Category'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  const Text('Description'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Describe the job in detail...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    minLines: 3,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Location
                  const Text('Location'),
                  const SizedBox(height: 8),
                  AddressAutocomplete(
                    initialValue: _locationController.text,
                    onAddressSelected: (address) {
                      _locationController.text = address;
                    },
                    decoration: InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter your address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Preferred Date
                  const Text('Preferred Date'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('EEEE, MMMM d, yyyy').format(_preferredDate)),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitJob,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Job'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 