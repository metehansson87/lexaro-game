// lib/screens/leaderboard_screen.dart
// Global leaderboard + league standings

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import '../services/leaderboard_service.dart';
import '../models/player_model.dart';
import '../theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _service = LeaderboardService();
  List<LeaderboardEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _service.fetchGlobal();
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = context.read<GameProvider>().player;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Leaderboard',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // My rank card
                _MyRankCard(player: player),

                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _entries.length,
                    itemBuilder: (_, i) => _EntryTile(
                      entry: _entries[i],
                      isMe: _entries[i].playerId == player.id,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MyRankCard extends StatelessWidget {
  final PlayerModel player;
  const _MyRankCard({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.3), AppColors.primaryLight.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                Text('${player.league} League',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${player.totalScore}',
                  style: const TextStyle(
                      color: AppColors.accent, fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('points', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isMe;
  const _EntryTile({required this.entry, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final rankColor = entry.rank == 1
        ? AppColors.accent
        : entry.rank == 2
          ? Colors.grey.shade300
          : entry.rank == 3
            ? Colors.brown.shade300
            : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? AppColors.primary.withOpacity(0.4) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surfaceLight,
            child: Text(
              entry.playerName[0].toUpperCase(),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.playerName,
                    style: TextStyle(
                        color: isMe ? AppColors.primaryLight : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                Text(entry.league,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Text('${entry.score}',
              style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ],
      ),
    );
  }
}
