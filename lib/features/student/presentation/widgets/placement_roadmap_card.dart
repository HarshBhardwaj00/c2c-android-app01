import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/constants/app_colors.dart';

class PlacementRoadmapCard extends StatelessWidget {
  const PlacementRoadmapCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;
    final aspectRatio = screenWidth > 600
        ? 1.4
        : (isCompact ? 1.05 : 1.15);

    final steps = [
      {
        'num': '01',
        'icon': LucideIcons.user,
        'title': 'Profile Building',
        'sub': 'Secure, verified credentials.',
      },
      {
        'num': '02',
        'icon': LucideIcons.target,
        'title': 'Skill Assessment',
        'sub': 'AI proctored baseline tests.',
      },
      {
        'num': '03',
        'icon': LucideIcons.bookOpen,
        'title': 'Learning Roadmap',
        'sub': 'Curated targeted content.',
      },
      {
        'num': '04',
        'icon': LucideIcons.users,
        'title': 'Mentorship',
        'sub': 'Mock trials & expert reviews.',
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CAREER PATH',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryLight.withValues(alpha: 0.9),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const AutoSizeText(
                      'Roadmap to placement',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.target,
                size: 22,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2x2 Grid of Step Cards
          GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: aspectRatio,
            children: steps.map((step) {
              final iconData = step['icon'] as IconData;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          iconData,
                          size: 16,
                          color: AppColors.primaryLight,
                        ),
                        Text(
                          step['num'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AutoSizeText(
                      step['title'] as String,
                      maxLines: 1,
                      minFontSize: 11,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        step['sub'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.25,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
