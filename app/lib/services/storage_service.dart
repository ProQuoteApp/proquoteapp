import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Service for handling file uploads to Firebase Storage
class StorageService {
  final FirebaseStorage _storage;
  
  /// Constructor that allows dependency injection for testing
  StorageService({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;
  
  /// Upload a job image
  Future<String?> uploadJobImage({
    required String jobId,
    required File imageFile,
  }) async {
    try {
      // Generate a unique ID for the image
      final imageId = const Uuid().v4();
      final path = 'jobs/$jobId/$imageId';
      
      // Create a reference to the file location
      final ref = _storage.ref().child(path);
      
      // Upload the file
      final uploadTask = ref.putFile(imageFile);
      
      // Wait for the upload to complete
      final snapshot = await uploadTask;
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading job image: $e');
      return null;
    }
  }
  
  /// Upload a profile image
  Future<String?> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Use a fixed name for profile images to easily overwrite old ones
      final path = 'users/$userId/profile';
      
      // Create a reference to the file location
      final ref = _storage.ref().child(path);
      
      // Upload the file
      final uploadTask = ref.putFile(imageFile);
      
      // Wait for the upload to complete
      final snapshot = await uploadTask;
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
  
  /// Upload a web image (for Flutter web platform)
  Future<String?> uploadWebImage({
    required String path,
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    try {
      // Create a reference to the file location
      final ref = _storage.ref().child(path);
      
      // Create metadata
      final metadata = SettableMetadata(
        contentType: mimeType,
      );
      
      // Upload the file
      final uploadTask = ref.putData(imageBytes, metadata);
      
      // Wait for the upload to complete
      final snapshot = await uploadTask;
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading web image: $e');
      return null;
    }
  }
  
  /// Delete an image
  Future<bool> deleteImage(String path) async {
    try {
      // Create a reference to the file location
      final ref = _storage.ref().child(path);
      
      // Delete the file
      await ref.delete();
      
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
} 