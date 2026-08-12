import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../domain/models/departmental_analytics_model.dart';
import '../../data/services/departmental_analytics_api_service.dart';
import '../widgets/college_drawer.dart';

class DepartmentalAnalyticsPage extends StatefulWidget {
  const DepartmentalAnalyticsPage({super.key});

  @override
  State<DepartmentalAnalyticsPage> createState() => _DepartmentalAnalyticsPageState();
}

class _DepartmentalAnalyticsPageState extends State<DepartmentalAnalyticsPage> {
  final DepartmentalAnalyticsApiService _apiService = DepartmentalAnalyticsApiService();
  late Future<DepartmentalAnalyticsDataModel> _analyticsFuture;

  int _navIndex = 1; // Reports / Analytics tab selected
  String _selectedSpreadDept = 'CS';
  String _selectedBatchYear = '2024';
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  void _loadAnalyticsData() {
    _analyticsFuture = _apiService.fetchDepartmentalAnalytics(
      selectedDept: _selectedSpreadDept,
      batchYear: _selectedBatchYear,
    );
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    setState(() {
      _loadAnalyticsData();
    });
    await _analyticsFuture;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/analytics/department'),
      appBar: _buildTopAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: FutureBuilder<DepartmentalAnalyticsDataModel>(
            future: _analyticsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final analytics = snapshot.data ?? DepartmentalAnalyticsDataModel.mockData;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar Toggle Section
                    if (_isSearchActive) ...[
                      _buildSearchBar(),
                      const SizedBox(height: 14),
                    ],

                    // 1. Header Title & Subtitle Section
                    _buildHeaderSection(),
                    const SizedBox(height: 14),

                    // 2. Top Metrics Cards (TOTAL STUDENTS & PLACEMENT RATE)
                    _buildTotalStudentsCard(context, analytics),
                    const SizedBox(height: 12),
                    _buildPlacementRateCard(context, analytics),
                    const SizedBox(height: 16),

                    // 3. Departmental Spread Horizontal Chips
                    _buildDepartmentalSpreadChips(context, analytics),
                    const SizedBox(height: 16),

                    // 4. Performance Index Radar Chart Card (Routes to Screen 8)
                    _buildPerformanceIndexCard(context, analytics),
                    const SizedBox(height: 16),

                    // 5. Batch Progress Timeline Stepper Card
                    _buildBatchProgressTimelineCard(context, analytics),
                    const SizedBox(height: 16),

                    // 6. Academic Performance Directory (Routes to Screen 8 & Screen 11)
                    _buildAcademicPerformanceSection(context, analytics),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() => _navIndex = index);
          _handleNavigation(index);
        },
        onFabPressed: () => _showQuickActionMenu(context),
      ),
    );
  }

  // --- Top App Bar ---
  PreferredSizeWidget _buildTopAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leadingWidth: 52,
      leading: Builder(
        builder: (scaffoldContext) {
          return IconButton(
            icon: const Icon(LucideIcons.menu, color: AppColors.textPrimary, size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
              Scaffold.of(scaffoldContext).openDrawer();
            },
          );
        },
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'c2c',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'C2C',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearchActive ? LucideIcons.x : LucideIcons.search,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() {
              _isSearchActive = !_isSearchActive;
              if (!_isSearchActive) _searchController.clear();
            });
          },
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(LucideIcons.bell, color: AppColors.textPrimary, size: 20),
              onPressed: () {
                HapticFeedback.lightImpact();
                context.go('/college/operations/communication');
              },
            ),
            Positioned(
              right: 10,
              top: 10,
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
        Padding(
          padding: const EdgeInsets.only(right: 14.0, left: 4.0),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/college/operations/config');
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                image: const DecorationImage(
                  image: AssetImage('assets/images/hero_student.webp'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Search Bar Component ---
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search departments, batches, or readiness metrics...',
          prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: (val) {
          setState(() {});
        },
      ),
    );
  }

  // --- 1. Header Title & Subtitle ---
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Departmental Analytics',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Real-time overview of academic performance and placement readiness.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // --- 2. Card 1: TOTAL STUDENTS ---
  Widget _buildTotalStudentsCard(
    BuildContext context,
    DepartmentalAnalyticsDataModel data,
  ) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.users, size: 18, color: AppColors.primary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data.studentsGrowthYoY,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const Text(
              'TOTAL STUDENTS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),

            AutoSizeText(
              _formatNumber(data.totalStudents),
              maxLines: 1,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Card 2: PLACEMENT RATE ---
  Widget _buildPlacementRateCard(
    BuildContext context,
    DepartmentalAnalyticsDataModel data,
  ) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.checkCircle2, size: 18, color: AppColors.primary),
            ),
            const SizedBox(height: 12),

            const Text(
              'PLACEMENT RATE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),

            AutoSizeText(
              '${data.placementRate}%',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: data.placementRate / 100.0,
                minHeight: 5,
                backgroundColor: AppColors.inputFill,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. Departmental Spread Chips ---
  Widget _buildDepartmentalSpreadChips(
    BuildContext context,
    DepartmentalAnalyticsDataModel data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DEPARTMENTAL SPREAD',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: data.departmentSpread.map((dept) {
              final isSelected = _selectedSpreadDept == dept;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(dept),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  onSelected: (val) {
                    if (val) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedSpreadDept = dept;
                        _loadAnalyticsData();
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- 4. Performance Index Radar Chart Card (Routes to Screen 8) ---
  Widget _buildPerformanceIndexCard(
    BuildContext context,
    DepartmentalAnalyticsDataModel data,
  ) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title & Subtitle Row with Route Trigger Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Performance Index',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Multi-metric comparison across departments.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // ROUTE TO SCREEN 8: Department Compare
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go('/college/analytics/compare');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Compare ➔',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Pentagonal Radar Chart Custom Painter
            Center(
              child: SizedBox(
                width: 220,
                height: 200,
                child: CustomPaint(
                  painter: _PentagonRadarChartPainter(
                    metrics: data.radarMetrics,
                    primaryColor: AppColors.primary,
                    accentColor: AppColors.primaryLight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Bottom Inset Stats Boxes (Top Dept & Avg Score)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top Dept',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.topDepartment,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Avg Score',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data.avgScore}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
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
      ),
    );
  }

  // --- 5. Batch Progress Timeline Stepper Card ---
  Widget _buildBatchProgressTimelineCard(
    BuildContext context,
    DepartmentalAnalyticsDataModel data,
  ) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row + Dropdown Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Batch Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Timeline for 2024 Final-year batches',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Batch Selector Dropdown Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBatchYear,
                      isDense: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textPrimary),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      items: ['2024', '2025', '2026'].map((year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text('Batch $year'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedBatchYear = val;
                            _loadAnalyticsData();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Stepper Timeline Items
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.batchProgressTimeline.length,
              itemBuilder: (context, index) {
                final item = data.batchProgressTimeline[index];
                final isLast = index == data.batchProgressTimeline.length - 1;
                return _buildTimelineStepItem(context, item, isLast);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStepItem(
    BuildContext context,
    BatchProgressTimelineItemModel item,
    bool isLast,
  ) {
    IconData iconData = LucideIcons.clipboardCheck;
    Color iconColor = AppColors.primary;
    Color iconBg = AppColors.primaryLight;

    if (item.iconType == 'code') {
      iconData = LucideIcons.code;
      iconColor = AppColors.accentViolet;
      iconBg = AppColors.aiBadgeBg;
    } else if (item.iconType == 'rocket') {
      iconData = LucideIcons.rocket;
      iconColor = AppColors.textMuted;
      iconBg = AppColors.inputFill;
    }

    Color badgeBg = AppColors.successLight;
    Color badgeTextColor = AppColors.success;

    if (item.statusBadge == 'IN PROGRESS') {
      badgeBg = AppColors.primaryLight;
      badgeTextColor = AppColors.primary;
    } else if (item.statusBadge == 'UPCOMING') {
      badgeBg = AppColors.inputFill;
      badgeTextColor = AppColors.textMuted;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Circle + Connecting Line
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(iconData, size: 18, color: iconColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.stageName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.statusBadge,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: badgeTextColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  if (item.progressValue > 0) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.progressValue,
                        minHeight: 4,
                        backgroundColor: AppColors.inputFill,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          item.statusBadge == 'COMPLETED' ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. Academic Performance Directory (Routes to Screen 8 & Screen 11) ---
  Widget _buildAcademicPerformanceSection(
    BuildContext context,
    DepartmentalAnalyticsDataModel data,
  ) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Academic Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.slidersHorizontal, size: 18, color: AppColors.textPrimary),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.go('/college/analytics/compare');
                      },
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.moreVertical, size: 18, color: AppColors.textPrimary),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        // Routes to Screen 11: Placement Intelligence
                        context.go('/college/analytics/intelligence');
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Table Header Labels
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'DEPARTMENT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'ENROLLED',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'AVG CGPA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 8),

            // Department Items List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.academicDepartments.length,
              separatorBuilder: (context, index) => const Divider(height: 16, color: AppColors.border),
              itemBuilder: (context, index) {
                final dept = data.academicDepartments[index];
                return _buildDepartmentRowItem(context, dept);
              },
            ),
            const SizedBox(height: 16),

            // Bottom Action Button: View all 12 departments ➔ (Routes to Screen 8)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // STRICT ROUTING REQUIREMENT: Routes to Screen 8 (Dept Compare: /college/analytics/compare)
                  context.go('/college/analytics/compare');
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View all 12 departments ➔',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentRowItem(
    BuildContext context,
    DepartmentAcademicPerformanceItemModel dept,
  ) {
    IconData icon = LucideIcons.code;
    if (dept.iconCategory == 'network') icon = LucideIcons.barChart3;
    if (dept.iconCategory == 'gear') icon = LucideIcons.settings;

    final isNegative = dept.cgpaTrend.startsWith('-');

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        // Route to Screen 8 (Dept Compare) or Screen 11 (Placement Intelligence)
        context.go('/college/analytics/compare');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            // Icon Square
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 10),

            // Name & Subtext
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dept.departmentName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dept.subtextBatches,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Enrolled Count
            Expanded(
              flex: 2,
              child: Text(
                '${dept.enrolledCount}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // Avg CGPA & Indicator Progress
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${dept.avgCgpa}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dept.cgpaTrend,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isNegative ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Mini Progress Indicator Line
                  SizedBox(
                    width: 45,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: dept.progressValue,
                        minHeight: 4,
                        backgroundColor: AppColors.inputFill,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isNegative ? AppColors.error : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Bottom Sheet Quick Action Menu ---
  void _showQuickActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
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
                  'Analytics Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(LucideIcons.gitCompare, color: AppColors.primary, size: 18),
                  ),
                  title: const Text('Department Comparison (Screen 8)'),
                  subtitle: const Text('Side-by-side branch readiness benchmarking'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/college/analytics/compare');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.aiBadgeBg,
                    child: Icon(LucideIcons.sparkles, color: AppColors.accentViolet, size: 18),
                  ),
                  title: const Text('Placement Intelligence (Screen 11)'),
                  subtitle: const Text('AI Predictive Placement insights & projections'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/college/analytics/intelligence');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Bottom Nav Router Handler ---
  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        context.go('/college/dashboard');
        break;
      case 1:
        // Already on Reports / Analytics
        break;
      case 3:
        context.go('/college/students');
        break;
      case 4:
        context.go('/college/operations/config');
        break;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      final str = number.toString();
      final length = str.length;
      final firstPart = str.substring(0, length - 3);
      final secondPart = str.substring(length - 3);
      return '$firstPart,$secondPart';
    }
    return number.toString();
  }
}

// --- Custom Painter for Pentagonal Radar Chart ---
class _PentagonRadarChartPainter extends CustomPainter {
  final Map<String, double> metrics;
  final Color primaryColor;
  final Color accentColor;

  _PentagonRadarChartPainter({
    required this.metrics,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.6;
    const numSides = 5;

    final outlinePaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final polygonPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    // Draw concentric pentagon grid rings (3 levels)
    for (int level = 1; level <= 3; level++) {
      final currentRadius = radius * (level / 3.0);
      final path = Path();
      for (int i = 0; i < numSides; i++) {
        final angle = (i * 2 * math.pi / numSides) - (math.pi / 2);
        final x = center.dx + currentRadius * math.cos(angle);
        final y = center.dy + currentRadius * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, outlinePaint);
    }

    // Draw radial lines from center to vertices
    for (int i = 0; i < numSides; i++) {
      final angle = (i * 2 * math.pi / numSides) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), outlinePaint);
    }

    // Plot metric data values
    final dataPath = Path();
    final keys = metrics.keys.toList();
    final values = metrics.values.toList();

    for (int i = 0; i < numSides; i++) {
      final val = i < values.length ? values[i] : 0.7;
      final currentRadius = radius * val.clamp(0.2, 1.0);
      final angle = (i * 2 * math.pi / numSides) - (math.pi / 2);
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);

      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    // Draw filled radar polygon and outline
    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, polygonPaint);

    // Draw vertex dots and text labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < numSides; i++) {
      final val = i < values.length ? values[i] : 0.7;
      final currentRadius = radius * val.clamp(0.2, 1.0);
      final angle = (i * 2 * math.pi / numSides) - (math.pi / 2);
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);

      // Vertex dot
      canvas.drawCircle(Offset(x, y), 3.5, pointPaint);

      // Metric label positioned slightly outside radius
      final labelAngle = angle;
      final labelRadius = radius + 18;
      final labelX = center.dx + labelRadius * math.cos(labelAngle);
      final labelY = center.dy + labelRadius * math.sin(labelAngle);

      final labelText = i < keys.length ? keys[i] : '';
      textPainter.text = TextSpan(
        text: labelText,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PentagonRadarChartPainter oldDelegate) {
    return oldDelegate.metrics != metrics;
  }
}
