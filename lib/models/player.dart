import 'dart:convert';

class Player {
  final String id;
  final String name;
  final String displayName;
  final DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    required this.displayName,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      displayName: json['displayName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static String formatName(String input) {
    return input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }
} 