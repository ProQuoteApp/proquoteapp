import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../models/auth_user.dart';
import 'storage_service.dart';

/// Service for job-related operations
class JobService {
  final FirebaseFirestore _firestore;
  final StorageService _storageService;
  
  // Cache for jobs to minimize Firestore reads
  final Map<String, Job> _jobCache = {};
  final Map<String, List<Job>> _userJobsCache = {};
  final Map<String, List<Job>> _openJobsCache = {};
  
  // Cache expiration time (5 minutes)
  final Duration _cacheExpiration = const Duration(minutes: 5);
  
  // Cache timestamps
  final Map<String, DateTime> _jobCacheTimestamps = {};
  final Map<String, DateTime> _userJobsCacheTimestamps = {};
  final Map<String, DateTime> _openJobsCacheTimestamps = {};
  
  /// Constructor that allows dependency injection for testing
  JobService({
    FirebaseFirestore? firestore,
    StorageService? storageService,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _storageService = storageService ?? StorageService();
  
  /// Collection reference
  CollectionReference get _jobsCollection => _firestore.collection('jobs');
  
  /// Check if cache is expired
  bool _isCacheExpired(DateTime timestamp) {
    return DateTime.now().difference(timestamp) > _cacheExpiration;
  }
  
  /// Create a new job
  Future<Job?> createJob({
    required String title,
    required String description,
    required String category,
    required String location,
    required DateTime preferredDate,
    required List<String> images,
    required String userId,
  }) async {
    try {
      // Create a new document with auto-generated ID
      final docRef = _jobsCollection.doc();
      
      final job = Job(
        id: docRef.id,
        title: title,
        description: description,
        category: category,
        location: location,
        createdAt: DateTime.now(),
        preferredDate: preferredDate,
        status: 'open',
        images: images,
        userId: userId,
        quoteIds: [],
      );
      
      // Convert to map and save to Firestore
      await docRef.set(job.toJson());
      
      // Also update the user's jobIds array
      await _firestore.collection('users').doc(userId).update({
        'jobIds': FieldValue.arrayUnion([docRef.id]),
      });
      
      // Update cache
      _jobCache[job.id] = job;
      _jobCacheTimestamps[job.id] = DateTime.now();
      
      // Clear user jobs cache to force refresh
      _userJobsCache.remove(userId);
      // Clear open jobs cache as this new job should appear there
      _openJobsCache.clear();
      
      return job;
    } catch (e) {
      print('Error creating job: $e');
      return null;
    }
  }
  
  /// Upload job images and create a job
  Future<Job?> createJobWithImages({
    required String title,
    required String description,
    required String category,
    required String location,
    required DateTime preferredDate,
    required List<File> imageFiles,
    required String userId,
  }) async {
    try {
      // Create a new document with auto-generated ID first to get the job ID
      final docRef = _jobsCollection.doc();
      final jobId = docRef.id;
      
      // Upload images
      final List<String> imageUrls = [];
      
      for (final imageFile in imageFiles) {
        final imageUrl = await _storageService.uploadJobImage(
          jobId: jobId,
          imageFile: imageFile,
        );
        
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      }
      
      // Create the job with image URLs
      final job = Job(
        id: jobId,
        title: title,
        description: description,
        category: category,
        location: location,
        createdAt: DateTime.now(),
        preferredDate: preferredDate,
        status: 'open',
        images: imageUrls,
        userId: userId,
        quoteIds: [],
      );
      
      // Save to Firestore
      await docRef.set(job.toJson());
      
      // Also update the user's jobIds array
      await _firestore.collection('users').doc(userId).update({
        'jobIds': FieldValue.arrayUnion([jobId]),
      });
      
      // Update cache
      _jobCache[job.id] = job;
      _jobCacheTimestamps[job.id] = DateTime.now();
      
      // Clear user jobs cache to force refresh
      _userJobsCache.remove(userId);
      // Clear open jobs cache as this new job should appear there
      _openJobsCache.clear();
      
      return job;
    } catch (e) {
      print('Error creating job with images: $e');
      return null;
    }
  }
  
  /// Upload job images for web platform and create a job
  Future<Job?> createJobWithWebImages({
    required String title,
    required String description,
    required String category,
    required String location,
    required DateTime preferredDate,
    required List<Uint8List> imageBytes,
    required List<String> mimeTypes,
    required String userId,
  }) async {
    try {
      // Create a new document with auto-generated ID first to get the job ID
      final docRef = _jobsCollection.doc();
      final jobId = docRef.id;
      
      // Upload images
      final List<String> imageUrls = [];
      
      for (int i = 0; i < imageBytes.length; i++) {
        final imageUrl = await _storageService.uploadWebImage(
          path: 'jobs/$jobId/${i}_image',
          imageBytes: imageBytes[i],
          mimeType: mimeTypes[i],
        );
        
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      }
      
      // Create the job with image URLs
      final job = Job(
        id: jobId,
        title: title,
        description: description,
        category: category,
        location: location,
        createdAt: DateTime.now(),
        preferredDate: preferredDate,
        status: 'open',
        images: imageUrls,
        userId: userId,
        quoteIds: [],
      );
      
      // Save to Firestore
      await docRef.set(job.toJson());
      
      // Also update the user's jobIds array
      await _firestore.collection('users').doc(userId).update({
        'jobIds': FieldValue.arrayUnion([jobId]),
      });
      
      // Update cache
      _jobCache[job.id] = job;
      _jobCacheTimestamps[job.id] = DateTime.now();
      
      // Clear user jobs cache to force refresh
      _userJobsCache.remove(userId);
      // Clear open jobs cache as this new job should appear there
      _openJobsCache.clear();
      
      return job;
    } catch (e) {
      print('Error creating job with web images: $e');
      return null;
    }
  }
  
  /// Get a job by ID
  Future<Job?> getJob(String jobId) async {
    // Check cache first
    if (_jobCache.containsKey(jobId) && 
        _jobCacheTimestamps.containsKey(jobId) && 
        !_isCacheExpired(_jobCacheTimestamps[jobId]!)) {
      print('Using cached job: $jobId');
      return _jobCache[jobId];
    }
    
    try {
      print('Fetching job from Firestore: $jobId');
      
      // Try to get from cache first, then network if needed
      DocumentSnapshot? doc;
      try {
        doc = await _jobsCollection.doc(jobId).get(const GetOptions(source: Source.cache));
        print('Got job from cache: $jobId');
      } catch (e) {
        print('Cache miss for job: $jobId, fetching from server');
        doc = await _jobsCollection.doc(jobId).get(const GetOptions(source: Source.server));
      }
      
      if (doc.exists) {
        final job = Job.fromJson(doc.data() as Map<String, dynamic>);
        
        // Update cache
        _jobCache[jobId] = job;
        _jobCacheTimestamps[jobId] = DateTime.now();
        
        return job;
      }
      
      return null;
    } catch (e) {
      print('Error getting job: $e');
      return null;
    }
  }
  
  /// Get jobs for a user
  Future<List<Job>?> getUserJobs(
    String userId, {
    int limit = 10,
    String? startAfterId,
  }) async {
    // Check cache first if not paginating
    final cacheKey = userId;
    if (startAfterId == null && 
        _userJobsCache.containsKey(cacheKey) && 
        _userJobsCacheTimestamps.containsKey(cacheKey) && 
        !_isCacheExpired(_userJobsCacheTimestamps[cacheKey]!)) {
      print('Using cached user jobs for: $userId');
      return _userJobsCache[cacheKey];
    }
    
    try {
      print('Fetching user jobs from Firestore: $userId');
      
      // Create query
      Query query = _jobsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      // Add pagination if needed
      if (startAfterId != null) {
        // Get the last document
        final lastDoc = await _jobsCollection.doc(startAfterId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }
      
      // Execute query
      final snapshot = await query.get();
      
      // Convert to jobs
      final jobs = snapshot.docs
          .map((doc) => Job.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      
      // Only update cache for first page
      if (startAfterId == null) {
        _userJobsCache[cacheKey] = jobs;
        _userJobsCacheTimestamps[cacheKey] = DateTime.now();
      }
      
      return jobs;
    } catch (e) {
      print('Error getting user jobs: $e');
      return null;
    }
  }
  
  /// Get open jobs (for service providers)
  Future<List<Job>?> getOpenJobs({
    String? category,
    int limit = 10,
    String? startAfterId,
  }) async {
    // Check cache first if not paginating
    final cacheKey = category ?? 'all';
    if (startAfterId == null && 
        _openJobsCache.containsKey(cacheKey) && 
        _openJobsCacheTimestamps.containsKey(cacheKey) && 
        !_isCacheExpired(_openJobsCacheTimestamps[cacheKey]!)) {
      print('Using cached open jobs for category: $cacheKey');
      return _openJobsCache[cacheKey];
    }
    
    try {
      print('Fetching open jobs from Firestore for category: $cacheKey');
      
      // Create query
      Query query = _jobsCollection
          .where('status', isEqualTo: 'open')
          .orderBy('createdAt', descending: true);
      
      // Add category filter if specified
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      
      // Add limit
      query = query.limit(limit);
      
      // Add pagination if needed
      if (startAfterId != null) {
        // Get the last document
        final lastDoc = await _jobsCollection.doc(startAfterId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }
      
      // Execute query
      final snapshot = await query.get();
      
      // Convert to jobs
      final jobs = snapshot.docs
          .map((doc) => Job.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      
      // Only update cache for first page
      if (startAfterId == null) {
        _openJobsCache[cacheKey] = jobs;
        _openJobsCacheTimestamps[cacheKey] = DateTime.now();
      }
      
      return jobs;
    } catch (e) {
      print('Error getting open jobs: $e');
      return null;
    }
  }
  
  /// Update job status
  Future<bool> updateJobStatus(String jobId, String status) async {
    try {
      await _jobsCollection.doc(jobId).update({'status': status});
      
      // Update cache if job exists in cache
      if (_jobCache.containsKey(jobId)) {
        final job = _jobCache[jobId]!;
        _jobCache[jobId] = Job(
          id: job.id,
          title: job.title,
          description: job.description,
          category: job.category,
          location: job.location,
          createdAt: job.createdAt,
          preferredDate: job.preferredDate,
          status: status, // Updated status
          images: job.images,
          userId: job.userId,
          quoteIds: job.quoteIds,
        );
        _jobCacheTimestamps[jobId] = DateTime.now();
      }
      
      // Clear user jobs cache for this job's user
      if (_jobCache.containsKey(jobId)) {
        final userId = _jobCache[jobId]!.userId;
        _userJobsCache.remove(userId);
      }
      
      // Clear open jobs cache as the status has changed
      _openJobsCache.clear();
      
      return true;
    } catch (e) {
      print('Error updating job status: $e');
      return false;
    }
  }
  
  /// Add a quote ID to a job
  Future<bool> addQuoteToJob(String jobId, String quoteId) async {
    try {
      await _jobsCollection.doc(jobId).update({
        'quoteIds': FieldValue.arrayUnion([quoteId]),
      });
      
      // Update cache if job exists in cache
      if (_jobCache.containsKey(jobId)) {
        final job = _jobCache[jobId]!;
        final updatedQuoteIds = List<String>.from(job.quoteIds)..add(quoteId);
        _jobCache[jobId] = Job(
          id: job.id,
          title: job.title,
          description: job.description,
          category: job.category,
          location: job.location,
          createdAt: job.createdAt,
          preferredDate: job.preferredDate,
          status: job.status,
          images: job.images,
          userId: job.userId,
          quoteIds: updatedQuoteIds, // Updated quote IDs
        );
        _jobCacheTimestamps[jobId] = DateTime.now();
      }
      
      return true;
    } catch (e) {
      print('Error adding quote to job: $e');
      return false;
    }
  }
  
  /// Clear all caches
  void clearCache() {
    _jobCache.clear();
    _userJobsCache.clear();
    _openJobsCache.clear();
    _jobCacheTimestamps.clear();
    _userJobsCacheTimestamps.clear();
    _openJobsCacheTimestamps.clear();
    print('Job cache cleared');
  }
  
  /// Clear cache for a specific job
  void clearJobCache(String jobId) {
    _jobCache.remove(jobId);
    _jobCacheTimestamps.remove(jobId);
    print('Cache cleared for job: $jobId');
  }
  
  /// Clear cache for a user's jobs
  void clearUserJobsCache(String userId) {
    _userJobsCache.remove(userId);
    _userJobsCacheTimestamps.remove(userId);
    print('Cache cleared for user jobs: $userId');
  }
} 