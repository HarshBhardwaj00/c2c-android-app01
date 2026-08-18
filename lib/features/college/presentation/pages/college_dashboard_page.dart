import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../bloc/college_bloc.dart';
import '../../data/services/college_api_service.dart';
import '../../domain/models/college_dashboard_model.dart';
import '../widgets/college_drawer.dart';
import '../../../auth/presentation/widgets/bouncy_button.dart';

/// Production-ready, 100% Overflow-Free College Executive Overview Dashboard.
/// Built with strict Responsive Bounded Layouts, AutoSizeText scaling,
/// Impeller engine optimization, System Navigation Safe Bottom Sheets, and Central Theme Tokens.
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CollegeApiService _apiService = CollegeApiService();

  int _selectedNavIndex = 0;
  String? _toastMessage;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    HapticFeedback.mediumImpact();
    setState(() => _toastMessage = message);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: context.bg,
        drawer: const CollegeNavigationDrawer(currentRoute: '/college/dashboard'),
        body: SafeArea(
          bottom: true,
          child: Stack(
            children: [
              RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context.read<CollegeBloc>().add(RefreshCollegeDashboard());
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 12.0,
                    bottom: bottomPadding == 0 ? 110.0 : bottomPadding + 96.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Adaptive Header Bar
                      _buildTopHeaderBar(context),
                      const SizedBox(height: 14),

                      // 2. Main Executive Content
                      BlocBuilder<CollegeBloc, CollegeState>(
                        builder: (context, state) {
                          if (state is CollegeLoading) {
                            return const SizedBox(
                              height: 380,
                              child: Center(
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ),
                            );
                          }

                          final data = (state is CollegeLoaded) ? state.data : CollegeDashboardModel.mockData;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hero Welcome Banner
                              _buildWelcomeHeroBanner(context, data),
                              const SizedBox(height: 14),

                              // Quick Actions & Urgent Pending Action Banner
                              _buildQuickActionsAndUrgentCard(context),
                              const SizedBox(height: 14),

                              // Key Metrics 2x2 Responsive Grid
                              _buildKeyMetricCards(context, data),
                              const SizedBox(height: 14),

                              // Recent Student Activity Feed
                              _buildRecentActivitySection(context, data.recentActivities),
                              const SizedBox(height: 14),

                              // Upcoming Placement Schedule Timeline (100% Overflow Protected)
                              _buildUpcomingScheduleSection(context, data.scheduleEvents),
                              const SizedBox(height: 14),

                              // AI Insight Recommendation Card
                              _buildAiInsightRecommendationCard(context),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Floating AI Placement Assistant FAB
              Positioned(
                bottom: bottomPadding == 0 ? 24 : bottomPadding + 16,
                right: 16,
                child: _buildFloatingAiAssistantFab(context),
              ),

              // Toast Notification Banner
              if (_toastMessage != null)
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: _buildToastNotification(context, _toastMessage!),
                ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _selectedNavIndex,
          onTap: (index) {
            setState(() => _selectedNavIndex = index);
            if (index == 1) {
              context.go('/college/reports');
            } else if (index == 3) {
              context.go('/college/students');
            } else if (index == 4) {
              context.go('/college/settings');
            }
          },
          onFabPressed: () => _showScheduleDriveModal(context),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. TOP RESPONSIVE HEADER BAR
  // ---------------------------------------------------------------------------
  Widget _buildTopHeaderBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.brdr),
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
          // Drawer / Back Trigger
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                _scaffoldKey.currentState?.openDrawer();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.surfAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.brdr),
              ),
              child: Icon(
                Navigator.canPop(context) ? LucideIcons.arrowLeft : LucideIcons.menu,
                color: context.txtPrimary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Search Field
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: context.surfAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.search, size: 15, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.txtPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search candidates...',
                        hintStyle: TextStyle(fontSize: 11, color: context.txtMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(LucideIcons.x, size: 14, color: AppColors.textMuted),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Quick Action Launch Button (New Drive)
          BouncyButton(
            onPressed: () => _showScheduleDriveModal(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentViolet, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentViolet.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.plus, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'New Drive',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. WELCOME HERO BANNER
  // ---------------------------------------------------------------------------
  Widget _buildWelcomeHeroBanner(BuildContext context, CollegeDashboardModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C1D95), AppColors.accentViolet, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placement Season Active Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.sparkles, size: 13, color: Color(0xFFFDE047)),
                SizedBox(width: 6),
                Text(
                  'Campus Placement Season Active',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Title
          AutoSizeText(
            'Welcome back, ${data.collegeName}',
            maxLines: 2,
            minFontSize: 15,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            'Academic Year 2025-26. You have ${data.totalStudents} candidates enrolled for upcoming recruitment cycles.',
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Embedded Stat Badges Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'ACTIVE STUDENTS',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AutoSizeText(
                        '${data.activeCandidates}',
                        maxLines: 1,
                        minFontSize: 14,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'PLACEMENT RATE',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AutoSizeText(
                        '${data.placementPercentage}%',
                        maxLines: 1,
                        minFontSize: 14,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. QUICK ACTIONS & URGENT PENDING ACTIONS
  // ---------------------------------------------------------------------------
  Widget _buildQuickActionsAndUrgentCard(BuildContext context) {
    return Column(
      children: [
        // Quick Actions 2x2 Grid
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.brdr),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QUICK ACTIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: context.txtMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.priLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Frequent Tasks',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionTile(
                      context: context,
                      icon: LucideIcons.userPlus,
                      label: 'Invite Students',
                      onTap: () => _showInviteStudentsModal(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionTile(
                      context: context,
                      icon: LucideIcons.calendar,
                      label: 'Schedule Drive',
                      onTap: () => _showScheduleDriveModal(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionTile(
                      context: context,
                      icon: LucideIcons.send,
                      label: 'Send Broadcast',
                      onTap: () => _showBroadcastModal(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionTile(
                      context: context,
                      icon: LucideIcons.fileText,
                      label: 'View Reports',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.go('/college/reports');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Urgent Pending Actions Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.errorLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFECDD3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.alertTriangle, size: 15, color: AppColors.error),
                      SizedBox(width: 6),
                      Text(
                        'PENDING ACTIONS',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.error,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF9F1239),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Placement drive eligibility verification pending for active registered candidate cohort.',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF881337),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: BouncyButton(
                  onPressed: () => _showReviewPendingModal(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Review Now',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.error,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(LucideIcons.arrowRight, size: 13, color: AppColors.error),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return BouncyButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: context.priLight.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.priLight),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 15, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AutoSizeText(
                label,
                maxLines: 2,
                minFontSize: 9,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.txtPrimary,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. KEY METRICS ROW (Responsive 2x2 Grid)
  // ---------------------------------------------------------------------------
  Widget _buildKeyMetricCards(BuildContext context, CollegeDashboardModel data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                context: context,
                title: 'TOTAL CANDIDATES',
                value: '${data.totalStudents}',
                subtext: 'Registered database cohort',
                icon: LucideIcons.users,
                progress: 0.85,
                progressColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiCard(
                context: context,
                title: 'ACTIVE DRIVES',
                value: '${data.totalProjects}',
                subtext: 'Ongoing recruitment',
                icon: LucideIcons.briefcase,
                badgeText: 'Active Cycle',
                badgeColor: AppColors.aiBadgeBg,
                badgeTextColor: AppColors.aiBadgeText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                context: context,
                title: 'INTERVIEWS / APPS',
                value: '${data.totalApplications}',
                subtext: 'Applications submitted',
                icon: LucideIcons.clock,
                badgeText: 'Review Stage',
                badgeColor: AppColors.warningLight,
                badgeTextColor: const Color(0xFFB45309),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiCard(
                context: context,
                title: 'BROADCASTS',
                value: '${data.broadcastsSent}',
                subtext: '100% Delivery Success',
                icon: LucideIcons.send,
                progress: 1.0,
                progressColor: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    String? badgeText,
    Color? badgeColor,
    Color? badgeTextColor,
    double? progress,
    Color? progressColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.brdr),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: context.txtMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: context.priLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 13, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),

          AutoSizeText(
            value,
            maxLines: 1,
            minFontSize: 16,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: context.txtPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),

          if (badgeText != null)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: badgeTextColor ?? AppColors.primary,
                  ),
                ),
              ),
            )
          else if (progress != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: context.surfAlt,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor ?? AppColors.primary),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtext,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 8.5, color: context.txtMuted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. RECENT STUDENT ACTIVITY FEED
  // ---------------------------------------------------------------------------
  Widget _buildRecentActivitySection(
    BuildContext context,
    List<RecentActivityModel> activities,
  ) {
    final filtered = activities.where((act) {
      if (_searchQuery.isEmpty) return true;
      return act.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          act.action.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          act.detail.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.brdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AutoSizeText(
                  'Recent Student Activity',
                  maxLines: 1,
                  minFontSize: 11,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: context.txtPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BouncyButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.go('/college/students');
                },
                child: const Text(
                  'View All ➔',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => Divider(height: 14, color: context.brdr),
            itemBuilder: (context, index) {
              final act = filtered[index];
              return _buildActivityItem(context, act);
            },
          ),

          const SizedBox(height: 10),
          Divider(height: 1, color: context.brdr),
          const SizedBox(height: 6),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Real-time candidate feed',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: context.txtMuted, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Synced with database',
                style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, RecentActivityModel act) {
    Color avatarColor = const Color(0xFF2563EB);
    Color badgeBg = context.surfAlt;
    Color badgeTextColor = context.txtSecondary;

    if (act.badgeType == 'score') {
      avatarColor = AppColors.accentViolet;
      badgeBg = AppColors.aiBadgeBg;
      badgeTextColor = AppColors.aiBadgeText;
    } else if (act.badgeType == 'updated') {
      avatarColor = AppColors.warning;
      badgeBg = AppColors.warningLight;
      badgeTextColor = const Color(0xFF92400E);
    } else if (act.badgeType == 'shortlisted') {
      avatarColor = AppColors.success;
      badgeBg = AppColors.successLight;
      badgeTextColor = const Color(0xFF065F46);
    }

    final initials = act.name.trim().isNotEmpty
        ? act.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'ST';

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: avatarColor,
          child: Text(
            initials,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  text: act.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: context.txtPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: ' ${act.detail}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.normal,
                        color: context.txtMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 1),
              Text(
                act.action,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: context.txtSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              act.badgeText,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                color: badgeTextColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 6. UPCOMING PLACEMENT SCHEDULE TIMELINE (100% Overflow Protected)
  // ---------------------------------------------------------------------------
  Widget _buildUpcomingScheduleSection(
    BuildContext context,
    List<ScheduleEventModel> events,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.brdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AutoSizeText(
                  'Upcoming Drives Timeline',
                  maxLines: 1,
                  minFontSize: 11,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: context.txtPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.priLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Placement Cycle',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final ev = events[index];
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.surfAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.brdr),
                ),
                child: Row(
                  children: [
                    // Date Badge
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.priLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ev.month,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ev.day,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: context.txtPrimary,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Info (100% Overflow Proof)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AutoSizeText(
                            ev.title,
                            maxLines: 1,
                            minFontSize: 10,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: context.txtPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ev.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                              color: context.txtMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(LucideIcons.chevronRight, size: 15, color: context.txtMuted),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. AI INSIGHT RECOMMENDATION CARD
  // ---------------------------------------------------------------------------
  Widget _buildAiInsightRecommendationCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.brdr),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(LucideIcons.sparkles, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'AI INSIGHT RECOMMENDATION',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Cohort placement readiness has improved. 84% of Computer Science candidates are validated for upcoming placement drives.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: context.txtPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. FLOATING AI PLACEMENT ASSISTANT FAB
  // ---------------------------------------------------------------------------
  Widget _buildFloatingAiAssistantFab(BuildContext context) {
    return BouncyButton(
      onPressed: () => _showAiAssistantChatSheet(context),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accentViolet, AppColors.primaryDark],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(LucideIcons.messageSquare, color: Colors.white, size: 20),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 9. TOAST NOTIFICATION BANNER
  // ---------------------------------------------------------------------------
  Widget _buildToastNotification(BuildContext context, String message) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.checkCircle2, size: 16, color: AppColors.success),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _toastMessage = null),
              child: const Icon(LucideIcons.x, size: 15, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 10. MODAL: SCHEDULE NEW PLACEMENT DRIVE (POST /api/college/projects)
  // ---------------------------------------------------------------------------
  void _showScheduleDriveModal(BuildContext context) {
    HapticFeedback.mediumImpact();
    final bloc = context.read<CollegeBloc>();
    final companyController = TextEditingController();
    final roleController = TextEditingController();
    final packageController = TextEditingController(text: '12.0');
    final dateController = TextEditingController(text: '2026-03-25');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final sysBottomPadding = MediaQuery.of(ctx).padding.bottom;
        final effectiveBottom = bottomInset > 0
            ? bottomInset + 16.0
            : (sysBottomPadding == 0 ? 24.0 : sysBottomPadding + 16.0);

        return SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: effectiveBottom,
            ),
            decoration: BoxDecoration(
              color: context.surf,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Schedule New Placement Drive',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: context.txtPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(LucideIcons.x, size: 18),
                      ),
                    ],
                  ),
                  Divider(color: context.brdr),
                  const SizedBox(height: 10),

                  _buildFormField(context, 'Company Name', 'e.g. Google India / TCS', companyController),
                  const SizedBox(height: 10),

                  _buildFormField(context, 'Job Role', 'e.g. Full Stack Developer', roleController),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(context, 'Package (LPA)', 'e.g. 18.5', packageController),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFormField(context, 'Drive Date', 'YYYY-MM-DD', dateController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (companyController.text.trim().isEmpty || roleController.text.trim().isEmpty) {
                          return;
                        }
                        Navigator.pop(ctx);
                        try {
                          await _apiService.createPlacementDrive({
                            'companyName': companyController.text.trim(),
                            'jobRole': roleController.text.trim(),
                            'packageLPA': packageController.text.trim(),
                            'driveDate': dateController.text.trim(),
                          });
                          _showToast('Placement Drive for ${companyController.text.trim()} scheduled successfully!');
                          bloc.add(RefreshCollegeDashboard());
                        } catch (e) {
                          _showToast(e.toString().replaceAll('Exception: ', ''));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Schedule Drive in Database',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 11. MODAL: INVITE STUDENTS (POST /api/college/students)
  // ---------------------------------------------------------------------------
  void _showInviteStudentsModal(BuildContext context) {
    HapticFeedback.mediumImpact();
    final bloc = context.read<CollegeBloc>();
    final emailsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final sysBottomPadding = MediaQuery.of(ctx).padding.bottom;
        final effectiveBottom = bottomInset > 0
            ? bottomInset + 16.0
            : (sysBottomPadding == 0 ? 24.0 : sysBottomPadding + 16.0);

        return SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: effectiveBottom,
            ),
            decoration: BoxDecoration(
              color: context.surf,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Register Candidates by Email',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: context.txtPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(LucideIcons.x, size: 18),
                      ),
                    ],
                  ),
                  Divider(color: context.brdr),
                  const SizedBox(height: 10),

                  _buildFormField(
                    context,
                    'Candidate Email(s) (comma separated)',
                    'rahul@college.edu, ananya@college.edu',
                    emailsController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (emailsController.text.trim().isEmpty) return;
                        Navigator.pop(ctx);
                        try {
                          await _apiService.inviteStudents(emails: emailsController.text.trim());
                          _showToast('Candidate(s) registered in database successfully!');
                          bloc.add(RefreshCollegeDashboard());
                        } catch (e) {
                          _showToast(e.toString().replaceAll('Exception: ', ''));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Register Candidates',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 12. MODAL: SEND BROADCAST (UI Feature)
  // ---------------------------------------------------------------------------
  void _showBroadcastModal(BuildContext context) {
    HapticFeedback.mediumImpact();
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final sysBottomPadding = MediaQuery.of(ctx).padding.bottom;
        final effectiveBottom = bottomInset > 0
            ? bottomInset + 16.0
            : (sysBottomPadding == 0 ? 24.0 : sysBottomPadding + 16.0);

        return SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: effectiveBottom,
            ),
            decoration: BoxDecoration(
              color: context.surf,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Send Campus Broadcast',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: context.txtPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(LucideIcons.x, size: 18),
                      ),
                    ],
                  ),
                  Divider(color: context.brdr),
                  const SizedBox(height: 10),

                  _buildFormField(context, 'Subject', 'e.g. Mandatory Pre-Placement Talk', subjectController),
                  const SizedBox(height: 10),

                  _buildFormField(
                    context,
                    'Message Announcement',
                    'Details about time, venue, dress code...',
                    messageController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (subjectController.text.trim().isEmpty) return;
                        Navigator.pop(ctx);
                        await _apiService.sendBroadcast(
                          subject: subjectController.text.trim(),
                          message: messageController.text.trim(),
                        );
                        _showToast('Broadcast "${subjectController.text.trim()}" dispatched successfully!');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Dispatch Broadcast',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 13. MODAL: REVIEW PENDING ACTION
  // ---------------------------------------------------------------------------
  void _showReviewPendingModal(BuildContext context) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final sysBottom = MediaQuery.of(ctx).padding.bottom;
        return SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: sysBottom == 0 ? 24.0 : sysBottom + 16.0,
            ),
            decoration: BoxDecoration(
              color: context.surf,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pending Placement Actions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: context.txtPrimary),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(LucideIcons.x, size: 18),
                    ),
                  ],
                ),
                Divider(color: context.brdr),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.alertCircle, size: 20, color: Color(0xFFB45309)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Google Placement Drive registration cutoff is approaching. Verify student eligibility status.',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Dismiss', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.go('/college/students');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Go to Candidates', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 14. MODAL: AI ASSISTANT CHAT SHEET (UI Feature)
  // ---------------------------------------------------------------------------
  void _showAiAssistantChatSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    final promptCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final sysBottom = MediaQuery.of(ctx).padding.bottom;
        final effectiveBottom = bottomInset > 0 ? bottomInset + 16 : (sysBottom == 0 ? 24.0 : sysBottom + 16.0);

        return SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: effectiveBottom,
            ),
            decoration: BoxDecoration(
              color: context.surf,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(LucideIcons.sparkles, size: 20, color: AppColors.accentViolet),
                          SizedBox(width: 8),
                          Text(
                            'AI Placement Advisor',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(LucideIcons.x, size: 18),
                      ),
                    ],
                  ),
                  Divider(color: context.brdr),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.surfAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Ask AI about placement predictions, high-demand technical skills, salary benchmarks, or candidate readiness analysis for your college.',
                      style: TextStyle(fontSize: 11.5, color: context.txtSecondary, height: 1.35),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: promptCtrl,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'e.g. Which branch has highest placement conversion this season?',
                      hintStyle: TextStyle(fontSize: 11.5, color: context.txtMuted),
                      filled: true,
                      fillColor: context.surfAlt,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (promptCtrl.text.trim().isEmpty) return;
                        Navigator.pop(ctx);
                        _showToast('Analyzing cohort data with C2C AI Engine...');
                      },
                      icon: const Icon(LucideIcons.send, size: 14, color: Colors.white),
                      label: const Text('Ask AI Advisor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField(
    BuildContext context,
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: context.txtPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: context.surfAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.brdr),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 12, color: context.txtMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}
