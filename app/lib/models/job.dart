class Job {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime createdAt;
  final DateTime preferredDate;
  final String status; // open, in_progress, completed, cancelled
  final List<String> images;
  final String userId;
  final List<String> quoteIds;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.createdAt,
    required this.preferredDate,
    required this.status,
    required this.images,
    required this.userId,
    required this.quoteIds,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      location: json['location'],
      createdAt: DateTime.parse(json['createdAt']),
      preferredDate: DateTime.parse(json['preferredDate']),
      status: json['status'],
      images: List<String>.from(json['images']),
      userId: json['userId'],
      quoteIds: List<String>.from(json['quoteIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'preferredDate': preferredDate.toIso8601String(),
      'status': status,
      'images': images,
      'userId': userId,
      'quoteIds': quoteIds,
    };
  }
} 