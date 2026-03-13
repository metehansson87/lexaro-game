import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence layer using SharedPreferences.
/// Provides typed read/write access for all locally cached game data.
class StorageService {
  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance != null) return _instance!;
    final instance = StorageService._();
    instance._prefs = await SharedPreferences.getInstance();
    _instance = instance;
    return _instance!;
  }

  // ── Keys ──────────────────────────────────────────────────────────────────
  static const String _keyPlayerData = 'player_data';
  static const String _keySolvedIds = 'solved_puzzles';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyMusicEnabled = 'music_enabled';
  static const String _keyLanguage = 'selected_language';
  static const String _keyDailyPuzzleDate = 'daily_puzzle_date';
  static const String _keyDailyPuzzleCompleted = 'daily_puzzle_completed';
  static const String _keyAchievements = 'achievements';

  static const String _keySessionCount = 'session_count';
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';

  // ── Generic ───────────────────────────────────────────────────────────────
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  int? getInt(String key) => _prefs.getInt(key);

  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<void> setJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  Map<String, dynamic>? getJson(String key) {
    final str = _prefs.getString(key);
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  Future<bool> remove(String key) => _prefs.remove(key);

  // ── Player ────────────────────────────────────────────────────────────────
  Future<void> savePlayerData(Map<String, dynamic> data) =>
      setJson(_keyPlayerData, data);

  Map<String, dynamic>? loadPlayerData() => getJson(_keyPlayerData);

  // ── Solved Puzzles ────────────────────────────────────────────────────────
  Future<void> saveSolvedIds(Set<String> ids) =>
      setStringList(_keySolvedIds, ids.toList());

  Set<String> loadSolvedIds() =>
      (getStringList(_keySolvedIds) ?? []).toSet();

  Future<void> markPuzzleSolved(String puzzleId) async {
    final ids = loadSolvedIds();
    ids.add(puzzleId);
    await saveSolvedIds(ids);
  }

  // ── Sound ─────────────────────────────────────────────────────────────────
  Future<void> setSoundEnabled(bool enabled) =>
      setBool(_keySoundEnabled, enabled);

  bool isSoundEnabled() => getBool(_keySoundEnabled) ?? true;

  Future<void> setMusicEnabled(bool enabled) =>
      setBool(_keyMusicEnabled, enabled);

  bool isMusicEnabled() => getBool(_keyMusicEnabled) ?? true;

  // ── Language ──────────────────────────────────────────────────────────────
  Future<void> setLanguage(String lang) => setString(_keyLanguage, lang);

  String getLanguage() => getString(_keyLanguage) ?? 'en';

  // ── Daily Puzzle ──────────────────────────────────────────────────────────
  Future<void> setDailyPuzzleCompleted(String dateKey) async {
    await setString(_keyDailyPuzzleDate, dateKey);
    await setBool(_keyDailyPuzzleCompleted, true);
  }

  bool isDailyPuzzleCompleted(String dateKey) {
    final storedDate = getString(_keyDailyPuzzleDate);
    if (storedDate != dateKey) return false;
    return getBool(_keyDailyPuzzleCompleted) ?? false;
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  Future<void> saveAuthToken(String token) => setString(_keyAuthToken, token);

  String? getAuthToken() => getString(_keyAuthToken);

  Future<void> saveUserId(String id) => setString(_keyUserId, id);

  String? getUserId() => getString(_keyUserId);

  Future<void> clearAuth() async {
    await remove(_keyAuthToken);
    await remove(_keyUserId);
  }

  // ── Session ───────────────────────────────────────────────────────────────
  Future<void> incrementSessionCount() async {
    final count = getInt(_keySessionCount) ?? 0;
    await setInt(_keySessionCount, count + 1);
  }

  int getSessionCount() => getInt(_keySessionCount) ?? 0;

  bool isFirstLaunch() => getBool(_keyFirstLaunch) ?? true;

  Future<void> setFirstLaunchDone() => setBool(_keyFirstLaunch, false);

  // ── Achievements ──────────────────────────────────────────────────────────
  Future<void> saveAchievements(List<String> achievementIds) =>
      setStringList(_keyAchievements, achievementIds);

  List<String> loadAchievements() =>
      getStringList(_keyAchievements) ?? [];

  // ── Clear All ─────────────────────────────────────────────────────────────
  Future<bool> clearAll() => _prefs.clear();
}
