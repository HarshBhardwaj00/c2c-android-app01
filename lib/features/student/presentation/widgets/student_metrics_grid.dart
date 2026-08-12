import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/student_dashboard_model.dart';

class StudentMetricsGrid extends StatelessWidget {
  final StudentStatsData stats;

  const StudentMetricsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;

    // Calculate aspect ratio dynamically based on screen width to guarantee zero bottom overflow
    final aspectRatio = screenWidth > 600
        ? 1.5
        : (isCompact ? 1.15 : 1.25);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: aspectRatio,
      children: [
        _buildMetricCard(
          title: 'REGISTERED COURSES',
          value: stats.registeredCourses.toString(),
          icon: LucideIcons.bookOpen,
          trendText: '^ 0',
          trendIsPositive: true,
        ),
        _buildMetricCard(
          title: 'COMPLETED',
          value: stats.completed.toString(),
          icon: LucideIcons.checkCircle2,
          trendText: '^ 0',
          trendIsPositive: true,
        ),
        _buildMetricCard(
          title: 'PENDING',
          value: stats.pending.toString(),
          icon: LucideIcons.clock,
          trendText: 'v 0',
          trendIsPositive: false,
        ),
        _buildMetricCard(
          title: 'CERTIFICATES',
          value: stats.certificates.toString(),
          icon: LucideIcons.award,
          trendText: '^ 0',
          trendIsPositive: true,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required String trendText,
    required bool trendIsPositive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Icon & Trend Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColors.inputFill,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: trendIsPositive
                      ? AppColors.successLight
                      : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trendText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: trendIsPositive
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Metric Label Block - Wrapped in FittedBox to guarantee zero overflow
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              title,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
