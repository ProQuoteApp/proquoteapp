import 'package:flutter/foundation.dart';
import '../models/quote.dart';
import '../models/provider.dart';
import '../services/quote_service.dart';

/// Provider that manages quote state
class QuoteProvider extends ChangeNotifier {
  final QuoteService _quoteService;
  
  List<Quote>? _jobQuotes;
  List<Quote>? _providerQuotes;
  Quote? _currentQuote;
  bool _isLoading = false;
  String? _error;

  /// Constructor
  QuoteProvider({
    QuoteService? quoteService,
  }) : _quoteService = quoteService ?? QuoteService();

  /// Quotes for a job
  List<Quote>? get jobQuotes => _jobQuotes;

  /// Quotes submitted by a provider
  List<Quote>? get providerQuotes => _providerQuotes;

  /// Currently selected quote
  Quote? get currentQuote => _currentQuote;

  /// Whether data is being loaded
  bool get isLoading => _isLoading;

  /// Error message if any
  String? get error => _error;

  /// Load quotes for a job
  Future<void> loadJobQuotes(String jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _jobQuotes = await _quoteService.getJobQuotes(jobId);
    } catch (e) {
      _error = 'Failed to load quotes: $e';
      print('QuoteProvider: Error loading job quotes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load quotes submitted by a provider
  Future<void> loadProviderQuotes(String providerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _providerQuotes = await _quoteService.getProviderQuotes(providerId);
    } catch (e) {
      _error = 'Failed to load provider quotes: $e';
      print('QuoteProvider: Error loading provider quotes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load a specific quote
  Future<void> loadQuote(String quoteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentQuote = await _quoteService.getQuote(quoteId);
      
      if (_currentQuote == null) {
        _error = 'Quote not found';
      }
    } catch (e) {
      _error = 'Failed to load quote: $e';
      print('QuoteProvider: Error loading quote: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new quote
  Future<Quote?> createQuote({
    required String jobId,
    required ServiceProvider provider,
    required double amount,
    required String description,
    required DateTime estimatedCompletionDate,
    required List<String> includedServices,
    required List<String> excludedServices,
    required bool includesPartsAndMaterials,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final quote = await _quoteService.createQuote(
        jobId: jobId,
        provider: provider,
        amount: amount,
        description: description,
        estimatedCompletionDate: estimatedCompletionDate,
        includedServices: includedServices,
        excludedServices: excludedServices,
        includesPartsAndMaterials: includesPartsAndMaterials,
      );
      
      if (quote != null) {
        // Add to job quotes if we're viewing that job
        if (_jobQuotes != null && quote.jobId == jobId) {
          _jobQuotes!.insert(0, quote);
        }
        
        // Add to provider quotes if we're viewing that provider
        if (_providerQuotes != null && quote.provider.id == provider.id) {
          _providerQuotes!.insert(0, quote);
        }
      }
      
      return quote;
    } catch (e) {
      _error = 'Failed to create quote: $e';
      print('QuoteProvider: Error creating quote: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update quote status
  Future<bool> updateQuoteStatus(String quoteId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _quoteService.updateQuoteStatus(quoteId, status);
      
      if (success) {
        // Update the quote in our lists
        if (_currentQuote != null && _currentQuote!.id == quoteId) {
          _currentQuote = Quote(
            id: _currentQuote!.id,
            jobId: _currentQuote!.jobId,
            provider: _currentQuote!.provider,
            amount: _currentQuote!.amount,
            description: _currentQuote!.description,
            estimatedCompletionDate: _currentQuote!.estimatedCompletionDate,
            createdAt: _currentQuote!.createdAt,
            status: status,
            includedServices: _currentQuote!.includedServices,
            excludedServices: _currentQuote!.excludedServices,
            includesPartsAndMaterials: _currentQuote!.includesPartsAndMaterials,
          );
        }
        
        // If this quote was accepted, we need to update all quotes for this job
        if (status == 'accepted' && _jobQuotes != null) {
          // Find the job ID from the current quote
          String? jobId;
          if (_currentQuote != null) {
            jobId = _currentQuote!.jobId;
          } else {
            // Find the quote in our lists
            final quoteInList = _jobQuotes!.firstWhere(
              (q) => q.id == quoteId,
              orElse: () => _providerQuotes?.firstWhere(
                (q) => q.id == quoteId,
                orElse: () => Quote(
                  id: '',
                  jobId: '',
                  provider: ServiceProvider(
                    id: '',
                    name: '',
                    description: '',
                    profileImageUrl: '',
                    serviceCategories: [],
                    rating: 0,
                    completedJobs: 0,
                    isVerified: false,
                    location: '',
                    contactNumber: '',
                    email: '',
                  ),
                  amount: 0,
                  description: '',
                  estimatedCompletionDate: DateTime.now(),
                  createdAt: DateTime.now(),
                  status: '',
                  includedServices: [],
                  excludedServices: [],
                  includesPartsAndMaterials: false,
                ),
              ) ?? Quote(
                id: '',
                jobId: '',
                provider: ServiceProvider(
                  id: '',
                  name: '',
                  description: '',
                  profileImageUrl: '',
                  serviceCategories: [],
                  rating: 0,
                  completedJobs: 0,
                  isVerified: false,
                  location: '',
                  contactNumber: '',
                  email: '',
                ),
                amount: 0,
                description: '',
                estimatedCompletionDate: DateTime.now(),
                createdAt: DateTime.now(),
                status: '',
                includedServices: [],
                excludedServices: [],
                includesPartsAndMaterials: false,
              ),
            );
            
            jobId = quoteInList.jobId;
          }
          
          if (jobId != null && jobId.isNotEmpty) {
            // Reload all quotes for this job to get the updated statuses
            await loadJobQuotes(jobId);
          }
        }
      } else {
        _error = 'Failed to update quote status';
      }
      
      return success;
    } catch (e) {
      _error = 'Failed to update quote status: $e';
      print('QuoteProvider: Error updating quote status: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 