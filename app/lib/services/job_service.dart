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
  
  /// Constructor that allows dependency injection for testing
  JobService({
    FirebaseFirestore? firestore,
    StorageService? storageService,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _storageService = storageService ?? StorageService();
  
  /// Collection reference
  CollectionReference get _jobsCollection => _firestore.collection('jobs');
  
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
      
      return job;
    } catch (e) {
      print('Error creating job with web images: $e');
      return null;
    }
  }
  
  /// Get a job by ID
  Future<Job?> getJob(String jobId) async {
    try {
      final doc = await _jobsCollection.doc(jobId).get();
      
      if (doc.exists) {
        return Job.fromJson(doc.data() as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      print('Error getting job: $e');
      return null;
    }
  }
  
  /// Get all jobs for a user
  Future<List<Job>> getUserJobs(String userId) async {
    try {
      final querySnapshot = await _jobsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Job.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting user jobs: $e');
      return [];
    }
  }
  
  /// Get all open jobs (for service providers)
  Future<List<Job>> getOpenJobs({String? category}) async {
    try {
      Query query = _jobsCollection.where('status', isEqualTo: 'open');
      
      // Add category filter if provided
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      
      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Job.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting open jobs: $e');
      return [];
    }
  }
  
  /// Update job status
  Future<bool> updateJobStatus(String jobId, String status) async {
    try {
      await _jobsCollection.doc(jobId).update({'status': status});
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
      return true;
    } catch (e) {
      print('Error adding quote to job: $e');
      return false;
    }
  }
} 