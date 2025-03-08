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
  bool _isLoadingMore = false;
  String? _error;
  
  // Track if data is from cache
  bool _isUserJobsFromCache = false;
  bool _isOpenJobsFromCache = false;
  bool _isCurrentJobFromCache = false;
  
  // Pagination parameters
  static const int _pageSize = 10;
  String? _lastDocumentId;
  bool _hasMoreJobs = true;

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
  
  /// Whether more data is being loaded
  bool get isLoadingMore => _isLoadingMore;

  /// Error message if any
  String? get error => _error;
  
  /// Whether user jobs are from cache
  bool get isUserJobsFromCache => _isUserJobsFromCache;
  
  /// Whether open jobs are from cache
  bool get isOpenJobsFromCache => _isOpenJobsFromCache;
  
  /// Whether current job is from cache
  bool get isCurrentJobFromCache => _isCurrentJobFromCache;
  
  /// Whether there are more jobs to load
  bool get hasMoreJobs => _hasMoreJobs;

  /// Load jobs for a user
  Future<void> loadUserJobs(String userId) async {
    _isLoading = true;
    _error = null;
    _lastDocumentId = null;
    _hasMoreJobs = true;
    notifyListeners();

    try {
      // First attempt to load from cache
      _userJobs = await _jobService.getUserJobs(
        userId, 
        limit: _pageSize,
      );
      
      // If no jobs were found, clear the cache and try again from server
      if (_userJobs == null || _userJobs!.isEmpty) {
        print('No jobs found in cache, forcing server fetch');
        _jobService.clearUserJobsCache(userId);
        _userJobs = await _jobService.getUserJobs(
          userId,
          limit: _pageSize,
        );
        _isUserJobsFromCache = false;
      } else {
        _isUserJobsFromCache = true;
      }
      
      // Update pagination state
      _updatePaginationState(_userJobs);
    } catch (e) {
      _error = 'Failed to load jobs: $e';
      print('JobProvider: Error loading user jobs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load more user jobs (pagination)
  Future<void> loadMoreUserJobs(String userId) async {
    // Don't load more if we're already loading or there are no more jobs
    if (_isLoadingMore || !_hasMoreJobs || _lastDocumentId == null) {
      return;
    }
    
    _isLoadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final moreJobs = await _jobService.getUserJobs(
        userId,
        limit: _pageSize,
        startAfterId: _lastDocumentId,
      );
      
      if (moreJobs != null && moreJobs.isNotEmpty) {
        _userJobs = [...?_userJobs, ...moreJobs];
        _updatePaginationState(moreJobs);
      } else {
        _hasMoreJobs = false;
      }
    } catch (e) {
      _error = 'Failed to load more jobs: $e';
      print('JobProvider: Error loading more user jobs: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  /// Force refresh jobs for a user (bypass cache)
  Future<void> refreshUserJobs(String userId) async {
    _isLoading = true;
    _error = null;
    _lastDocumentId = null;
    _hasMoreJobs = true;
    notifyListeners();

    try {
      // Clear the cache for this user's jobs
      _jobService.clearUserJobsCache(userId);
      
      // Load fresh data
      _userJobs = await _jobService.getUserJobs(
        userId,
        limit: _pageSize,
      );
      _isUserJobsFromCache = false; // Fresh data
      
      // Update pagination state
      _updatePaginationState(_userJobs);
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
    _lastDocumentId = null;
    _hasMoreJobs = true;
    notifyListeners();

    try {
      _openJobs = await _jobService.getOpenJobs(
        category: category,
        limit: _pageSize,
      );
      _isOpenJobsFromCache = true; // Assume from cache initially
      
      // Update pagination state
      _updatePaginationState(_openJobs);
    } catch (e) {
      _error = 'Failed to load open jobs: $e';
      print('JobProvider: Error loading open jobs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load more open jobs (pagination)
  Future<void> loadMoreOpenJobs({String? category}) async {
    // Don't load more if we're already loading or there are no more jobs
    if (_isLoadingMore || !_hasMoreJobs || _lastDocumentId == null) {
      return;
    }
    
    _isLoadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final moreJobs = await _jobService.getOpenJobs(
        category: category,
        limit: _pageSize,
        startAfterId: _lastDocumentId,
      );
      
      if (moreJobs != null && moreJobs.isNotEmpty) {
        _openJobs = [...?_openJobs, ...moreJobs];
        _updatePaginationState(moreJobs);
      } else {
        _hasMoreJobs = false;
      }
    } catch (e) {
      _error = 'Failed to load more open jobs: $e';
      print('JobProvider: Error loading more open jobs: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  /// Force refresh open jobs (bypass cache)
  Future<void> refreshOpenJobs({String? category}) async {
    _isLoading = true;
    _error = null;
    _lastDocumentId = null;
    _hasMoreJobs = true;
    notifyListeners();

    try {
      // Clear the cache
      final cacheKey = category ?? 'all';
      _jobService.clearCache(); // Clear all cache for simplicity
      
      // Load fresh data
      _openJobs = await _jobService.getOpenJobs(
        category: category,
        limit: _pageSize,
      );
      _isOpenJobsFromCache = false; // Fresh data
      
      // Update pagination state
      _updatePaginationState(_openJobs);
    } catch (e) {
      _error = 'Failed to refresh open jobs: $e';
      print('JobProvider: Error refreshing open jobs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Update pagination state based on loaded jobs
  void _updatePaginationState(List<Job>? jobs) {
    if (jobs == null || jobs.isEmpty) {
      _hasMoreJobs = false;
      return;
    }
    
    // If we got fewer jobs than the page size, there are no more jobs
    if (jobs.length < _pageSize) {
      _hasMoreJobs = false;
    } else {
      _hasMoreJobs = true;
      // Store the ID of the last document for pagination
      _lastDocumentId = jobs.last.id;
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
        // Update job in cache
        if (_currentJob != null && _currentJob!.id == jobId) {
          _currentJob = _currentJob!.copyWith(status: status);
        }
        
        // Update job in user jobs list
        if (_userJobs != null) {
          final index = _userJobs!.indexWhere((job) => job.id == jobId);
          if (index != -1) {
            _userJobs![index] = _userJobs![index].copyWith(status: status);
          }
        }
        
        // Update job in open jobs list
        if (_openJobs != null) {
          final index = _openJobs!.indexWhere((job) => job.id == jobId);
          if (index != -1) {
            // If status is not 'open', remove from open jobs
            if (status != 'open') {
              _openJobs!.removeAt(index);
            } else {
              _openJobs![index] = _openJobs![index].copyWith(status: status);
            }
          }
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