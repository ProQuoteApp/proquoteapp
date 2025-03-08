import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../services/job_service.dart';

/// Provider that manages job state
class JobProvider extends ChangeNotifier {
  final JobService _jobService;
  
  List<Job>? _userJobs;
  List<Job>? _openJobs;
  Job? _currentJob;
  bool _isLoading = false;
  String? _error;
  
  // Track if data is from cache
  bool _isUserJobsFromCache = false;
  bool _isOpenJobsFromCache = false;
  bool _isCurrentJobFromCache = false;

  /// Constructor
  JobProvider({
    JobService? jobService,
  }) : _jobService = jobService ?? JobService();

  /// User's jobs
  List<Job>? get userJobs => _userJobs;

  /// Open jobs (for service providers)
  List<Job>? get openJobs => _openJobs;

  /// Currently selected job
  Job? get currentJob => _currentJob;

  /// Whether data is being loaded
  bool get isLoading => _isLoading;

  /// Error message if any
  String? get error => _error;
  
  /// Whether user jobs are from cache
  bool get isUserJobsFromCache => _isUserJobsFromCache;
  
  /// Whether open jobs are from cache
  bool get isOpenJobsFromCache => _isOpenJobsFromCache;
  
  /// Whether current job is from cache
  bool get isCurrentJobFromCache => _isCurrentJobFromCache;

