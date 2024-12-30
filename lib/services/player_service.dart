import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';

class PlayerService {
  static const String _playersKey = 'players';

  Future<List<Player>> getPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getString(_playersKey);
    if (playersJson == null) return [];

    final List<dynamic> decoded = jsonDecode(playersJson);
    return decoded.map((json) => Player.fromJson(json)).toList();
  }

  Future<bool> addPlayer(String displayName) async {
    final name = Player.formatName(displayName);
    final players = await getPlayers();
    
    // Check for duplicates
    if (players.any((p) => p.name == name)) {
      return false;
    }

    final player = Player(
      id: const Uuid().v4(),
      name: name,
      displayName: displayName.trim(),
      createdAt: DateTime.now(),
    );

    players.add(player);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playersKey, jsonEncode(
      players.map((p) => p.toJson()).toList(),
    ));

    return true;
  }

  Future<void> removePlayer(String playerId) async {
    final players = await getPlayers();
    players.removeWhere((p) => p.id == playerId);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playersKey, jsonEncode(
      players.map((p) => p.toJson()).toList(),
    ));
  }
} 