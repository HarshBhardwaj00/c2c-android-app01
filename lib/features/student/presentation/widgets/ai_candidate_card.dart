import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

class AiCandidateCard extends StatelessWidget {
  final String name;
  final String statusText;
  final int matchScore;
  final String avatarUrl;
  final List<String> skills;

  const AiCandidateCard({
    super.key,
    this.name = 'Priya Sharma',
    this.statusText = 'Ready for Google, Stripe, Meta',
    this.matchScore = 98,
    this.avatarUrl = 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
    this.skills = const ['Python Expert', '300+ LeetCode', '4 Internships'],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFAF5FF),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: AI Candidate Badge + Beta Pill
            Row(
              children: [
                const Icon(LucideIcons.sparkles, color: AppColors.accentViolet, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: AutoSizeText(
                    'AI CANDIDATE HIGHLIGHT',
                    maxLines: 1,
                    minFontSize: 9,
                    maxFontSize: 12,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.accentViolet,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.aiBadgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const AutoSizeText(
                    'BETA',
                    maxLines: 1,
                    minFontSize: 8,
                    style: TextStyle(
                      color: AppColors.accentViolet,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Profile & Match Score Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar with Verified Badge using AspectRatio
                Stack(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: NetworkImage(avatarUrl),
                          onBackgroundImageError: (error, stackTrace) {},
                          child: const Icon(LucideIcons.user, size: 20, color: AppColors.primary),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.checkCircle,
                          color: AppColors.accentViolet,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Candidate Name & Target Companies
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        name,
                        maxLines: 1,
                        minFontSize: 14,
                        maxFontSize: 18,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      AutoSizeText(
                        statusText,
                        maxLines: 2,
                        minFontSize: 10,
                        maxFontSize: 12,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Match Score Badge
                FittedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AutoSizeText(
                        '$matchScore%',
                        maxLines: 1,
                        minFontSize: 16,
                        maxFontSize: 24,
                        style: const TextStyle(
                          color: AppColors.accentViolet,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      const Text(
                        'MATCH',
                        style: TextStyle(
                          color: AppColors.accentViolet,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Skill Chips Wrap
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AutoSizeText(
                    skill,
                    maxLines: 1,
                    minFontSize: 9,
                    maxFontSize: 11,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
