import 'package:proquote/models/provider.dart';

class Quote {
  final String id;
  final String jobId;
  final ServiceProvider provider;
  final double amount;
  final String description;
  final DateTime estimatedCompletionDate;
  final DateTime createdAt;
  final String status; // pending, accepted, rejected
  final List<String> includedServices;
  final List<String> excludedServices;
  final bool includesPartsAndMaterials;

  Quote({
    required this.id,
    required this.jobId,
    required this.provider,
    required this.amount,
    required this.description,
    required this.estimatedCompletionDate,
    required this.createdAt,
    required this.status,
    required this.includedServices,
    required this.excludedServices,
    required this.includesPartsAndMaterials,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      jobId: json['jobId'],
      provider: ServiceProvider.fromJson(json['provider']),
      amount: json['amount'].toDouble(),
      description: json['description'],
      estimatedCompletionDate: DateTime.parse(json['estimatedCompletionDate']),
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
      includedServices: List<String>.from(json['includedServices']),
      excludedServices: List<String>.from(json['excludedServices']),
      includesPartsAndMaterials: json['includesPartsAndMaterials'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'provider': provider.toJson(),
      'amount': amount,
      'description': description,
      'estimatedCompletionDate': estimatedCompletionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'includedServices': includedServices,
      'excludedServices': excludedServices,
      'includesPartsAndMaterials': includesPartsAndMaterials,
    };
  }
} 