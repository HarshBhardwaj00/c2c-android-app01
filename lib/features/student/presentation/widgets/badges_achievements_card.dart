import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/student_dashboard_model.dart';

class BadgesAchievementsCard extends StatelessWidget {
  final List<StudentBadgeData> badges;

  const BadgesAchievementsCard({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    final earnedCount = badges.where((b) => b.earned).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                LucideIcons.award,
                size: 22,
                color: AppColors.warning,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AutoSizeText(
                      'Badges & Achievements',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Unlock badges as you progress through your learning journey.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Earned Pill Top-Right
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$earnedCount / ${badges.length}\nEarned',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Horizontal Badge Scroll List - Wrapped in bounded SizedBox with FittedBox item Protection
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: badges.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final badge = badges[index];
                return _buildBadgeItem(badge);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(StudentBadgeData badge) {
    Color bgCircleColor = AppColors.primary;
    try {
      bgCircleColor = Color(int.parse(badge.colorHex));
    } catch (_) {}

    return Container(
      width: 108,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: badge.earned
            ? AppColors.inputFill.withValues(alpha: 0.5)
            : AppColors.inputFill.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badge.earned
              ? AppColors.border
              : AppColors.border.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji Icon Circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: badge.earned ? bgCircleColor : AppColors.textMuted,
                shape: BoxShape.circle,
                boxShadow: badge.earned
                    ? [
                        BoxShadow(
                          color: bgCircleColor.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                badge.icon,
                style: TextStyle(
                  fontSize: 18,
                  color: badge.earned ? Colors.white : Colors.white60,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Badge Title
            SizedBox(
              width: 90,
              child: AutoSizeText(
                badge.title,
                maxLines: 1,
                minFontSize: 9,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: badge.earned
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Unlocked / Locked Status Text
            Text(
              badge.earned ? 'Unlocked' : 'Locked',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: badge.earned ? AppColors.success : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
