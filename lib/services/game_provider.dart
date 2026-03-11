// lib/services/game_provider.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/puzzle_model.dart';
import '../models/player_model.dart';
import 'puzzle_data.dart';
import 'storage_service.dart';
import 'audio_service.dart';
import 'ad_service.dart';

enum RoundState { idle, playing, won, lost }

class GameProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final AudioService   audio    = AudioService();
  final AdService      _ads     = AdService();

  // ─── Player ───────────────────────────────────────────────────────────────
  PlayerModel _player = PlayerModel.newPlayer();
  PlayerModel get player => _player;
  Set<String> _solvedIds = {};

  // ─── Round ────────────────────────────────────────────────────────────────
  PuzzleModel? _puzzle;
  PuzzleModel? get puzzle => _puzzle;

  Difficulty _selectedDifficulty = Difficulty.medium;
  Difficulty get selectedDifficulty => _selectedDifficulty;

  RoundState _roundState = RoundState.idle;
  RoundState get roundState => _roundState;

  // Answer boxes
  List<String> _boxes = [];
  List<String> get boxes => _boxes;

  // Hinted box indices — these cannot be deleted
  final Set<int> _hintedBoxes = {};
  Set<int> get hintedBoxes => _hintedBoxes;

  int _selectedBox = -1;
  int get selectedBox => _selectedBox;

  Map<String, int> _availableLetters = {};
  Map<String, int> get availableLetters => _availableLetters;

  List<String> _keyboardLetters = [];
  List<String> get keyboardLetters => _keyboardLetters;

  int _shuffleCount = 0;
  int get shuffleCount => _shuffleCount;

  // Interstitial counter — show ad every 3 puzzles solved
  int _puzzlesSinceLastAd = 0;

  // Timer
  static const int roundDuration = 45;
  int _timeLeft = roundDuration;
  int get timeLeft => _timeLeft;
  Timer? _timer;

  // ─── Init ─────────────────────────────────────────────────────────────────
  Future<void> init() async {
    _player   = await _storage.loadPlayer();
    _solvedIds = await _storage.loadSolvedIds();
    final soundOn = await _storage.loadSoundEnabled();
    audio.setSoundEnabled(soundOn);
    if (soundOn) await audio.startBackgroundMusic();
    _ads.loadRewardedAd();
    _ads.loadInterstitialAd();
    notifyListeners();
  }

  // ─── Difficulty ───────────────────────────────────────────────────────────
  void setDifficulty(Difficulty d) {
    _selectedDifficulty = d;
    notifyListeners();
  }

  // ─── Start round ──────────────────────────────────────────────────────────
  void startRound([Difficulty? difficulty]) {
    final diff = difficulty ?? _selectedDifficulty;
    _selectedDifficulty = diff;

    final next = PuzzleData.getNext(diff, _solvedIds);
    if (next == null) {
      _solvedIds.removeWhere(
        (id) => PuzzleData.forDifficulty(diff).any((p) => p.id == id),
      );
      startRound(diff);
      return;
    }

    _puzzle = next;
    _roundState = RoundState.playing;
    _timeLeft = roundDuration;
    _hintedBoxes.clear();

    // Build answer boxes
    _boxes = [];
    for (final word in next.words) {
      for (final _ in word.split('')) {
        _boxes.add('');
      }
      _boxes.add(' ');
    }
    if (_boxes.isNotEmpty && _boxes.last == ' ') _boxes.removeLast();

    _selectedBox = _boxes.indexOf('');
    _availableLetters = Map.from(next.letterCounts);
    _buildKeyboardLetters();
    _startTimer();
    notifyListeners();
  }

  // ─── Keyboard ─────────────────────────────────────────────────────────────
  void _buildKeyboardLetters() {
    _keyboardLetters = [];
    _availableLetters.forEach((letter, count) {
      for (int i = 0; i < count; i++) {
        _keyboardLetters.add(letter);
      }
    });
    _shuffleLetters();
  }

  void _shuffleLetters() => _keyboardLetters.shuffle(Random());

  void shuffleKeyboard() {
    _shuffleLetters();
    _shuffleCount++;
    notifyListeners();
  }

  bool isLetterAvailable(String letter) =>
      (_availableLetters[letter] ?? 0) > 0;

  // ─── Box selection ────────────────────────────────────────────────────────
  void selectBox(int index) {
    if (_roundState != RoundState.playing) return;
    if (_boxes[index] == ' ') return;
    _selectedBox = index;
    notifyListeners();
  }

  // ─── Enter letter ─────────────────────────────────────────────────────────
  void enterLetter(String letter) {
    if (_roundState != RoundState.playing) return;
    if (!isLetterAvailable(letter)) return;

    // If selected box is filled or invalid, find next empty
    if (_selectedBox < 0 ||
        (_boxes[_selectedBox] != '' && _boxes[_selectedBox] != ' ')) {
      int empty = -1;
      for (int i = 0; i < _boxes.length; i++) {
        if (_boxes[i] == '') { empty = i; break; }
      }
      if (empty < 0) return;
      _selectedBox = empty;
    }

    audio.playKeypress();
    _boxes[_selectedBox] = letter;
    _availableLetters[letter] = (_availableLetters[letter] ?? 1) - 1;
    if (_availableLetters[letter] == 0) _availableLetters.remove(letter);
    _keyboardLetters.remove(letter);
    _advanceSelection();
    notifyListeners();
    _checkWin();
  }

  void _advanceSelection() {
    int next = _selectedBox + 1;
    while (next < _boxes.length) {
      if (_boxes[next] == '') { _selectedBox = next; return; }
      next++;
    }
    for (int i = 0; i < _boxes.length; i++) {
      if (_boxes[i] == '') { _selectedBox = i; return; }
    }
    _selectedBox = -1;
  }

  // ─── Delete letter ────────────────────────────────────────────────────────
  void deleteLetter() {
    if (_roundState != RoundState.playing) return;

    int target = _selectedBox;

    // If selected box has a non-hinted letter, delete it
    if (target >= 0 &&
        _boxes[target] != '' &&
        _boxes[target] != ' ' &&
        !_hintedBoxes.contains(target)) {
      // target is valid
    } else {
      // Scan backwards for the last filled, non-hinted box
      target = _boxes.length - 1;
      while (target >= 0) {
        if (_boxes[target] != '' &&
            _boxes[target] != ' ' &&
            !_hintedBoxes.contains(target)) {
          break;
        }
        target--;
      }
    }

    if (target < 0 || _boxes[target] == ' ' || _boxes[target] == '') return;
    if (_hintedBoxes.contains(target)) return; // Safety guard

    final removed = _boxes[target];
    _boxes[target] = '';
    _selectedBox = target;

    _availableLetters[removed] = (_availableLetters[removed] ?? 0) + 1;
    _keyboardLetters.add(removed);

    notifyListeners();
  }

  // ─── Win check ────────────────────────────────────────────────────────────
  void _checkWin() {
    if (_puzzle == null) return;
    final answer = _boxes.where((b) => b != ' ').join();
    final correct = _puzzle!.answer.toUpperCase().replaceAll(' ', '');
    if (answer == correct) _onWin();
  }

  void _onWin() {
    _timer?.cancel();
    _roundState = RoundState.won;
    audio.playSuccess();

    final earned = _puzzle!.points;
    _player = _player.copyWith(
      totalScore: _player.totalScore + earned,
      puzzlesSolved: _player.puzzlesSolved + 1,
    );
    _solvedIds.add(_puzzle!.id);
    _storage.markSolved(_puzzle!.id);
    _storage.savePlayer(_player);

    // Show interstitial every 3 solved puzzles
    _puzzlesSinceLastAd++;
    if (_puzzlesSinceLastAd >= 3) {
      _puzzlesSinceLastAd = 0;
      _ads.showInterstitialAd();
    }

    notifyListeners();
  }

  void _onLose() {
    _roundState = RoundState.lost;
    _storage.savePlayer(_player);
    notifyListeners();
  }

  // ─── Timer ────────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _onLose();
      }
    });
  }

  void pauseTimer() => _timer?.cancel();
  void resumeTimer() {
    if (_roundState == RoundState.playing) _startTimer();
  }

  // ─── Hint ─────────────────────────────────────────────────────────────────
  static const int hintCost = 1;

  bool get canUseHint => _player.gold >= hintCost && _boxes.any((b) => b == '');

  void useHint() {
    if (!canUseHint) return;
    if (_puzzle == null) return;

    final correctLetters = _puzzle!.answer.toUpperCase().replaceAll(' ', '');

    // Build list of empty box indices with their correct letter
    final emptySlots = <MapEntry<int, String>>[];
    int letterIdx = 0;
    for (int i = 0; i < _boxes.length; i++) {
      if (_boxes[i] == ' ') continue;
      if (_boxes[i] == '' && letterIdx < correctLetters.length) {
        emptySlots.add(MapEntry(i, correctLetters[letterIdx]));
      }
      letterIdx++;
    }

    if (emptySlots.isEmpty) return;

    emptySlots.shuffle(Random());
    final slot = emptySlots.first;
    final targetBox = slot.key;
    final revealLetter = slot.value;

    // Place letter and mark as hinted (permanent)
    _boxes[targetBox] = revealLetter;
    _hintedBoxes.add(targetBox);

    // Consume from available pool
    if ((_availableLetters[revealLetter] ?? 0) > 0) {
      _availableLetters[revealLetter] = _availableLetters[revealLetter]! - 1;
      if (_availableLetters[revealLetter] == 0) {
        _availableLetters.remove(revealLetter);
      }
      _keyboardLetters.remove(revealLetter);
    }

    // Deduct gold
    _player = _player.copyWith(gold: _player.gold - hintCost);
    _storage.savePlayer(_player);

    _advanceSelection();
    notifyListeners();
    _checkWin();
  }

  // ─── Daily reward ─────────────────────────────────────────────────────────
  static const int dailyGold = 10;

  bool get canClaimDaily => _player.canClaimDailyReward;

  Future<void> claimDailyReward() async {
    if (!canClaimDaily) return;
    _player = _player.copyWith(
      gold: _player.gold + dailyGold,
      lastDailyReward: DateTime.now(),
    );
    await _storage.savePlayer(_player);
    notifyListeners();
  }

  // ─── Rewarded ad ──────────────────────────────────────────────────────────
  static const int adGoldReward = 2;

  Future<bool> watchAdForGold() async {
    final earned = await _ads.showRewardedAd();
    if (earned) {
      _player = _player.copyWith(gold: _player.gold + adGoldReward);
      await _storage.savePlayer(_player);
      notifyListeners();
    }
    return earned;
  }

  // ─── IAP placeholder ──────────────────────────────────────────────────────
  Future<void> purchaseGold(int goldAmount, String productId) async {
    _player = _player.copyWith(gold: _player.gold + goldAmount);
    await _storage.savePlayer(_player);
    notifyListeners();
  }

  // ─── Sound ────────────────────────────────────────────────────────────────
  Future<void> toggleSound() async {
    final newState = !audio.soundEnabled;
    audio.setSoundEnabled(newState);
    if (newState) await audio.startBackgroundMusic();
    await _storage.saveSoundEnabled(newState);
    notifyListeners();
  }

  // ─── Dispose ──────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _timer?.cancel();
    audio.dispose();
    super.dispose();
  }
}
