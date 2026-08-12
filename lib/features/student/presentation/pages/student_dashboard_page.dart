import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

import 'student_profile_view.dart';
import 'student_projects_view.dart';
import 'student_alerts_view.dart';

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
        final activeTab = state.activeTab;

        return Scaffold(
          backgroundColor: AppColors.background,

          // Top Header Bar
          body: SafeArea(
            bottom: true,
            child: Column(
              children: [
                // Fixed Header Widget
                StudentHeader(
                  onAskAiPressed: () => _showAskAiModal(context),
                  onSearchPressed: () => _showSearchModal(context),
                  onNotificationPressed: () {
                    context.read<StudentDashboardBloc>().add(
                          ChangeStudentTabEvent(3),
                        );
                  },
                  unreadCount: state is StudentDashboardLoadedState
                      ? state.data.stats.unreadNotifications
                      : 3,
                  userName: state is StudentDashboardLoadedState
                      ? (state.data.profile.fullName.isNotEmpty ? state.data.profile.fullName : 'Student')
                      : 'Student',
                  userEmail: state is StudentDashboardLoadedState
                      ? (state.data.profile.email.isNotEmpty ? state.data.profile.email : '')
                      : '',
                ),

                // Main Content Body according to State & Active Tab
                Expanded(
                  child: _buildBody(context, state, activeTab),
                ),
              ],
            ),
          ),

          // Adaptive Bottom Navigation Bar
          bottomNavigationBar: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom == 0 ? 16.0 : MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: activeTab,
              onDestinationSelected: (index) {
                HapticFeedback.lightImpact();
                context.read<StudentDashboardBloc>().add(
                      ChangeStudentTabEvent(index),
                    );
              },
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primaryLight,
              elevation: 0,
              destinations: const [
                NavigationDestination(
                  icon: Icon(LucideIcons.home, color: AppColors.textMuted),
                  selectedIcon:
                      Icon(LucideIcons.home, color: AppColors.primaryDark),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(LucideIcons.user, color: AppColors.textMuted),
                  selectedIcon:
                      Icon(LucideIcons.user, color: AppColors.primaryDark),
                  label: 'Profile',
                ),
                NavigationDestination(
                  icon: Icon(LucideIcons.clipboard, color: AppColors.textMuted),
                  selectedIcon: Icon(LucideIcons.clipboard,
                      color: AppColors.primaryDark),
                  label: 'Projects',
                ),
                NavigationDestination(
                  icon: Icon(LucideIcons.bell, color: AppColors.textMuted),
                  selectedIcon:
                      Icon(LucideIcons.bell, color: AppColors.primaryDark),
                  label: 'Alerts',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    StudentDashboardState state,
    int activeTab,
  ) {
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
              const Icon(LucideIcons.alertCircle,
                  size: 48, color: AppColors.error),
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
      return IndexedStack(
        index: activeTab,
        children: [
          // Tab 0: Main Figma Student Dashboard Mobile View
          _buildFigmaDashboardHome(context, state),

          // Tab 1: Profile View
          StudentProfileView(initialProfile: state.data.profile),

          // Tab 2: Projects View
          StudentProjectsView(projects: state.projects),

          // Tab 3: Alerts View
          StudentAlertsView(notifications: state.notifications),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  /// Builds the 100% Figma Dashboard Mobile Home screen view with smooth scroll physics & non-overflowing components
  Widget _buildFigmaDashboardHome(
    BuildContext context,
    StudentDashboardLoadedState state,
  ) {
    final data = state.data;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth > 600 ? 24.0 : 16.0;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<StudentDashboardBloc>().add(
              RefreshStudentDashboardEvent(),
            );
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Student Dark Navy Identity Card
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

            const SizedBox(height: 32),
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

  /// Displays the search modal
  void _showSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search courses, drives, skills...',
                  prefixIcon: const Icon(LucideIcons.search, size: 18),
                  suffixIcon: IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
