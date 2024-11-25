import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class ActivityItem extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final ActivityType type;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, subtitle, timestamp, type];

  IconData get icon {
    switch (type) {
      case ActivityType.stock:
        return Icons.inventory_2_outlined;
      case ActivityType.order:
        return Icons.shopping_cart_outlined;
      case ActivityType.user:
        return Icons.person_outline;
      case ActivityType.delivery:
        return Icons.local_shipping_outlined;
    }
  }

  Color get color {
    switch (type) {
      case ActivityType.stock:
        return Colors.blue;
      case ActivityType.order:
        return Colors.green;
      case ActivityType.user:
        return Colors.orange;
      case ActivityType.delivery:
        return Colors.purple;
    }
  }

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return timestamp.toString().substring(0, 10);
    }
  }

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: ActivityType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => ActivityType.stock,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
    };
  }
}

enum ActivityType {
  stock,
  order,
  user,
  delivery,
}