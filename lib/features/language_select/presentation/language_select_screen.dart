import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/routing/app_router.dart';

/// Language selection screen shown after splash.
/// User picks one of 6 languages before proceeding to the game.
class LanguageSelectScreen extends StatelessWidget {
  const LanguageSelectScreen({super.key});

  static const List<_LanguageOption> _languages = [
    _LanguageOption('en', 'English', '🇬🇧'),
    _LanguageOption('tr', 'Turkce', '🇹🇷'),
    _LanguageOption('de', 'Deutsch', '🇩🇪'),
    _LanguageOption('it', 'Italiano', '🇮🇹'),
    _LanguageOption('fr', 'Francais', '🇫🇷'),
    _LanguageOption('es', 'Espanol', '🇪🇸'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppDecorations.neonButton(
                    color: AppColors.primary,
                    radius: 24,
                  ),
                  child: const Icon(
                    Icons.extension,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'LEXARO',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        letterSpacing: 4,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Game Puzzle Battle',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 40),
                Text(
                  'SELECT LANGUAGE',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),
                // Language grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRouter.auth,
                          arguments: lang.code,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: AppDecorations.cardElevated(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              lang.flag,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              lang.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption {
  final String code;
  final String name;
  final String flag;

  const _LanguageOption(this.code, this.name, this.flag);
}
