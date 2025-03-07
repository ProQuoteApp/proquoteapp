class ServiceProvider {
  final String id;
  final String name;
  final String description;
  final String profileImageUrl;
  final List<String> serviceCategories;
  final double rating;
  final int completedJobs;
  final bool isVerified;
  final String location;
  final String contactNumber;
  final String email;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.description,
    required this.profileImageUrl,
    required this.serviceCategories,
    required this.rating,
    required this.completedJobs,
    required this.isVerified,
    required this.location,
    required this.contactNumber,
    required this.email,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      profileImageUrl: json['profileImageUrl'],
      serviceCategories: List<String>.from(json['serviceCategories']),
      rating: json['rating'].toDouble(),
      completedJobs: json['completedJobs'],
      isVerified: json['isVerified'],
      location: json['location'],
      contactNumber: json['contactNumber'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'profileImageUrl': profileImageUrl,
      'serviceCategories': serviceCategories,
      'rating': rating,
      'completedJobs': completedJobs,
      'isVerified': isVerified,
      'location': location,
      'contactNumber': contactNumber,
      'email': email,
    };
  }
} 