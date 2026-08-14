import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/student_bloc.dart';
import '../widgets/student_header.dart';
import '../widgets/student_identity_card.dart';
import '../widgets/ai_workspace_banner.dart';
import '../widgets/student_metrics_grid.dart';
import '../widgets/performance_overview_card.dart';
import '../widgets/daily_streak_card.dart';
import '../widgets/upcoming_activities_card.dart';
import '../widgets/badges_achievements_card.dart';
import '../widgets/course_modules_card.dart';
import '../widgets/placement_roadmap_card.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StudentDashboardBloc()..add(LoadStudentDashboardEvent()),
      child: const _StudentDashboardPageContent(),
    );
  }
}

class _StudentDashboardPageContent extends StatelessWidget {
  const _StudentDashboardPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentDashboardBloc, StudentDashboardState>(
      builder: (context, state) {
        final userName = state is StudentDashboardLoadedState
            ? (state.data.profile.fullName.isNotEmpty
                ? state.data.profile.fullName
                : 'Student')
            : 'Student';
        final userEmail = state is StudentDashboardLoadedState
            ? (state.data.profile.email.isNotEmpty
                ? state.data.profile.email
                : '')
            : '';
        final unreadCount = state is StudentDashboardLoadedState
            ? state.data.stats.unreadNotifications
            : 3;

        return PopScope(
          canPop: true,
          child: Scaffold(
            backgroundColor: AppColors.background,

            // Top Header Bar
            body: SafeArea(
              bottom: true,
              child: Column(
                children: [
                  // Fixed Overflow-Free Header Widget
                  StudentHeader(
                    onAskAiPressed: () => _showAskAiModal(context),
                    onSearchPressed: () => _showSearchModal(context),
                    onNotificationPressed: () {
                      context.push('/student/notifications');
                    },
                    unreadCount: unreadCount,
                    userName: userName,
                    userEmail: userEmail,
                  ),

                  // Main Content Scrollable Body
                  Expanded(
                    child: _buildBody(context, state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, StudentDashboardState state) {
    if (state is StudentDashboardLoadingState) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Loading Student Dashboard...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state is StudentDashboardErrorState) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<StudentDashboardBloc>().add(
                        LoadStudentDashboardEvent(),
                      );
                },
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is StudentDashboardLoadedState) {
      return _buildDashboardScrollableContent(context, state);
    }

    return const SizedBox.shrink();
  }

  /// Builds the 100% Figma Dashboard Mobile Home screen view without footer buttons
  Widget _buildDashboardScrollableContent(
    BuildContext context,
    StudentDashboardLoadedState state,
  ) {
    final data = state.data;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth > 600 ? 24.0 : 16.0;

    final bottomPadding = MediaQuery.of(context).padding.bottom == 0
        ? 24.0
        : MediaQuery.of(context).padding.bottom + 16.0;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<StudentDashboardBloc>().add(
              RefreshStudentDashboardEvent(),
            );
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          top: 12,
          bottom: bottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Student Identity Card
            RepaintBoundary(
              child: StudentIdentityCard(profile: data.profile),
            ),
            const SizedBox(height: 16),

            // 2. AI-Powered Career Workspace Hero Banner
            RepaintBoundary(
              child: AiWorkspaceBanner(studentName: data.profile.fullName),
            ),
            const SizedBox(height: 16),

            // 3. 2x2 Metric Cards Grid
            RepaintBoundary(
              child: StudentMetricsGrid(stats: data.stats),
            ),
            const SizedBox(height: 16),

            // 4. Learning Analytics Performance Overview Card
            RepaintBoundary(
              child: PerformanceOverviewCard(
                performanceData: data.performanceData,
              ),
            ),
            const SizedBox(height: 16),

            // 5. Productivity Daily Streak Card
            RepaintBoundary(
              child: DailyStreakCard(streak: data.streak),
            ),
            const SizedBox(height: 16),

            // 6. Upcoming Corporate Activities & Interviews Card
            RepaintBoundary(
              child: UpcomingActivitiesCard(
                activities: data.upcomingActivities,
              ),
            ),
            const SizedBox(height: 16),

            // 7. Badges & Achievements Section
            RepaintBoundary(
              child: BadgesAchievementsCard(badges: data.badges),
            ),
            const SizedBox(height: 16),

            // 8. Course Tracking - Modules & Learning Progress
            RepaintBoundary(
              child: CourseModulesCard(modules: data.modules),
            ),
            const SizedBox(height: 16),

            // 9. Career Path - Roadmap to Placement (Dark Navy Grid)
            const RepaintBoundary(
              child: PlacementRoadmapCard(),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays the Ask AI Career Coach modal screen
  void _showAskAiModal(BuildContext context) {
    HapticFeedback.lightImpact();
    context.push('/student/ask-ai');
  }

  /// Displays the interactive portal search modal
  void _showSearchModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final screenHeight = MediaQuery.sizeOf(context).height;
            return Container(
              height: screenHeight * 0.72,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.search, size: 20, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AutoSizeText(
                          'Search Portal & Features',
                          maxLines: 1,
                          minFontSize: 13,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    autofocus: true,
                    onSubmitted: (query) {
                      if (query.trim().isNotEmpty) {
                        Navigator.pop(modalContext);
                        context.push('/student/projects?search=${Uri.encodeComponent(query.trim())}');
                      }
                    },
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Type to search projects, ATS resume, drives, settings...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Quick Feature Shortcuts',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildSearchTile(
                          context,
                          modalContext,
                          title: 'Browse Projects & Openings',
                          subtitle: 'Explore available corporate projects and internships',
                          icon: LucideIcons.briefcase,
                          route: '/student/projects',
                        ),
                        _buildSearchTile(
                          context,
                          modalContext,
                          title: 'AI Resume Builder & ATS Score',
                          subtitle: 'Craft ATS recruiter-ready resumes and optimize score',
                          icon: LucideIcons.fileText,
                          route: '/student/ai-resume',
                        ),
                        _buildSearchTile(
                          context,
                          modalContext,
                          title: 'Hiring Process & Placement Drives',
                          subtitle: 'Track interviews, placement rounds, and offers',
                          icon: LucideIcons.trendingUp,
                          route: '/student/hiring-process',
                        ),
                        _buildSearchTile(
                          context,
                          modalContext,
                          title: 'My Profile & Skill Tags',
                          subtitle: 'Update your contact details, bio, and social links',
                          icon: LucideIcons.user,
                          route: '/student/profile',
                        ),
                        _buildSearchTile(
                          context,
                          modalContext,
                          title: 'Certificates & Credentials',
                          subtitle: 'View and download verified C2C course certificates',
                          icon: LucideIcons.award,
                          route: '/student/certificates',
                        ),
                        _buildSearchTile(
                          context,
                          modalContext,
                          title: 'Account & Security Settings',
                          subtitle: 'Manage 2FA, dark theme mode, and privacy settings',
                          icon: LucideIcons.settings,
                          route: '/student/settings',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildSearchTile(
    BuildContext context,
    BuildContext modalContext, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        title: AutoSizeText(
          title,
          maxLines: 1,
          minFontSize: 11,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        subtitle: AutoSizeText(
          subtitle,
          maxLines: 2,
          minFontSize: 10,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
        onTap: () {
          Navigator.pop(modalContext);
          context.push(route);
        },
      ),
    );
  }
}
