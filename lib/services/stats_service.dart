import '../models/game.dart';
import '../models/player.dart';
import 'storage_service.dart';

class PlayerStats {
  final String playerName;
  final int totalPoints;
  final double averagePoints;
  final int gamesPlayed;
  final int gamesWon;
  final int highestScore;

  PlayerStats({
    required this.playerName,
    required this.totalPoints,
    required this.averagePoints,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.highestScore,
  });
}

class GameSummary {
  final String id;
  final String title;
  final String type;
  final String winner;
  final int winningScore;
  final DateTime playedAt;
  final int playerCount;

  GameSummary({
    required this.id,
    required this.title,
    required this.type,
    required this.winner,
    required this.winningScore,
    required this.playedAt,
    required this.playerCount,
  });
}

class StatsService {
  final StorageService _storageService = StorageService();

  Future<List<PlayerStats>> getPlayerStats(String gameType) async {
    final games = await _storageService.getGames();
    final Map<String, List<int>> playerScores = {};
    final Map<String, int> gamesWon = {};
    final Map<String, int> highestScores = {};
    
    // Collect all scores for each player
    for (final game in games) {
      // Skip draft games, games with no scores, and games of different type
      if (game.isDraftGame || game.scores.isEmpty || game.type != gameType) continue;

      // Find winner by highest total score
      int maxScore = -1;
      String? winner;
      
      for (var i = 0; i < game.players.length; i++) {
        final player = game.players[i];
        final playerTotalScore = game.scores.fold<int>(
          0,
          (sum, round) => sum + round[i],
        );

        if (playerTotalScore > maxScore) {
          maxScore = playerTotalScore;
          winner = player;
        }

        playerScores.putIfAbsent(player, () => []);
        playerScores[player]!.add(playerTotalScore);

        // Track highest individual score
        highestScores[player] = (highestScores[player] ?? 0) > playerTotalScore
            ? highestScores[player]!
            : playerTotalScore;
      }

      if (winner != null) {
        gamesWon[winner] = (gamesWon[winner] ?? 0) + 1;
      }
    }

    // Calculate stats for each player
    return playerScores.entries.map((entry) {
      final scores = entry.value;
      final totalPoints = scores.reduce((a, b) => a + b);
      final averagePoints = scores.isEmpty ? 0.0 : totalPoints / scores.length;

      return PlayerStats(
        playerName: entry.key,
        totalPoints: totalPoints,
        averagePoints: averagePoints,
        gamesPlayed: scores.length,
        gamesWon: gamesWon[entry.key] ?? 0,
        highestScore: highestScores[entry.key] ?? 0,
      );
    }).toList()
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
  }

  Future<List<GameSummary>> getGameSummaries(String gameType) async {
    final games = await _storageService.getGames();
    
    return games
        .where((game) => !game.isDraftGame && game.scores.isNotEmpty && game.type == gameType)
        .map((game) {
      // Find winner and winning score
      int maxScore = -1;
      String winner = '';
      
      for (var i = 0; i < game.players.length; i++) {
        final totalScore = game.scores.fold<int>(
          0,
          (sum, round) => sum + round[i],
        );
        
        if (totalScore > maxScore) {
          maxScore = totalScore;
          winner = game.players[i];
        }
      }

      return GameSummary(
        id: game.id,
        title: game.title,
        type: game.type,
        winner: winner,
        winningScore: maxScore,
        playedAt: game.createdAt,
        playerCount: game.players.length,
      );
    }).toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
  }
} 