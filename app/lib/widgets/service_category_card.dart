import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ServiceCategoryCard extends StatelessWidget {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const ServiceCategoryCard({
    super.key,
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        height: 140, // Fixed height for the card
        child: ShadCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(name),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 96,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.p.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'painting':
        return Icons.format_paint;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'gardening':
        return Icons.yard;
      case 'carpentry':
        return Icons.handyman;
      case 'roofing':
        return Icons.roofing;
      default:
        return Icons.home_repair_service;
    }
  }
} 