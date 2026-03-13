import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../data/models/leaderboard_entry.dart';
import '../../../data/repositories/leaderboard_repository.dart';

/// Global leaderboard screen with league filtering and player rank display.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardRepository _repo = LeaderboardRepository();
  List<LeaderboardEntry> _entries = [];
  String _selectedLeague = 'Global';
  bool _loading = true;

  static const _leagues = ['Global', 'Diamond', 'Gold', 'Silver', 'Bronze'];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _loading = true);
    _entries = await _repo.fetchGlobalLeaderboard(limit: 50);
    setState(() => _loading = false);
  }

  Future<void> _filterByLeague(String league) async {
    setState(() {
      _selectedLeague = league;
      _loading = true;
    });
    if (league == 'Global') {
      _entries = await _repo.fetchGlobalLeaderboard(limit: 50);
    } else {
      _entries = await _repo.fetchLeagueLeaderboard(league: league, limit: 50);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: Column(
        children: [
          // League filter
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _leagues.length,
              itemBuilder: (context, index) {
                final league = _leagues[index];
                final selected = league == _selectedLeague;
                final color = league == 'Global'
                    ? AppColors.primary
                    : AppDecorations.leagueColor(league);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(league),
                    selected: selected,
                    selectedColor: color.withAlpha(51),
                    side: BorderSide(
                      color: selected ? color : Colors.white.withAlpha(26),
                    ),
                    labelStyle: TextStyle(
                      color: selected ? color : AppColors.textSecondary,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (_) => _filterByLeague(league),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? const Center(child: Text('No entries yet'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _entries.length,
                        itemBuilder: (context, index) =>
                            _buildEntry(context, _entries[index], index),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntry(
      BuildContext context, LeaderboardEntry entry, int index) {
    final isTop3 = index < 3;
    final rankColors = [AppColors.accent, Colors.grey[300]!, Colors.orange[300]!];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.card(
        color: isTop3
            ? rankColors[index].withAlpha(13)
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child: isTop3
                ? Icon(
                    Icons.emoji_events_rounded,
                    color: rankColors[index],
                    size: 24,
                  )
                : Text(
                    '${index + 1}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          // Name & league
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.playerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  entry.league,
                  style: TextStyle(
                    color: AppDecorations.leagueColor(entry.league),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.score}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${entry.matchesWon}W',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
