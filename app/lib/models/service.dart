class Service {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final double averageRating;
  final int totalRatings;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.averageRating,
    required this.totalRatings,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      averageRating: json['averageRating'].toDouble(),
      totalRatings: json['totalRatings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
    };
  }
} 