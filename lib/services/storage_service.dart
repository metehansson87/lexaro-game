// lib/services/storage_service.dart
// Handles all local persistence via SharedPreferences
// Replace with Firebase/backend calls later for cloud sync

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_model.dart';

class StorageService {
  static const _playerKey = 'player_data';
  static const _solvedKey = 'solved_puzzles';
  static const _soundKey  = 'sound_enabled';

  // ─── Player ─────────────────────────────────────────────────────────────────

  Future<PlayerModel> loadPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_playerKey);
    if (json == null) {
      final newPlayer = PlayerModel.newPlayer();
      await savePlayer(newPlayer);
      return newPlayer;
    }
    return PlayerModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> savePlayer(PlayerModel player) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerKey, jsonEncode(player.toJson()));
  }

  // ─── Solved puzzles ──────────────────────────────────────────────────────────

  Future<Set<String>> loadSolvedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_solvedKey) ?? [];
    return list.toSet();
  }

  Future<void> markSolved(String puzzleId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_solvedKey) ?? [];
    if (!current.contains(puzzleId)) {
      current.add(puzzleId);
      await prefs.setStringList(_solvedKey, current);
    }
  }

  // ─── Sound setting ───────────────────────────────────────────────────────────

  Future<bool> loadSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
  }

  Future<void> saveSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }
}
