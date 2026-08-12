import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../bloc/placement_hub_bloc.dart';
import '../../domain/models/placement_hub_dashboard_data.dart';
import '../widgets/college_drawer.dart';

class PlacementHubPage extends StatelessWidget {
  const PlacementHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlacementHubBloc()..add(FetchDrivesEvent()),
      child: const _PlacementHubContentView(),
    );
  }
}

class _PlacementHubContentView extends StatefulWidget {
  const _PlacementHubContentView();

  @override
  State<_PlacementHubContentView> createState() => _PlacementHubContentViewState();
}

class _PlacementHubContentViewState extends State<_PlacementHubContentView> {
  int _selectedNavIndex = 1;
  final List<String> _hubTabs = ['Overview', 'Recruitment Trends', 'Departmental ROI'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktopOrTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/drives'),
      body: SafeArea(
        child: Row(
          children: [
            // Adaptive Navigation: Rail for Desktop/Tablet (> 600dp)
            if (isDesktopOrTablet) ...[
              NavigationRail(
                selectedIndex: _selectedNavIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedNavIndex = index);
                  _handleNavigation(index);
                },
                labelType: NavigationRailLabelType.selected,
                backgroundColor: AppColors.surface,
                selectedIconTheme: const IconThemeData(color: AppColors.primary),
                unselectedIconTheme: const IconThemeData(color: AppColors.textMuted),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(LucideIcons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(LucideIcons.calendar),
                    label: Text('Drives'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(LucideIcons.fileText),
                    label: Text('Reports'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(LucideIcons.users),
                    label: Text('Students'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(LucideIcons.settings),
                    label: Text('Settings'),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1, color: AppColors.border),
            ],

            // Main Content Area
            Expanded(
              child: BlocConsumer<PlacementHubBloc, PlacementHubState>(
                listener: (context, state) {
                  if (state is PlacementHubError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is PlacementHubLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    );
                  }

                  final data = (state is PlacementHubLoaded)
                      ? state.dashboardData
                      : PlacementHubDashboardData.mockData;

                  final selectedTab = (state is PlacementHubLoaded) ? state.selectedTab : 'Overview';

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      HapticFeedback.lightImpact();
                      context.read<PlacementHubBloc>().add(FetchDrivesEvent(selectedTab: selectedTab));
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktopOrTablet ? 24.0 : 16.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Top Header Bar (C2C Logo, Drawer, Notifications, Avatar)
                          _buildHeaderBar(context),
                          const SizedBox(height: 16),

                          // 2. Coordination Hub Header Title & Filter Tabs
                          _buildTitleAndTabSection(context, selectedTab, data),
                          const SizedBox(height: 18),

                          // 3. Campus Drive Calendar Widget
                          RepaintBoundary(
                            child: _buildCampusDriveCalendar(context, data.calendarEvents),
                          ),
                          const SizedBox(height: 20),

                          // 4. Live Offer Pipeline Section (Horizontal Carousel)
                          RepaintBoundary(
                            child: _buildLiveOfferPipelineSection(context, data.offerPipelines),
                          ),
                          const SizedBox(height: 20),

                          // 5. Recruiter Allocation Card
                          RepaintBoundary(
                            child: _buildRecruiterAllocationCard(context, data.recruiters),
                          ),
                          const SizedBox(height: 20),

                          // 6. Today's Lineup (Live Interview Timeline)
                          RepaintBoundary(
                            child: _buildTodaysLineupCard(context, data.todaysLineup),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isDesktopOrTablet
          ? null
          : CustomBottomNav(
              currentIndex: _selectedNavIndex,
              onTap: (index) {
                setState(() => _selectedNavIndex = index);
                _handleNavigation(index);
              },
              onFabPressed: () => _showAssignRecruiterModal(context),
            ),
    );
  }

  // --- 1. Top Header Bar ---
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

        // Bell Notification Icon with Badge
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
          borderRadius: BorderRadius.circular(18),
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

  // --- 2. Title & Subtitle + Dynamic Filter Tabs ---
  Widget _buildTitleAndTabSection(
    BuildContext context,
    String selectedTab,
    PlacementHubDashboardData data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ShaderMask Title Gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.textPrimary, AppColors.primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            'Coordination Hub',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white, // Transparent target for ShaderMask
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Subtitle with Dynamic Counts
        Text(
          'Managing ${data.activeCyclesCount} active recruitment cycles and ${data.totalCandidatesCount}+ candidate pipelines.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
        ),
        const SizedBox(height: 14),

        // Filter Tabs Carousel
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _hubTabs.map((tab) {
              final isSelected = selectedTab == tab;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<PlacementHubBloc>().add(ChangeTabEvent(tab));
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.fastOutSlowIn,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.inputFill,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- 3. Campus Drive Calendar Widget ---
  Widget _buildCampusDriveCalendar(
    BuildContext context,
    List<CalendarEventModel> events,
  ) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.calendar, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Campus Drive Calendar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              // Month Navigator
              Row(
                children: [
                  InkWell(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: const Icon(LucideIcons.chevronLeft, size: 16, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'October 2023',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Events List
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Text(
                  'No scheduled events for this month',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = events[index];
                return _buildCalendarScheduleTile(
                  context,
                  month: item.month,
                  date: item.date,
                  title: item.title,
                  subtitle: item.subtitle,
                  accentColor: item.accentColor,
                  bgColor: AppColors.inputFill,
                  driveId: item.driveId,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarScheduleTile(
    BuildContext context, {
    required String month,
    required String date,
    required String title,
    required String subtitle,
    required Color accentColor,
    required Color bgColor,
    required String driveId,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go('/college/drives/$driveId/pipeline');
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Left Vertical Accent Strip
            Container(
              width: 4,
              height: 38,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Date Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Title & Subtitle with AutoSizeText
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    title,
                    maxLines: 1,
                    minFontSize: 11,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(LucideIcons.moreVertical, size: 18, color: AppColors.textMuted),
              onPressed: () => HapticFeedback.lightImpact(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. Live Offer Pipeline Section (Horizontal Card Carousel) ---
  Widget _buildLiveOfferPipelineSection(
    BuildContext context,
    List<PipelineOfferModel> offerPipelines,
  ) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth * 0.72).clamp(240.0, 340.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.trendingUp, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Live Offer Pipeline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.go('/college/drives');
              },
              child: const Row(
                children: [
                  Icon(LucideIcons.filter, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text(
                    'FILTER',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Dynamic Horizontal Carousel Box
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: offerPipelines.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = offerPipelines[index];
              return Hero(
                tag: 'pipeline_card_${item.id}',
                child: Material(
                  color: Colors.transparent,
                  child: _buildPipelineCarouselCard(
                    context,
                    cardWidth: cardWidth,
                    driveId: item.driveId,
                    badgeText: item.badgeText,
                    badgeColor: item.badgeColor,
                    title: item.roleTitle,
                    company: item.companyName,
                    icon: index == 0
                        ? LucideIcons.briefcase
                        : (index == 1 ? LucideIcons.database : LucideIcons.code),
                    iconBg: item.badgeColor.withValues(alpha: 0.15),
                    progress: item.progress,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPipelineCarouselCard(
    BuildContext context, {
    required double cardWidth,
    required String driveId,
    required String badgeText,
    required Color badgeColor,
    required String title,
    required String company,
    required IconData icon,
    required Color iconBg,
    required double progress,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        // Route to Screen 5: Job Pipeline Page
        context.go('/college/drives/$driveId/pipeline');
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: cardWidth,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: badgeColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  title,
                  maxLines: 1,
                  minFontSize: 11,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            // Progress Indicator Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.inputFill,
                valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 5. Recruiter Allocation Card ---
  Widget _buildRecruiterAllocationCard(
    BuildContext context,
    List<RecruiterAllocationModel> recruiters,
  ) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recruiter Allocation',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showAssignRecruiterModal(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(LucideIcons.userPlus, size: 18, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dynamic Recruiter List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recruiters.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final recruiter = recruiters[index];
              return _buildRecruiterRowTile(
                context,
                companyId: recruiter.companyId,
                initials: recruiter.initials,
                name: recruiter.name,
                title: recruiter.title,
                activeCount: '${recruiter.activeCount.toString().padLeft(2, '0')} ACTIVE',
              );
            },
          ),
          const SizedBox(height: 14),

          // Dashed / Outlined Assign Recruiter Button
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _showAssignRecruiterModal(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Text(
                  '+ Assign Recruiter',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruiterRowTile(
    BuildContext context, {
    required String companyId,
    required String initials,
    required String name,
    required String title,
    required String activeCount,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        // Route to Screen 6: Company & Recruiter Snapshot
        context.go('/college/companies/$companyId');
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Hero(
              tag: 'recruiter_avatar_$initials',
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    name,
                    maxLines: 1,
                    minFontSize: 11,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  activeCount.split(' ')[0],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary),
                ),
                Text(
                  activeCount.split(' ').length > 1 ? activeCount.split(' ')[1] : '',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 6. Today's Lineup (Live Interview Timeline) ---
  Widget _buildTodaysLineupCard(
    BuildContext context,
    List<LineupInterviewModel> todaysLineup,
  ) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.video, size: 18, color: AppColors.error),
                  SizedBox(width: 8),
                  Text(
                    "Today's Lineup",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.error,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dynamic Timeline Items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todaysLineup.length,
            itemBuilder: (context, index) {
              final item = todaysLineup[index];
              final isLastItem = index == todaysLineup.length - 1;

              return _buildTimelineInterviewTile(
                context,
                time: item.time,
                statusText: item.statusText,
                statusBg: item.statusBg,
                statusColor: item.statusColor,
                candidateName: item.candidateName,
                roleCompany: item.roleCompany,
                interviewer: item.interviewer,
                isLast: isLastItem,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineInterviewTile(
    BuildContext context, {
    required String time,
    required String statusText,
    required Color statusBg,
    required Color statusColor,
    required String candidateName,
    required String roleCompany,
    required String interviewer,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Node Line Column
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 84,
                color: AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Timeline Content Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputFill.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AutoSizeText(
                    candidateName,
                    maxLines: 1,
                    minFontSize: 11,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    roleCompany,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 6),
                  Text(
                    interviewer,
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Assign Recruiter Bottom Modal Sheet ---
  void _showAssignRecruiterModal(BuildContext parentContext) {
    final nameController = TextEditingController();
    final cycleController = TextEditingController();

    showModalBottomSheet(
      context: parentContext,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Assign New Recruiter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Coordinator Name (e.g. Jane Doe)',
                  prefixIcon: Icon(LucideIcons.user, size: 18, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cycleController,
                decoration: const InputDecoration(
                  hintText: 'Assign Drive Cycle (e.g. Google STEP)',
                  prefixIcon: Icon(LucideIcons.briefcase, size: 18, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    final name = nameController.text.trim();
                    final cycle = cycleController.text.trim();

                    if (name.isNotEmpty && cycle.isNotEmpty) {
                      parentContext.read<PlacementHubBloc>().add(
                            AssignRecruiterEvent(
                              coordinatorName: name,
                              driveCycle: cycle,
                            ),
                          );
                    }
                    Navigator.pop(modalContext);
                  },
                  child: const Text('Confirm Assignment'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleNavigation(int index) {
    HapticFeedback.lightImpact();
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
