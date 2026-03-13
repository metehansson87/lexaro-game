import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';


/// Settings screen with language, audio, account, and about options.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'en';
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _notificationsEnabled = true;

  static const _languages = {
    'en': 'English',
    'tr': 'Turkish',
    'de': 'German',
    'it': 'Italian',
    'fr': 'French',
    'es': 'Spanish',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(context, 'Puzzle Language'),
          const SizedBox(height: 8),
          _buildLanguageSelector(context),
          const SizedBox(height: 24),

          _sectionTitle(context, 'Audio'),
          const SizedBox(height: 8),
          _buildToggle(
            context,
            icon: Icons.volume_up_rounded,
            title: 'Sound Effects',
            value: _soundEnabled,
            onChanged: (v) => setState(() => _soundEnabled = v),
          ),
          const SizedBox(height: 8),
          _buildToggle(
            context,
            icon: Icons.music_note_rounded,
            title: 'Music',
            value: _musicEnabled,
            onChanged: (v) => setState(() => _musicEnabled = v),
          ),
          const SizedBox(height: 24),

          _sectionTitle(context, 'Notifications'),
          const SizedBox(height: 8),
          _buildToggle(
            context,
            icon: Icons.notifications_rounded,
            title: 'Push Notifications',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          const SizedBox(height: 24),

          _sectionTitle(context, 'Account'),
          const SizedBox(height: 8),
          _buildAction(
            context,
            icon: Icons.person_rounded,
            title: 'Edit Profile',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _buildAction(
            context,
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            color: AppColors.error,
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/auth', (_) => false);
            },
          ),
          const SizedBox(height: 24),

          _sectionTitle(context, 'About'),
          const SizedBox(height: 8),
          _buildInfo(context, 'Version', '2.0.0'),
          const SizedBox(height: 8),
          _buildAction(
            context,
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _buildAction(
            context,
            icon: Icons.description_rounded,
            title: 'Terms of Service',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1.5,
          ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _languages.entries.map((entry) {
        final selected = entry.key == _selectedLanguage;
        return ChoiceChip(
          label: Text(entry.value),
          selected: selected,
          selectedColor: AppColors.primary.withAlpha(51),
          side: BorderSide(
            color:
                selected ? AppColors.primary : Colors.white.withAlpha(26),
          ),
          labelStyle: TextStyle(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
          onSelected: (_) => setState(() => _selectedLanguage = entry.key),
        );
      }).toList(),
    );
  }

  Widget _buildToggle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: AppDecorations.card(),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryLight, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    final c = color ?? AppColors.primaryLight;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.card(),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    color: color ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: c.withAlpha(102), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card(),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
                color: AppColors.textMuted, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
