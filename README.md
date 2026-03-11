# GameGuess 🎮

A Flutter word puzzle game where players guess video game titles by filling letter boxes.

---

## Quick Start (VS Code)

### Prerequisites
- Flutter SDK ≥ 3.0 installed and in PATH
- Android SDK / Android Studio (for emulator or device)
- VS Code with the **Flutter** and **Dart** extensions

### Run
```bash
cd gameguess
flutter pub get
flutter run
```

---

## Project Structure

```
lib/
├── main.dart                   # Entry point, Provider setup
├── models/
│   ├── puzzle_model.dart       # Puzzle & Difficulty enums
│   └── player_model.dart       # Player, LeaderboardEntry
├── services/
│   ├── puzzle_data.dart        # All puzzle content (easy/medium/hard)
│   ├── storage_service.dart    # SharedPreferences persistence
│   ├── audio_service.dart      # SFX + background music
│   ├── ad_service.dart         # Rewarded ad placeholder
│   ├── leaderboard_service.dart# Mock + backend-ready leaderboard
│   └── game_provider.dart      # 🧠 Core game state (ChangeNotifier)
├── theme/
│   └── app_theme.dart          # Colors, typography, decorations
├── widgets/
│   ├── answer_boxes.dart       # Tappable letter boxes
│   ├── game_keyboard.dart      # Dynamic on-screen keyboard
│   ├── game_hud.dart           # Timer, score, gold, difficulty
│   └── success_overlay.dart    # Win/lose overlays + confetti
└── screens/
    ├── home_screen.dart        # Main menu, difficulty select
    ├── game_screen.dart        # Core gameplay
    ├── leaderboard_screen.dart # Global leaderboard
    └── store_screen.dart       # Gold shop + ad reward
```

---

## Adding Audio Assets

Place these files in `assets/audio/`:
- `bg_music.mp3`  — Looping background music (royalty-free)
- `keypress.mp3`  — Soft key tap sound
- `success.mp3`   — Win fanfare
- `error.mp3`     — Timer-end sound

**Free sources:** freesound.org, pixabay.com/music, zapsplat.com

---

## Adding New Puzzles

Edit `lib/services/puzzle_data.dart` — add entries to `easyPuzzles`, `mediumPuzzles`, or `hardPuzzles`.

```dart
PuzzleModel(
  id: 'e013',
  answer: 'SUPER MARIO',
  category: 'Platformer',
  difficulty: Difficulty.easy,
),
```

---

## Connecting a Real Backend

| Feature | File | TODO |
|---|---|---|
| Leaderboard | `leaderboard_service.dart` | Replace `fetchGlobal()` with HTTP GET |
| Score submit | `leaderboard_service.dart` | Replace `submitScore()` with HTTP POST |
| Rewarded ads | `ad_service.dart` | Add `google_mobile_ads` SDK |
| IAP | `game_provider.dart` | Add `in_app_purchase` SDK |
| Cloud save | `storage_service.dart` | Add Firebase Firestore calls |

---

## Monetization Prices (Placeholder)

| Package | Gold | Price |
|---|---|---|
| Starter | 100 | 20 TL |
| Popular | 200 | 35 TL |
| Mega | 1000 | 100 TL |

Update prices in `store_screen.dart` → `_packages` list.

---

## Difficulty System

| Level | Points | Timer |
|---|---|---|
| Easy | 5 | 45s |
| Medium | 10 | 45s |
| Hard | 20 | 45s |

---

## League System

| League | Score threshold |
|---|---|
| Bronze | 0+ |
| Silver | 500+ |
| Gold | 2000+ |
| Diamond | 5000+ |

---

## Export to Android Studio

1. Open Android Studio → **Open** → select the `gameguess/android` folder
2. Or use VS Code directly to build the APK:
   ```bash
   flutter build apk --release
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`
