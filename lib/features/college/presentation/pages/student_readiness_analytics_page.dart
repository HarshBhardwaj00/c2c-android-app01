import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../domain/models/student_readiness_model.dart';
import '../../data/services/student_readiness_api_service.dart';
import '../widgets/college_drawer.dart';

class StudentReadinessAnalyticsPage extends StatefulWidget {
  const StudentReadinessAnalyticsPage({super.key});

  @override
  State<StudentReadinessAnalyticsPage> createState() => _StudentReadinessAnalyticsPageState();
}

class _StudentReadinessAnalyticsPageState extends State<StudentReadinessAnalyticsPage> {
  final StudentReadinessApiService _apiService = StudentReadinessApiService();
  late Future<StudentReadinessDataModel> _readinessFuture;

  int _navIndex = 1; // Reports / Analytics tab selected
  bool _isSearchActive = false;
  bool _isAssigning = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReadinessData();
  }

  void _loadReadinessData() {
    _readinessFuture = _apiService.fetchReadinessAnalytics();
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    setState(() {
      _loadReadinessData();
    });
    await _readinessFuture;
  }

  Future<void> _handleAssignModule(String moduleId, String title) async {
    if (_isAssigning) return;
    HapticFeedback.lightImpact();
    setState(() => _isAssigning = true);

    final success = await _apiService.assignLearningModule(moduleId);

    if (mounted) {
      setState(() => _isAssigning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Module "$title" assigned to batch successfully!'
                : 'Failed to assign module.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
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
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/analytics/readiness'),
      appBar: _buildTopAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: FutureBuilder<StudentReadinessDataModel>(
            future: _readinessFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final data = snapshot.data ?? StudentReadinessDataModel.mockData;

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

                    // 1. Headline & Subtitle Section
                    _buildHeaderSection(),
                    const SizedBox(height: 14),

                    // 2. Action Buttons Row (Filters & Generate Report)
                    _buildActionButtonsRow(context),
                    const SizedBox(height: 16),

                    // 3. Metrics Cards Horizontal Scrollable Row (Avg Readiness, Eligible, High Risk -> Screen 10)
                    _buildMetricsCardsRow(context, data),
                    const SizedBox(height: 16),

                    // 4. Department Heatmap Card
                    _buildDepartmentHeatmapCard(context, data.departmentHeatmap),
                    const SizedBox(height: 16),

                    // 5. Readiness Radar (AVG) Card
                    _buildReadinessRadarCard(context, data),
                    const SizedBox(height: 16),

                    // 6. Placement Probability Card
                    _buildPlacementProbabilityCard(context, data),
                    const SizedBox(height: 16),

                    // 7. Skill-Gap Analysis Card (Routes to Screen 10)
                    _buildSkillGapAnalysisCard(context, data),
                    const SizedBox(height: 16),

                    // 8. Recommended Learning Cards (Routes to Screen 12)
                    _buildRecommendedLearningSection(context, data.recommendedModules),
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
          hintText: 'Search readiness scores, skill gaps, or modules...',
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

  // --- 1. Headline & Subtitle Section ---
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Student Readiness Analytics',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'AI-generated insights for 2024 batch.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // --- 2. Action Buttons Row (Filters & Generate Report) ---
  Widget _buildActionButtonsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showFiltersBottomSheet(context);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.border, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(LucideIcons.slidersHorizontal, size: 16, color: AppColors.textPrimary),
            label: const Text(
              'Filters',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Generating AI Readiness PDF Report...'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
            label: const AutoSizeText(
              'Generate Report',
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. Metrics Cards Horizontal Scrollable Row (Routes to Screen 10) ---
  Widget _buildMetricsCardsRow(
    BuildContext context,
    StudentReadinessDataModel data,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Card 1: AVG READINESS
          _buildMetricBox(
            title: 'AVG. READINESS',
            mainVal: '${data.avgReadinessPercentage}%',
            badgeText: data.readinessGrowthYoY,
            badgeColor: AppColors.successLight,
            badgeTextColor: AppColors.success,
            icon: LucideIcons.trendingUp,
          ),
          const SizedBox(width: 10),

          // Card 2: PLACEMENT ELIGIBLE
          _buildMetricBox(
            title: 'PLACEMENT ELIGIBLE',
            mainVal: _formatNumber(data.eligibleStudentsCount),
            subtext: 'of ${_formatNumber(data.totalStudentsCount)}',
            icon: LucideIcons.userCheck,
          ),
          const SizedBox(width: 10),

          // Card 3: HIGH RISK / ACTION REQUIRED -> ROUTE TO SCREEN 10 (At-Risk Students)
          RepaintBoundary(
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                // STRICT ROUTING REQUIREMENT: Routes to Screen 10 (At-Risk Students: /college/students/at-risk)
                context.go('/college/students/at-risk');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.errorLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'HIGH RISK',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.error,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ACTION',
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${data.highRiskStudentsCount}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Screen 10 ➔',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String mainVal,
    String? badgeText,
    Color? badgeColor,
    Color? badgeTextColor,
    String? subtext,
    IconData? icon,
  }) {
    return RepaintBoundary(
      child: Container(
        width: 145,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 6,
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
                Expanded(
                  child: AutoSizeText(
                    title,
                    maxLines: 1,
                    minFontSize: 7,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor ?? AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            AutoSizeText(
              mainVal,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtext != null) ...[
              const SizedBox(height: 2),
              Text(
                subtext,
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- 4. Department Heatmap Card ---
  Widget _buildDepartmentHeatmapCard(
    BuildContext context,
    List<DepartmentHeatmapRowModel> heatmapRows,
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
            // Header Row + Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Department Heatmap',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Aggregated performance across verticals',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    _buildLegendDot(AppColors.primary, '80%+'),
                    const SizedBox(width: 8),
                    _buildLegendDot(AppColors.primaryLight, '70-80%'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Heatmap Table Grid
            Column(
              children: [
                // Header Row
                const Row(
                  children: [
                    SizedBox(width: 50, child: Text('DEPT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                    Expanded(child: Center(child: Text('DSA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)))),
                    Expanded(child: Center(child: Text('CLOUD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)))),
                    Expanded(child: Center(child: Text('SYSTEM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)))),
                    Expanded(child: Center(child: Text('QUANT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)))),
                    Expanded(child: Center(child: Text('PROJ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)))),
                  ],
                ),
                const SizedBox(height: 8),

                // Heatmap Data Rows
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: heatmapRows.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final row = heatmapRows[index];
                    return Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            row.departmentCode,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ),
                        Expanded(child: _buildHeatmapCell('${row.dsaScore}%', row.dsaScore)),
                        const SizedBox(width: 4),
                        Expanded(child: _buildHeatmapCell('${row.cloudScore}%', row.cloudScore)),
                        const SizedBox(width: 4),
                        Expanded(child: _buildHeatmapCell('${row.systemScore}%', row.systemScore)),
                        const SizedBox(width: 4),
                        Expanded(child: _buildHeatmapCell('${row.quantScore}%', row.quantScore)),
                        const SizedBox(width: 4),
                        Expanded(child: _buildHeatmapCell('${row.projScore}%', row.projScore)),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHeatmapCell(String text, int score) {
    Color bg = AppColors.primary;
    Color textColor = Colors.white;

    if (score < 70) {
      bg = const Color(0xFF93C5FD); // Soft Blue
      textColor = const Color(0xFF1E3A8A);
    } else if (score < 85) {
      bg = const Color(0xFFC7D2FE); // Soft Purple Light
      textColor = const Color(0xFF3730A3);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }

  // --- 5. Readiness Radar (AVG) Card ---
  Widget _buildReadinessRadarCard(
    BuildContext context,
    StudentReadinessDataModel data,
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
            const Center(
              child: Text(
                'READINESS RADAR (AVG)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Radar Chart Painter
            Center(
              child: SizedBox(
                width: 220,
                height: 190,
                child: CustomPaint(
                  painter: _ReadinessRadarPainter(
                    metrics: data.radarMetrics,
                    primaryColor: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Technical Depth & Soft Skills Sub-bars
            _buildSubProgressBar('Technical Depth', data.technicalDepthScore, 0.88),
            const SizedBox(height: 10),
            _buildSubProgressBar('Soft Skills Growth', data.softSkillsScore, 0.92),
          ],
        ),
      ),
    );
  }

  Widget _buildSubProgressBar(String label, String valueText, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            Text(
              valueText,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: AppColors.inputFill,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  // --- 6. Placement Probability Card ---
  Widget _buildPlacementProbabilityCard(
    BuildContext context,
    StudentReadinessDataModel data,
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
            Row(
              children: const [
                Icon(LucideIcons.barChart2, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Placement Probability',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Stat Box 1: TIER 1 (DREAM)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TIER 1 (DREAM)',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.tier1Probability,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      data.tier1Growth,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Stat Box 2: TIER 2 (MASS+SUPER)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TIER 2 (MASS+SUPER)',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.tier2Probability,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Stable Projection',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
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

  // --- 7. Skill-Gap Analysis Card (Routes to Screen 10) ---
  Widget _buildSkillGapAnalysisCard(
    BuildContext context,
    StudentReadinessDataModel data,
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
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.aiBadgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.sparkles, size: 16, color: AppColors.accentViolet),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Skill-Gap Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'AI REVIEW',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Main AI Insight Quote Text
            Text(
              data.skillGapMainInsight,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            // Alerts List -> Tapping routes to Screen 10 (At-Risk Students)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.skillGapAlerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final alert = data.skillGapAlerts[index];
                final isCritical = alert.severity == 'CRITICAL';

                return InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // STRICT ROUTING REQUIREMENT: Routes to Screen 10 (At-Risk Students: /college/students/at-risk)
                    context.go('/college/students/at-risk');
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCritical
                          ? AppColors.errorLight.withValues(alpha: 0.3)
                          : AppColors.warningLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCritical
                            ? AppColors.error.withValues(alpha: 0.3)
                            : AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCritical ? LucideIcons.alertTriangle : LucideIcons.alertCircle,
                          size: 16,
                          color: isCritical ? AppColors.error : AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alert.message,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCritical ? AppColors.error : AppColors.warning,
                            ),
                          ),
                        ),
                        const Icon(LucideIcons.chevronRight, size: 14, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- 8. Recommended Learning Cards (Routes to Screen 12) ---
  Widget _buildRecommendedLearningSection(
    BuildContext context,
    List<RecommendedLearningModuleModel> modules,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row -> View all routes to Screen 12 (Assessments & Learning Analytics)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recommended Learning',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                // STRICT ROUTING REQUIREMENT: Routes to Screen 12 (Assessments & Learning: /college/analytics/assessments)
                context.go('/college/analytics/assessments');
              },
              child: const Text(
                'View all',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Learning Module Cards List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final module = modules[index];
            return _buildLearningModuleCard(context, module);
          },
        ),
      ],
    );
  }

  Widget _buildLearningModuleCard(
    BuildContext context,
    RecommendedLearningModuleModel module,
  ) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16),
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
            // Top Row: Category Tag & Badge Text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    module.categoryTag,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Text(
                  module.badgeText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title & Description
            Text(
              module.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              module.description,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),

            // Footer Row: Avatar Avatars & Assign Now Button (Routes to Screen 12)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: AssetImage('assets/images/hero_student.webp'),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+24',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                    ),
                  ],
                ),

                // Assign Now Button -> Triggers API & Routes to Screen 12
                InkWell(
                  onTap: _isAssigning ? null : () => _handleAssignModule(module.id, module.title),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _isAssigning ? 'Assigning...' : 'Assign Now ➔',
                          style: const TextStyle(
                            fontSize: 11,
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
          ],
        ),
      ),
    );
  }

  // --- Filter Options Bottom Sheet ---
  void _showFiltersBottomSheet(BuildContext context) {
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
                  'Filter Student Readiness',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('2024 Batch'),
                      selected: true,
                      onSelected: (val) {},
                      selectedColor: AppColors.primaryLight,
                      labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    FilterChip(
                      label: const Text('2025 Batch'),
                      selected: false,
                      onSelected: (val) {},
                    ),
                    FilterChip(
                      label: const Text('High Risk Only'),
                      selected: false,
                      onSelected: (val) {
                        Navigator.pop(context);
                        context.go('/college/students/at-risk');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Apply Readiness Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                  'Readiness Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.errorLight,
                    child: Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 18),
                  ),
                  title: const Text('At-Risk Students List (Screen 10)'),
                  subtitle: const Text('View 142 students requiring immediate intervention'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/college/students/at-risk');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(LucideIcons.graduationCap, color: AppColors.primary, size: 18),
                  ),
                  title: const Text('Assessments & Learning (Screen 12)'),
                  subtitle: const Text('Assign modules and track learning analytics'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/college/analytics/assessments');
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

// --- Custom Painter for Pentagonal Readiness Radar Chart ---
class _ReadinessRadarPainter extends CustomPainter {
  final Map<String, double> metrics;
  final Color primaryColor;

  _ReadinessRadarPainter({
    required this.metrics,
    required this.primaryColor,
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

    final fillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    // Grid rings (3 concentric pentagons)
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

    // Radial lines
    for (int i = 0; i < numSides; i++) {
      final angle = (i * 2 * math.pi / numSides) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // Metric Values Polygon
    final dataPath = Path();
    final keys = metrics.keys.toList();
    final values = metrics.values.toList();

    for (int i = 0; i < numSides; i++) {
      final val = i < values.length ? values[i] : 0.8;
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

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    // Vertex dots & Axis Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < numSides; i++) {
      final val = i < values.length ? values[i] : 0.8;
      final currentRadius = radius * val.clamp(0.2, 1.0);
      final angle = (i * 2 * math.pi / numSides) - (math.pi / 2);
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);

      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);

      final labelRadius = radius + 18;
      final labelX = center.dx + labelRadius * math.cos(angle);
      final labelY = center.dy + labelRadius * math.sin(angle);

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
  bool shouldRepaint(covariant _ReadinessRadarPainter oldDelegate) {
    return oldDelegate.metrics != metrics;
  }
}
