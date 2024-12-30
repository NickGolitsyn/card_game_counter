import 'dart:convert';

class Game {
  final String id;
  final String title;
  final String type;
  final List<String> players;
  final List<List<int>> scores;
  final List<String> roundWinners;
  final DateTime createdAt;
  final DateTime lastModified;
  final bool isDraftGame;

  Game({
    required this.id,
    required this.title,
    required this.type,
    required this.players,
    required this.scores,
    required this.roundWinners,
    required this.createdAt,
    required this.lastModified,
    this.isDraftGame = false,
  });

  List<int> get totalScores {
    return List.generate(players.length, (playerIndex) {
      return scores.fold<int>(
        0,
        (sum, roundScores) => sum + roundScores[playerIndex],
      );
    });
  }

  Game copyWith({
    String? id,
    String? title,
    String? type,
    List<String>? players,
    List<List<int>>? scores,
    List<String>? roundWinners,
    DateTime? createdAt,
    DateTime? lastModified,
    bool? isDraftGame,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      players: players ?? this.players,
      scores: scores ?? this.scores,
      roundWinners: roundWinners ?? this.roundWinners,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      isDraftGame: isDraftGame ?? this.isDraftGame,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'players': players,
      'scores': scores,
      'roundWinners': roundWinners,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'isDraftGame': isDraftGame,
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      players: List<String>.from(json['players'] as List),
      scores: (json['scores'] as List).map((e) => List<int>.from(e as List)).toList(),
      roundWinners: List<String>.from(json['roundWinners'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      isDraftGame: json['isDraftGame'] as bool? ?? false,
    );
  }
} 