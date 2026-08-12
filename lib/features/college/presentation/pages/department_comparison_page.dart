import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../domain/models/department_comparison_model.dart';
import '../../data/services/department_comparison_api_service.dart';
import '../widgets/college_drawer.dart';

class DepartmentComparisonPage extends StatefulWidget {
  const DepartmentComparisonPage({super.key});

  @override
  State<DepartmentComparisonPage> createState() => _DepartmentComparisonPageState();
}

class _DepartmentComparisonPageState extends State<DepartmentComparisonPage> {
  final DepartmentComparisonApiService _apiService = DepartmentComparisonApiService();
  late Future<DepartmentComparisonDataModel> _comparisonFuture;

  int _navIndex = 1; // Reports / Analytics tab active
  final String _primaryDept = 'CS';
  final String _secondaryDept = 'MECH';
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComparisonData();
  }

  void _loadComparisonData() {
    _comparisonFuture = _apiService.fetchDepartmentComparison(
      primaryDept: _primaryDept,
      secondaryDept: _secondaryDept,
    );
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    setState(() {
      _loadComparisonData();
    });
    await _comparisonFuture;
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
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/analytics/compare'),
      appBar: _buildTopAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: FutureBuilder<DepartmentComparisonDataModel>(
            future: _comparisonFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final data = snapshot.data ?? DepartmentComparisonDataModel.mockData;

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

                    // 1. Top AI Insights Highlight Banner
                    _buildAiInsightsBanner(data),
                    const SizedBox(height: 14),

                    // 2. Headline & Subtitle Section
                    _buildHeaderSection(),
                    const SizedBox(height: 16),

                    // 3. Metric Comparison Radar Chart Card (Dual Overlay)
                    _buildMetricComparisonCard(context, data),
                    const SizedBox(height: 16),

                    // 4. Most Improved Department Spotlight Card
                    _buildMostImprovedDeptCard(context, data.mostImprovedDept),
                    const SizedBox(height: 16),

                    // 5. Department Rankings Table Card
                    _buildDepartmentRankingsCard(context, data.departmentRankings),
                    const SizedBox(height: 20),

                    // 6. Large Primary Action Button: New Placement Drive +
                    _buildNewPlacementDriveButton(context),
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
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary, size: 20),
        onPressed: () {
          HapticFeedback.lightImpact();
          // STRICT ROUTING REQUIREMENT: Routes back to Screen 7 (Departmental Analytics: /college/analytics/department)
          context.go('/college/analytics/department');
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
          hintText: 'Search department rankings or compare metrics...',
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

  // --- 1. Top AI Insights Banner ---
  Widget _buildAiInsightsBanner(DepartmentComparisonDataModel data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.sparkles, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.aiInsightBanner,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Headline & Subtitle Section ---
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Department Performance',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Cross-departmental benchmarking of readiness and success metrics.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // --- 3. Metric Comparison Radar Chart Card (Dual Overlay) ---
  Widget _buildMetricComparisonCard(
    BuildContext context,
    DepartmentComparisonDataModel data,
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
            const Text(
              'Metric Comparison',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${data.primaryDeptName} vs ${data.secondaryDeptName}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),

            // Legend Row
            Row(
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      data.primaryDeptName,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 1),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      data.secondaryDeptName,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Dual Pentagon Radar Chart Painter
            Center(
              child: SizedBox(
                width: 240,
                height: 210,
                child: CustomPaint(
                  painter: _DualRadarComparisonPainter(
                    primaryMetrics: data.primaryMetrics,
                    secondaryMetrics: data.secondaryMetrics,
                    primaryColor: AppColors.primary,
                    secondaryColor: AppColors.accentViolet,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. Most Improved Department Spotlight Card ---
  Widget _buildMostImprovedDeptCard(
    BuildContext context,
    MostImprovedDepartmentModel dept,
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
            // Top Row: Trending Icon + Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.trendingUp, size: 18, color: AppColors.primary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'MOST IMPROVED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Department Title
            Text(
              dept.departmentName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            // Inset Stats Row (GROWTH & READINESS)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GROWTH',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dept.growthRate,
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'READINESS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dept.readinessScore,
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
            const SizedBox(height: 14),

            // AI Reasoning Quote Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.sparkles, size: 14, color: AppColors.accentViolet),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dept.aiReasoningQuote,
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                        height: 1.4,
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

  // --- 5. Department Rankings Table Card ---
  Widget _buildDepartmentRankingsCard(
    BuildContext context,
    List<DepartmentRankingItemModel> rankings,
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
            // Header Row + Search Field
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Department Rankings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                Container(
                  width: 110,
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const TextField(
                    style: TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      prefixIconConstraints: BoxConstraints(minWidth: 16),
                      suffixIcon: Icon(LucideIcons.search, size: 12, color: AppColors.textMuted),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Table Header Column Labels
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      'RANK',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
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
                      'SALARY',
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
                      'ENG...',
                      textAlign: TextAlign.right,
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

            // Department Ranking Items List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rankings.length,
              separatorBuilder: (context, index) => const Divider(height: 16, color: AppColors.border),
              itemBuilder: (context, index) {
                final rankItem = rankings[index];
                return _buildRankingRowItem(context, rankItem);
              },
            ),
            const SizedBox(height: 14),

            // Footer Pagination Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Showing 3 of 10 departments',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(LucideIcons.chevronLeft, size: 14, color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(LucideIcons.chevronRight, size: 14, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingRowItem(
    BuildContext context,
    DepartmentRankingItemModel item,
  ) {
    IconData icon = LucideIcons.laptop;
    if (item.iconCategory == 'cpu') icon = LucideIcons.cpu;
    if (item.iconCategory == 'zap') icon = LucideIcons.zap;

    final isRank1 = item.rank == 1;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        // Route to Screen 11: Placement Intelligence
        context.go('/college/analytics/intelligence');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            // Rank Badge Number
            SizedBox(
              width: 32,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: isRank1 ? AppColors.primaryLight : AppColors.inputFill,
                child: Text(
                  '${item.rank}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isRank1 ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Icon Square
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 8),

            // Department Name & Student Subtext
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.departmentName,
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
                    item.studentCountSubtext,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Avg Salary Package
            Expanded(
              flex: 2,
              child: Text(
                item.avgSalary,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Engagement Indicator Bar
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 45,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: item.engagementPercentage / 100.0,
                      minHeight: 4,
                      backgroundColor: AppColors.inputFill,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 6. Large Primary Action Button: New Placement Drive + ---
  Widget _buildNewPlacementDriveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          // Routes to Screen 4 (Placement Hub)
          context.go('/college/drives');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Text(
          'New Placement Drive',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        label: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
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
                  'Department Comparison Actions',
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
                    child: Icon(LucideIcons.barChart3, color: AppColors.primary, size: 18),
                  ),
                  title: const Text('Back to Departmental Analytics (Screen 7)'),
                  subtitle: const Text('Return to main overview dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/college/analytics/department');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.aiBadgeBg,
                    child: Icon(LucideIcons.sparkles, color: AppColors.accentViolet, size: 18),
                  ),
                  title: const Text('Placement Intelligence (Screen 11)'),
                  subtitle: const Text('Predictive AI placement projections'),
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

  // --- Navigation Router Handler ---
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
}

// --- Custom Painter for Dual Pentagon Radar Comparison Chart ---
class _DualRadarComparisonPainter extends CustomPainter {
  final Map<String, double> primaryMetrics;
  final Map<String, double> secondaryMetrics;
  final Color primaryColor;
  final Color secondaryColor;

  _DualRadarComparisonPainter({
    required this.primaryMetrics,
    required this.secondaryMetrics,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.6;
    const numSides = 5;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Concentric pentagons
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
      canvas.drawPath(path, gridPaint);
    }

    // Radial axis lines
    for (int i = 0; i < numSides; i++) {
      final angle = (i * 2 * math.pi / numSides) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // 1. Primary Department Polygon (Solid Line & Soft Fill)
    final primaryPath = Path();
    final primaryValues = primaryMetrics.values.toList();
    final keys = primaryMetrics.keys.toList();

    for (int i = 0; i < numSides; i++) {
      final val = i < primaryValues.length ? primaryValues[i] : 0.8;
      final currentRadius = radius * val.clamp(0.2, 1.0);
      final angle = (i * 2 * math.pi / numSides) - (math.pi / 2);
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);
      if (i == 0) {
        primaryPath.moveTo(x, y);
      } else {
        primaryPath.lineTo(x, y);
      }
    }
    primaryPath.close();

    final primaryFillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;
    final primaryStrokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(primaryPath, primaryFillPaint);
    canvas.drawPath(primaryPath, primaryStrokePaint);

    // 2. Secondary Department Polygon (Lighter Accent Fill)
    final secondaryPath = Path();
    final secondaryValues = secondaryMetrics.values.toList();

    for (int i = 0; i < numSides; i++) {
      final val = i < secondaryValues.length ? secondaryValues[i] : 0.6;
      final currentRadius = radius * val.clamp(0.2, 1.0);
      final angle = (i * 2 * math.pi / numSides) - (math.pi / 2);
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);
      if (i == 0) {
        secondaryPath.moveTo(x, y);
      } else {
        secondaryPath.lineTo(x, y);
      }
    }
    secondaryPath.close();

    final secondaryFillPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final secondaryStrokePaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawPath(secondaryPath, secondaryFillPaint);
    canvas.drawPath(secondaryPath, secondaryStrokePaint);

    // Vertex dots & Axis Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < numSides; i++) {
      final angle = (i * 2 * math.pi / numSides) - (math.pi / 2);
      final labelRadius = radius + 20;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

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
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DualRadarComparisonPainter oldDelegate) {
    return oldDelegate.primaryMetrics != primaryMetrics ||
        oldDelegate.secondaryMetrics != secondaryMetrics;
  }
}
