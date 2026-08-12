import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../bloc/college_bloc.dart';
import '../../domain/models/college_dashboard_model.dart';
import '../widgets/college_drawer.dart';

class CollegeDashboardPage extends StatelessWidget {
  const CollegeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CollegeBloc()..add(LoadCollegeDashboard()),
      child: const _CollegeDashboardContentView(),
    );
  }
}

class _CollegeDashboardContentView extends StatefulWidget {
  const _CollegeDashboardContentView();

  @override
  State<_CollegeDashboardContentView> createState() => _CollegeDashboardContentViewState();
}

class _CollegeDashboardContentViewState extends State<_CollegeDashboardContentView> {
  int _selectedNavIndex = 0;
  final String _selectedMonth = 'Current Month (March)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/dashboard'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<CollegeBloc>().add(RefreshCollegeDashboard());
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Header Bar
                  _buildHeaderBar(context),
                  const SizedBox(height: 16),

                  // 2. Executive Overview Title & Quick Actions
                  _buildTitleSection(context),
                  const SizedBox(height: 20),

                  // 3. Bloc Consumer for Dashboard Content
                  BlocBuilder<CollegeBloc, CollegeState>(
                    builder: (context, state) {
                      if (state is CollegeLoading) {
                        return const SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        );
                      }

                      final data = (state is CollegeLoaded) ? state.data : CollegeDashboardModel.mockData;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 4. KPI Stat Cards (4 Cards)
                          _buildKpiCardsGrid(context, data),
                          const SizedBox(height: 20),

                          // 5. Placement Velocity Card
                          _buildPlacementVelocityCard(context, data),
                          const SizedBox(height: 20),

                          // 6. Monthly Placement Schedule (Calendar)
                          _buildMonthlyScheduleCard(context),
                          const SizedBox(height: 20),

                          // 7. AI Insights Banner Card
                          _buildAiInsightsCard(context),
                          const SizedBox(height: 20),

                          // 8. Upcoming Campus Drives Section
                          _buildUpcomingDrivesSection(context, data.upcomingDrives),
                          const SizedBox(height: 20),

                          // 9. Recent Activities Timeline
                          _buildRecentActivitiesSection(context, data.recentActivities),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
          _handleNavigation(index);
        },
        onFabPressed: () => _showQuickActionBottomSheet(context),
      ),
    );
  }

  // --- 1. Top Header Bar Widget ---
  Widget _buildHeaderBar(BuildContext context) {
    return Row(
      children: [
        // Drawer Menu Button
        Builder(
          builder: (scaffoldContext) {
            return InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Scaffold.of(scaffoldContext).openDrawer();
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(LucideIcons.menu, size: 20, color: AppColors.textPrimary),
              ),
            );
          },
        ),
        const SizedBox(width: 12),

        // C2C Brand Logo Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'C2C',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),

        const Spacer(),

        // Bell Notification Icon with Unread Indicator
        Stack(
          children: [
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.go('/college/operations/communication');
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(LucideIcons.bell, size: 20, color: AppColors.textPrimary),
              ),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),

        // User Avatar Circle
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            context.go('/college/operations/config');
          },
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              'AB',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. Title & Action Buttons Section ---
  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: AutoSizeText(
                'Executive Overview',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Real-time placement intelligence for the 2024 session.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),

        // Action Buttons Row (Export Report & Quick Action)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.go('/college/reports');
                },
                icon: const Icon(LucideIcons.download, size: 16),
                label: const AutoSizeText(
                  'Export Report',
                  maxLines: 1,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppColors.surface,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showQuickActionBottomSheet(context);
                },
                icon: const Icon(LucideIcons.zap, size: 16),
                label: const AutoSizeText(
                  'Quick Action',
                  maxLines: 1,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 4. KPI Cards Grid (4 Cards Stacked / Responsive) ---
  Widget _buildKpiCardsGrid(BuildContext context, CollegeDashboardModel data) {
    return Column(
      children: [
        // Card 1: Total Students
        _KpiCard(
          icon: LucideIcons.users,
          iconBgColor: AppColors.primaryLight,
          iconColor: AppColors.primary,
          title: 'TOTAL STUDENTS',
          value: '${data.totalStudents}',
          badgeText: data.studentGrowth,
          badgeColor: AppColors.successLight,
          badgeTextColor: AppColors.success,
          onTap: () => context.go('/college/students'),
        ),
        const SizedBox(height: 12),

        // Card 2: Active Candidates
        _KpiCard(
          icon: LucideIcons.userCheck,
          iconBgColor: const Color(0xFFF3E8FF),
          iconColor: AppColors.accentViolet,
          title: 'ACTIVE CANDIDATES',
          value: '${data.activeCandidates}',
          badgeText: data.candidateGrowth,
          badgeColor: AppColors.successLight,
          badgeTextColor: AppColors.success,
          onTap: () => context.go('/college/students'),
        ),
        const SizedBox(height: 12),

        // Card 3: Placement Success %
        _KpiCard(
          icon: LucideIcons.checkCircle2,
          iconBgColor: const Color(0xFFD1FAE5),
          iconColor: AppColors.success,
          title: 'PLACEMENT SUCCESS',
          value: '${data.placementPercentage}%',
          showProgressBar: true,
          progressValue: data.placementPercentage / 100.0,
          onTap: () => context.go('/college/analytics/department'),
        ),
        const SizedBox(height: 12),

        // Card 4: Companies Visiting
        _KpiCard(
          icon: LucideIcons.building2,
          iconBgColor: AppColors.tagBackground,
          iconColor: AppColors.textSecondary,
          title: 'COMPANIES VISITING',
          value: '${data.companiesVisiting}',
          badgeText: 'LIVE',
          badgeColor: AppColors.primaryLight,
          badgeTextColor: AppColors.primary,
          onTap: () => context.go('/college/drives'),
        ),
      ],
    );
  }

  // --- 5. Placement Velocity Card ---
  Widget _buildPlacementVelocityCard(BuildContext context, CollegeDashboardModel data) {
    final progress = (data.placedCount / data.targetCount).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.target, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Placement Velocity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    AutoSizeText(
                      'Current target: 70% placed vs 100% target',
                      maxLines: 1,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Percentage Badge & YOY Metric
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '78% TARGET REACHED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '+8.5% YOY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.inputFill,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),

          // Bottom Totals Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${data.placedCount} PLACED',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${data.targetCount} TOTAL',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 6. Monthly Placement Schedule Card (Interactive Calendar Widget) ---
  Widget _buildMonthlyScheduleCard(BuildContext context) {
    final daysOfWeek = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Monthly Placement Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedMonth,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Days Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: daysOfWeek.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Date Grid (1-31)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 31,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index + 1;
              final isDay12 = dayNumber == 12;
              final isDay20 = dayNumber == 20;
              final isDriveDay = dayNumber == 15 || dayNumber == 25;

              BoxDecoration decoration;
              TextStyle textStyle;

              if (isDay12) {
                decoration = BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                );
                textStyle = const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                );
              } else if (isDay20) {
                decoration = BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                );
                textStyle = const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                );
              } else if (isDriveDay) {
                decoration = BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(10),
                );
                textStyle = const TextStyle(
                  color: AppColors.accentViolet,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                );
              } else {
                decoration = const BoxDecoration();
                textStyle = const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                );
              }

              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/college/drives');
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: decoration,
                  alignment: Alignment.center,
                  child: Text('$dayNumber', style: textStyle),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 7. AI Insights Banner Card (Vibrant Deep Purple Gradient) ---
  Widget _buildAiInsightsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x334F46E5),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top AI Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.zap, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'AI INSIGHTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Insight Item 1
          const Text(
            'Upcoming Hiring Peak',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'We predict a 25% increase in Tech campus drives between Mar 15 - Apr 10. Recommend scheduling pre-placement talks now.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Insight Item 2
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Skill Gap Identified',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Data Engineering roles have 40% higher vacancy, but candidate readiness is at 45%. Urgent skilling recommended.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.go('/college/analytics/intelligence');
              },
              icon: const Icon(LucideIcons.sparkles, size: 16, color: AppColors.primary),
              label: const Text(
                'View Predictive Notes ➔',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 8. Upcoming Campus Drives List Section ---
  Widget _buildUpcomingDrivesSection(BuildContext context, List<CampusDriveModel> drives) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Campus Drives',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.go('/college/drives');
              },
              child: const Text(
                'View all ➔',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Drive Items Container
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: drives.map((drive) {
              final isLast = drive.id == drives.last.id;
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.go('/college/drives/${drive.id}/pipeline');
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          // Company Logo Container
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.inputFill,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              drive.companyName.isNotEmpty ? drive.companyName.substring(0, 1) : 'C',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Company & Role Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  drive.companyName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  drive.role,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Date & CTC Column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                drive.date,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  drive.ctc,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast) const Divider(height: 1, color: AppColors.border),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- 9. Recent Activities Timeline Section ---
  Widget _buildRecentActivitiesSection(BuildContext context, List<RecentActivityModel> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  final isLast = index == activities.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Node Indicator Line
                      Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 48,
                              color: AppColors.border,
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      activity.title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    activity.timestamp,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activity.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),

              // View Activity Log Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.go('/college/reports');
                  },
                  child: const Text('View Activity Log'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Quick Action Bottom Sheet ---
  void _showQuickActionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(LucideIcons.plusCircle, color: AppColors.primary),
                title: const Text('Post New Campus Drive'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/college/drives');
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.send, color: AppColors.accentViolet),
                title: const Text('Send Broadcast Announcement'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/college/operations/communication');
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.userPlus, color: AppColors.success),
                title: const Text('Add Student Master Record'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/college/students');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Navigation Router Handler ---
  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        context.go('/college/dashboard');
        break;
      case 1:
        context.go('/college/drives');
        break;
      case 3:
        context.go('/college/students');
        break;
      case 4:
        context.go('/college/operations/config');
        break;
    }
  }
}

// --- Reusable KPI Card Component ---
class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String value;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final bool showProgressBar;
  final double progressValue;
  final VoidCallback onTap;

  const _KpiCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.value,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    this.showProgressBar = false,
    this.progressValue = 0.0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Metrics Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AutoSizeText(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (showProgressBar) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 6,
                        backgroundColor: AppColors.inputFill,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Badge Pill (if provided)
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
