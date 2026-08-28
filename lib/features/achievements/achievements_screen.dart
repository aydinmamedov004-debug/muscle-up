import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../models/achievement.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/section_header.dart';
import 'providers/achievement_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statuses = ref.watch(achievementStatusesProvider);

    final unlocked = statuses.where((s) => s.isUnlocked).toList();
    final locked = statuses.where((s) => !s.isUnlocked).toList()
      // Closest-to-completion first, so the next achievable goal leads.
      ..sort((a, b) => b.progress.compareTo(a.progress));

    return Scaffold(
      appBar: AppBar(title: const Text("Achievements")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: AppTheme.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      "${unlocked.length} / ${statuses.length} unlocked",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            if (unlocked.isNotEmpty) ...[
              SectionHeader(title: "Unlocked (${unlocked.length})"),
              ...unlocked.map(
                (status) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _AchievementTile(status: status),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            if (locked.isNotEmpty) ...[
              SectionHeader(title: "Locked (${locked.length})"),
              ...locked.map(
                (status) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _AchievementTile(status: status),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.fabClearance),
          ],
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final AchievementStatus status;

  const _AchievementTile({required this.status});

  @override
  Widget build(BuildContext context) {
    final achievement = status.achievement;
    final unlocked = status.isUnlocked;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: unlocked ? AppTheme.accentTint : AppTheme.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: unlocked ? AppTheme.primary : AppTheme.secondaryText,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: unlocked ? AppTheme.text : AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: const TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (unlocked)
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppTheme.success,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Unlocked",
                        style: TextStyle(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                else ...[
                  ClipRRect(
                    borderRadius: AppRadius.small,
                    child: LinearProgressIndicator(
                      value: status.progress,
                      minHeight: 6,
                      backgroundColor: AppTheme.surfaceLight,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${status.currentValue} / ${achievement.threshold}",
                    style: const TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
