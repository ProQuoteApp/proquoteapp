class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;
  final String address;
  final List<String> jobIds;
  final DateTime createdAt;
  final bool isServiceProvider;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.address,
    required this.jobIds,
    required this.createdAt,
    required this.isServiceProvider,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      address: json['address'],
      jobIds: List<String>.from(json['jobIds']),
      createdAt: DateTime.parse(json['createdAt']),
      isServiceProvider: json['isServiceProvider'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'jobIds': jobIds,
      'createdAt': createdAt.toIso8601String(),
      'isServiceProvider': isServiceProvider,
    };
  }
} 