  /// Load jobs for a user
  Future<void> loadUserJobs(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First attempt to load from cache
      _userJobs = await _jobService.getUserJobs(userId);
      
      // If no jobs were found, clear the cache and try again from server
      if (_userJobs == null || _userJobs!.isEmpty) {
        print('No jobs found in cache, forcing server fetch');
        _jobService.clearUserJobsCache(userId);
        _userJobs = await _jobService.getUserJobs(userId);
        _isUserJobsFromCache = false;
      } else {
        _isUserJobsFromCache = true;
      }
    } catch (e) {
      _error = 'Failed to load jobs: $e';
      print('JobProvider: Error loading user jobs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Force refresh jobs for a user (bypass cache)
  Future<void> refreshUserJobs(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Clear the cache for this user's jobs
      _jobService.clearUserJobsCache(userId);
      
      // Load fresh data
      _userJobs = await _jobService.getUserJobs(userId);
      _isUserJobsFromCache = false; // Fresh data
    } catch (e) {
      _error = 'Failed to refresh jobs: $e';
      print('JobProvider: Error refreshing user jobs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load open jobs (for service providers)
  Future<void> loadOpenJobs({String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _openJobs = await _jobService.getOpenJobs(category: category);
      _isOpenJobsFromCache = true; // Assume from cache initially
    } catch (e) {
      _error = 'Failed to load open jobs: $e';
      print('JobProvider: Error loading open jobs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Force refresh open jobs (bypass cache)
  Future<void> refreshOpenJobs({String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Clear the cache
      final cacheKey = category ?? 'all';
      _jobService.clearCache(); // Clear all cache for simplicity
      
      // Load fresh data
      _openJobs = await _jobService.getOpenJobs(category: category);
      _isOpenJobsFromCache = false; // Fresh data
    } catch (e) {
      _error = 'Failed to refresh open jobs: $e';
      print('JobProvider: Error refreshing open jobs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load a specific job
  Future<void> loadJob(String jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentJob = await _jobService.getJob(jobId);
      _isCurrentJobFromCache = true; // Assume from cache initially
      
      if (_currentJob == null) {
        _error = 'Job not found';
      }
    } catch (e) {
      _error = 'Failed to load job: $e';
      print('JobProvider: Error loading job: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Force refresh a specific job (bypass cache)
  Future<void> refreshJob(String jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Clear the cache for this job
      _jobService.clearJobCache(jobId);
      
      // Load fresh data
      _currentJob = await _jobService.getJob(jobId);
      _isCurrentJobFromCache = false; // Fresh data
      
      if (_currentJob == null) {
        _error = 'Job not found';
      }
    } catch (e) {
      _error = 'Failed to refresh job: $e';
      print('JobProvider: Error refreshing job: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new job
  Future<Job?> createJob({
    required String title,
    required String description,
    required String category,
    required String location,
    required DateTime preferredDate,
    required String userId,
    List<String> images = const [],
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final job = await _jobService.createJob(
        title: title,
        description: description,
        category: category,
        location: location,
        preferredDate: preferredDate,
        images: images,
        userId: userId,
      );
      
      if (job != null && _userJobs != null) {
        _userJobs!.insert(0, job);
      }
      
      return job;
    } catch (e) {
      _error = 'Failed to create job: $e';
      print('JobProvider: Error creating job: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Create a new job with images
  Future<Job?> createJobWithImages({
    required String title,
    required String description,
    required String category,
    required String location,
    required DateTime preferredDate,
    required List<File> imageFiles,
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final job = await _jobService.createJobWithImages(
        title: title,
        description: description,
        category: category,
        location: location,
        preferredDate: preferredDate,
        imageFiles: imageFiles,
        userId: userId,
      );
      
      if (job != null && _userJobs != null) {
        _userJobs!.insert(0, job);
      }
      
      return job;
    } catch (e) {
      _error = 'Failed to create job with images: $e';
      print('JobProvider: Error creating job with images: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Create a new job with web images
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final job = await _jobService.createJobWithWebImages(
        title: title,
        description: description,
        category: category,
        location: location,
        preferredDate: preferredDate,
        imageBytes: imageBytes,
        mimeTypes: mimeTypes,
        userId: userId,
      );
      
      if (job != null && _userJobs != null) {
        _userJobs!.insert(0, job);
      }
      
      return job;
    } catch (e) {
      _error = 'Failed to create job with web images: $e';
      print('JobProvider: Error creating job with web images: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update job status
  Future<bool> updateJobStatus(String jobId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _jobService.updateJobStatus(jobId, status);
      
      if (success) {
        // Update the job in our lists
        if (_currentJob != null && _currentJob!.id == jobId) {
          _currentJob = Job(
            id: _currentJob!.id,
            title: _currentJob!.title,
            description: _currentJob!.description,
            category: _currentJob!.category,
            location: _currentJob!.location,
            createdAt: _currentJob!.createdAt,
            preferredDate: _currentJob!.preferredDate,
            status: status,
            images: _currentJob!.images,
            userId: _currentJob!.userId,
            quoteIds: _currentJob!.quoteIds,
          );
        }
        
        if (_userJobs != null) {
          final index = _userJobs!.indexWhere((job) => job.id == jobId);
          if (index != -1) {
            _userJobs![index] = Job(
              id: _userJobs![index].id,
              title: _userJobs![index].title,
              description: _userJobs![index].description,
              category: _userJobs![index].category,
              location: _userJobs![index].location,
              createdAt: _userJobs![index].createdAt,
              preferredDate: _userJobs![index].preferredDate,
              status: status,
              images: _userJobs![index].images,
              userId: _userJobs![index].userId,
              quoteIds: _userJobs![index].quoteIds,
            );
          }
        }
        
        if (_openJobs != null && status != 'open') {
          _openJobs!.removeWhere((job) => job.id == jobId);
        }
      } else {
        _error = 'Failed to update job status';
      }
      
      return success;
    } catch (e) {
      _error = 'Failed to update job status: $e';
      print('JobProvider: Error updating job status: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Update an existing job
  Future<bool> updateJob(Job job) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First update the job status which is the only field we can update for now
      final success = await _jobService.updateJobStatus(job.id, job.status);
      
      if (success) {
        // Update the current job if it's the one being edited
        if (_currentJob != null && _currentJob!.id == job.id) {
          _currentJob = job;
        }
        
        // Update the job in the user's jobs list
        if (_userJobs != null) {
          final index = _userJobs!.indexWhere((j) => j.id == job.id);
          if (index != -1) {
            _userJobs![index] = job;
          }
        }
        
        // Remove from open jobs if status is no longer open
        if (_openJobs != null && job.status != 'open') {
          _openJobs!.removeWhere((j) => j.id == job.id);
        }
      } else {
        _error = 'Failed to update job';
      }
      
      return success;
    } catch (e) {
      _error = 'Failed to update job: $e';
      print('JobProvider: Error updating job: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Clear all caches
  void clearCache() {
    _jobService.clearCache();
  }
} 