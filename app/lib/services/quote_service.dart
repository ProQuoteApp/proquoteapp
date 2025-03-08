import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quote.dart';
import '../models/provider.dart';
import 'job_service.dart';

/// Service for quote-related operations
class QuoteService {
  final FirebaseFirestore _firestore;
  final JobService _jobService;
  
  /// Constructor that allows dependency injection for testing
  QuoteService({
    FirebaseFirestore? firestore,
    JobService? jobService,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _jobService = jobService ?? JobService();
  
  /// Collection reference
  CollectionReference get _quotesCollection => _firestore.collection('quotes');
  
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
    try {
      // Create a new document with auto-generated ID
      final docRef = _quotesCollection.doc();
      
      final quote = Quote(
        id: docRef.id,
        jobId: jobId,
        provider: provider,
        amount: amount,
        description: description,
        estimatedCompletionDate: estimatedCompletionDate,
        createdAt: DateTime.now(),
        status: 'pending',
        includedServices: includedServices,
        excludedServices: excludedServices,
        includesPartsAndMaterials: includesPartsAndMaterials,
      );
      
      // Convert to map and save to Firestore
      await docRef.set(quote.toJson());
      
      // Add the quote ID to the job
      await _jobService.addQuoteToJob(jobId, docRef.id);
      
      return quote;
    } catch (e) {
      print('Error creating quote: $e');
      return null;
    }
  }
  
  /// Get a quote by ID
  Future<Quote?> getQuote(String quoteId) async {
    try {
      final doc = await _quotesCollection.doc(quoteId).get();
      
      if (doc.exists) {
        return Quote.fromJson(doc.data() as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      print('Error getting quote: $e');
      return null;
    }
  }
  
  /// Get all quotes for a job
  Future<List<Quote>> getJobQuotes(String jobId) async {
    try {
      final querySnapshot = await _quotesCollection
          .where('jobId', isEqualTo: jobId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Quote.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting job quotes: $e');
      return [];
    }
  }
  
  /// Get all quotes submitted by a provider
  Future<List<Quote>> getProviderQuotes(String providerId) async {
    try {
      final querySnapshot = await _quotesCollection
          .where('provider.id', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Quote.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting provider quotes: $e');
      return [];
    }
  }
  
  /// Update quote status
  Future<bool> updateQuoteStatus(String quoteId, String status) async {
    try {
      await _quotesCollection.doc(quoteId).update({'status': status});
      
      // If a quote is accepted, update all other quotes for the job to 'rejected'
      if (status == 'accepted') {
        // Get the quote to find its job
        final quoteDoc = await _quotesCollection.doc(quoteId).get();
        if (quoteDoc.exists) {
          final quoteData = quoteDoc.data() as Map<String, dynamic>;
          final jobId = quoteData['jobId'];
          
          // Get all other quotes for this job
          final otherQuotes = await _quotesCollection
              .where('jobId', isEqualTo: jobId)
              .where(FieldPath.documentId, isNotEqualTo: quoteId)
              .get();
          
          // Update all other quotes to rejected
          final batch = _firestore.batch();
          for (var doc in otherQuotes.docs) {
            batch.update(doc.reference, {'status': 'rejected'});
          }
          
          // Also update the job status to in_progress
          batch.update(_firestore.collection('jobs').doc(jobId), {'status': 'in_progress'});
          
          await batch.commit();
        }
      }
      
      return true;
    } catch (e) {
      print('Error updating quote status: $e');
      return false;
    }
  }
} 