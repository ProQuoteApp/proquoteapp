import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_user.dart';
import 'user_profile.dart';

/// User model that combines authentication data with profile data
class User {
  final String id;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? address;
  final List<String> jobIds;
  final DateTime createdAt;
  final UserType userType;
  final bool isEmailVerified;
  final bool isProfileComplete;

  User({
    required this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.address,
    required this.jobIds,
    required this.createdAt,
    required this.userType,
    required this.isEmailVerified,
    required this.isProfileComplete,
  });

  /// Factory constructor to create a User from AuthUser and UserProfile
  factory User.fromAuthAndProfile(AuthUser authUser, UserProfile? profile) {
    return User(
      id: authUser.uid,
      name: profile?.displayName ?? authUser.displayName,
      email: profile?.email ?? authUser.email,
      phoneNumber: profile?.phoneNumber ?? authUser.phoneNumber,
      profileImageUrl: profile?.photoURL ?? authUser.photoURL,
      address: profile?.address,
      jobIds: const [], // This would be fetched separately
      createdAt: profile?.createdAt ?? authUser.createdAt ?? DateTime.now(),
      userType: profile?.userType ?? UserType.seeker,
      isEmailVerified: authUser.emailVerified,
      isProfileComplete: profile?.isProfileComplete ?? false,
    );
  }

  /// Factory constructor to create a User from a Firestore document
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'],
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      address: data['address'],
      jobIds: List<String>.from(data['jobIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userType: _userTypeFromString(data['userType'] ?? 'seeker'),
      isEmailVerified: data['isEmailVerified'] ?? false,
      isProfileComplete: data['isProfileComplete'] ?? false,
    );
  }

  /// Convert to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'jobIds': jobIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'userType': userType.toString().split('.').last,
      'isEmailVerified': isEmailVerified,
      'isProfileComplete': isProfileComplete,
    };
  }

  /// Check if this is a service provider
  bool get isServiceProvider => userType == UserType.provider;

  /// Check if this is a service seeker
  bool get isServiceSeeker => userType == UserType.seeker;

  /// Check if this is an admin
  bool get isAdmin => userType == UserType.admin;
}

/// Helper function to convert a string to UserType
UserType _userTypeFromString(String value) {
  switch (value.toLowerCase()) {
    case 'provider':
      return UserType.provider;
    case 'admin':
      return UserType.admin;
    case 'seeker':
    default:
      return UserType.seeker;
  }
} 