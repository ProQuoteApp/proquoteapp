import 'package:cloud_firestore/cloud_firestore.dart';

/// UserProfile model for extended profile information
/// This is stored in Firestore and contains additional information beyond
/// what is stored in Firebase Authentication
class UserProfile {
  final String uid;
  final String? displayName;
  final String? email;
  final String? phoneNumber;
  final String? photoURL;
  final String? address;
  final UserType userType;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final Map<String, dynamic>? additionalInfo;

  const UserProfile({
    required this.uid,
    this.displayName,
    this.email,
    this.phoneNumber,
    this.photoURL,
    this.address,
    required this.userType,
    required this.isProfileComplete,
    required this.createdAt,
    this.lastUpdatedAt,
    this.additionalInfo,
  });

  /// Factory constructor to create a UserProfile from a Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'],
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      photoURL: data['photoURL'],
      address: data['address'],
      userType: _userTypeFromString(data['userType'] ?? 'seeker'),
      isProfileComplete: data['isProfileComplete'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdatedAt: data['lastUpdatedAt'] != null
          ? (data['lastUpdatedAt'] as Timestamp).toDate()
          : null,
      additionalInfo: data['additionalInfo'],
    );
  }

  /// Convert to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'address': address,
      'userType': userType.toString().split('.').last,
      'isProfileComplete': isProfileComplete,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdatedAt': lastUpdatedAt != null
          ? Timestamp.fromDate(lastUpdatedAt!)
          : FieldValue.serverTimestamp(),
      'additionalInfo': additionalInfo,
    };
  }

  /// Create a copy of this UserProfile with the given fields replaced
  UserProfile copyWith({
    String? displayName,
    String? email,
    String? phoneNumber,
    String? photoURL,
    String? address,
    UserType? userType,
    bool? isProfileComplete,
    DateTime? lastUpdatedAt,
    Map<String, dynamic>? additionalInfo,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      address: address ?? this.address,
      userType: userType ?? this.userType,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt ?? DateTime.now(),
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  /// Check if this is a service provider
  bool get isServiceProvider => userType == UserType.provider;

  /// Check if this is a service seeker
  bool get isServiceSeeker => userType == UserType.seeker;
}

/// User types in the application
enum UserType {
  /// Service seeker (customer)
  seeker,

  /// Service provider (professional)
  provider,

  /// Admin user
  admin,
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