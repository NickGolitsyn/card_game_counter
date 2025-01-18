import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game.dart';

class StorageService {
  static const String _gamesKey = 'games';
  static const String _playersKey = 'players';
  static const String _draftGamesKey = 'draft_games';

  Future<void> saveGame(Game game) async {
    final prefs = await SharedPreferences.getInstance();
    final games = await getGames();
    
    final gameIndex = games.indexWhere((g) => g.id == game.id);
    if (gameIndex >= 0) {
      games[gameIndex] = game;
    } else {
      games.add(game);
    }

    await prefs.setString(_gamesKey, jsonEncode(
      games.map((g) => g.toJson()).toList(),
    ));
  }

  Future<void> saveDraft(Game game) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();
    
    final draftIndex = drafts.indexWhere((g) => g.id == game.id);
    if (draftIndex >= 0) {
      drafts[draftIndex] = game;
    } else {
      drafts.add(game);
    }

    await prefs.setString(_draftGamesKey, jsonEncode(
      drafts.map((g) => g.toJson()).toList(),
    ));
  }

  Future<List<Game>> getGames() async {
    final prefs = await SharedPreferences.getInstance();
    final gamesJson = prefs.getString(_gamesKey);
    if (gamesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(gamesJson);
    return decoded.map((json) => Game.fromJson(json)).toList();
  }

  Future<List<Game>> getDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = prefs.getString(_draftGamesKey);
    if (draftsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(draftsJson);
    return decoded.map((json) => Game.fromJson(json)).toList();
  }

  Future<void> deleteGame(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final games = await getGames();
    games.removeWhere((g) => g.id == gameId);
    
    await prefs.setString(_gamesKey, jsonEncode(
      games.map((g) => g.toJson()).toList(),
    ));
  }

  Future<void> deleteDraft(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();
    drafts.removeWhere((g) => g.id == gameId);
    
    await prefs.setString(_draftGamesKey, jsonEncode(
      drafts.map((g) => g.toJson()).toList(),
    ));
  }

  Future<void> saveDraftGame(Game game) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDraftGames();
    drafts[game.id] = game.toJson();
    await prefs.setString(_draftGamesKey, jsonEncode(drafts));
  }

  Future<Map<String, dynamic>> getDraftGames() async {
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = prefs.getString(_draftGamesKey);
    return draftsJson != null ? Map<String, dynamic>.from(jsonDecode(draftsJson)) : {};
  }

  Future<void> deleteDraftGame(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDraftGames();
    drafts.remove(gameId);
    await prefs.setString(_draftGamesKey, jsonEncode(drafts));
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
} 