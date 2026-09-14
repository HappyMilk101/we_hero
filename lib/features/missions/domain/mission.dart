import 'package:flutter/material.dart';

class Mission {
  const Mission(
    this.title,
    this.description,
    this.category,
    this.minutes,
    this.coin,
    this.xp,
    this.icon, {
    this.id,
  });

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
    json['title'] as String? ?? '추천 Mission',
    json['description'] as String? ?? '',
    json['category'] as String? ?? '',
    (json['estimated_minutes'] as num?)?.toInt() ?? 0,
    (json['base_coin_reward'] as num?)?.toInt() ?? 0,
    (json['base_xp_reward'] as num?)?.toInt() ?? 0,
    iconForCategory(json['category'] as String?),
    id: json['id'] as String?,
  );

  final String? id;
  final String title, description, category;
  final int minutes, coin, xp;
  final IconData icon;

  static IconData iconForCategory(String? category) => switch (category) {
    'environment' || '환경' => Icons.eco,
    'sharing' || '나눔' => Icons.favorite,
    'community' || '지역사회' => Icons.diversity_3,
    _ => Icons.flag,
  };
}
