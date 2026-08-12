import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../domain/models/placement_intelligence_model.dart';
import '../../data/services/placement_intelligence_api_service.dart';
import '../widgets/college_drawer.dart';

class PlacementIntelligencePage extends StatefulWidget {
  const PlacementIntelligencePage({super.key});

  @override
  State<PlacementIntelligencePage> createState() => _PlacementIntelligencePageState();
}

class _PlacementIntelligencePageState extends State<PlacementIntelligencePage> {
  final PlacementIntelligenceApiService _apiService = PlacementIntelligenceApiService();
  late Future<PlacementIntelligenceOverviewModel> _intelligenceFuture;

  int _navIndex = 1; // Reports / Analytics tab active
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadIntelligenceData();
  }

  void _loadIntelligenceData() {
    _intelligenceFuture = _apiService.fetchPlacementIntelligenceData();
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    setState(() {
      _loadIntelligenceData();
    });
    await _intelligenceFuture;
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
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/analytics/intelligence'),
      appBar: _buildTopAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: FutureBuilder<PlacementIntelligenceOverviewModel>(
            future: _intelligenceFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final data = snapshot.data ?? PlacementIntelligenceOverviewModel.mockData;

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

                    // 1. Live Forecast Badge & Headline Section
                    _buildHeaderSection(data),
                    const SizedBox(height: 16),

                    // 2. Card 1: EXPECTED PLACEMENT % (Forecast Card)
                    _buildExpectedPlacementCard(context, data),
                    const SizedBox(height: 16),

                    // 3. Card 2: COMPANY-WISE SELECTION Grid Card
                    _buildCompanyWiseSelectionCard(context, data.companySelections),
                    const SizedBox(height: 16),

                    // 4. Card 3: Talent Demand vs Supply Line Chart Card
                    _buildDemandVsSupplyCard(context, data.demandVsSupplyData),
                    const SizedBox(height: 16),

                    // 5. Card 4: Skill Alignment Matrix Card
                    _buildSkillAlignmentMatrixCard(context, data),
                    const SizedBox(height: 16),

                    // 6. Active Drives & Registered Row Cards
                    _buildActiveDrivesAndRegisteredRow(context, data),
                    const SizedBox(height: 16),

                    // 7. Card 5: UPCOMING PREP SESSION Card (Routes to Screen 12)
                    _buildUpcomingPrepSessionCard(context, data.upcomingPrepSession),
                    const SizedBox(height: 24),

                    // 8. Footer Links & Copyright
                    _buildFooterSection(),
                    const SizedBox(height: 16),
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
          hintText: 'Search placement predictions, company offers...',
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

  // --- 1. Live Forecast Badge & Headline Section ---
  Widget _buildHeaderSection(PlacementIntelligenceOverviewModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, size: 6, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'LIVE FORECAST',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '• ${data.batchTitle}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Placement Intelligence',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Leveraging neural networks to predict recruitment outcomes and strategic talent allocation.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // --- 2. Card 1: EXPECTED PLACEMENT % (Forecast Card) ---
  Widget _buildExpectedPlacementCard(
    BuildContext context,
    PlacementIntelligenceOverviewModel data,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'EXPECTED PLACEMENT %',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textMuted,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.trendingUp, size: 16, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 6),

            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  data.expectedPlacementPercentage,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data.growthPercentage,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            Text(
              data.confidenceIntervalText,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 18),

            // Bar Chart Visualization Trajectory
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.monthlyTrajectoryBars.map((val) {
                  return Container(
                    width: 38,
                    height: 50 * val,
                    decoration: BoxDecoration(
                      color: val > 0.6 ? AppColors.primary : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. Card 2: COMPANY-WISE SELECTION Grid Card ---
  Widget _buildCompanyWiseSelectionCard(
    BuildContext context,
    List<CompanySelectionItemModel> companies,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'COMPANY-WISE SELECTION',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textMuted,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'TOP 5',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 2x2 Grid of Companies
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        company.companyName,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        company.estimatedOffersSubtext,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            // Footer Link: Full breakdown ➔ (Routes to Screen 4)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.primaryLight,
                      child: const Text('G', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                    const SizedBox(width: 4),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.aiBadgeBg,
                      child: const Text('F', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.accentViolet)),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go('/college/drives');
                  },
                  child: const Text(
                    'Full breakdown ➔',
                    style: TextStyle(
                      fontSize: 11,
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
    );
  }

  // --- 4. Card 3: Talent Demand vs Supply Line Chart Card ---
  Widget _buildDemandVsSupplyCard(
    BuildContext context,
    List<DemandSupplyPointModel> points,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Talent Demand vs Supply',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Industry requirements vs Student specializations',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildLegendDot(AppColors.primary, 'Demand'),
                    const SizedBox(width: 8),
                    _buildLegendDot(AppColors.accentViolet, 'Supply'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Smooth Line Chart
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 140,
                child: CustomPaint(
                  painter: _DemandSupplyChartPainter(
                    points: points,
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

  // --- 5. Card 4: Skill Alignment Matrix Card ---
  Widget _buildSkillAlignmentMatrixCard(
    BuildContext context,
    PlacementIntelligenceOverviewModel data,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Skill Alignment Matrix',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'High-Drive Skills',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Skill Bars
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.skillAlignments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final skill = data.skillAlignments[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          skill.skillName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${skill.alignmentPercentage}% Align',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: skill.alignmentPercentage / 100.0,
                        minHeight: 5,
                        backgroundColor: AppColors.inputFill,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          index == 0 ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // AI Insight Quote Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.lightbulb, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.aiInsightQuote,
                      style: const TextStyle(
                        fontSize: 11,
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

  // --- 6. Active Drives & Registered Row Cards ---
  Widget _buildActiveDrivesAndRegisteredRow(
    BuildContext context,
    PlacementIntelligenceOverviewModel data,
  ) {
    return Row(
      children: [
        // Left Card: Vibrant Purple Card (ACTIVE DRIVES)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF818CF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.briefcase, size: 16, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  'ACTIVE DRIVES',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.activeDrivesCount}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Right Card: White Surface Card (REGISTERED)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.users, size: 16, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                const Text(
                  'REGISTERED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatNumber(data.registeredStudentsCount),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 7. Card 5: UPCOMING PREP SESSION Card (Routes to Screen 12) ---
  Widget _buildUpcomingPrepSessionCard(
    BuildContext context,
    PrepSessionModel session,
  ) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // STRICT ROUTING REQUIREMENT: Routes to Screen 12 (Assessments & Learning Analytics: /college/analytics/assessments)
          context.go('/college/analytics/assessments');
        },
        borderRadius: BorderRadius.circular(18),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'UPCOMING PREP SESSION',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.sessionTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.scheduleTimeSubtext,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.calendarCheck, size: 20, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 8. Footer Section ---
  Widget _buildFooterSection() {
    return Column(
      children: [
        const Center(
          child: Text(
            '© 2024 C2C. Verified Industry Partnership Network.',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Privacy Policy', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Text(' • ', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Text('Terms of Service', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Text(' • ', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Text('Support Center', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ],
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
                  'Placement Intelligence Actions',
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
                    child: Icon(LucideIcons.graduationCap, color: AppColors.primary, size: 18),
                  ),
                  title: const Text('Assessments & Learning (Screen 12)'),
                  subtitle: const Text('Go to practice modules and prep analytics'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/college/analytics/assessments');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.aiBadgeBg,
                    child: Icon(LucideIcons.barChart3, color: AppColors.accentViolet, size: 18),
                  ),
                  title: const Text('Back to Departmental Analytics (Screen 7)'),
                  subtitle: const Text('Return to main overview dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/college/analytics/department');
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
        // Already on Analytics / Reports
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

// --- Custom Painter for Demand vs Supply Line Chart ---
class _DemandSupplyChartPainter extends CustomPainter {
  final List<DemandSupplyPointModel> points;
  final Color primaryColor;
  final Color secondaryColor;

  _DemandSupplyChartPainter({
    required this.points,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final demandPath = Path();
    final supplyPath = Path();

    final stepX = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final x = i * stepX;
      final demandY = size.height - (pt.demandVal * (size.height - 20));
      final supplyY = size.height - (pt.supplyVal * (size.height - 20));

      if (i == 0) {
        demandPath.moveTo(x, demandY);
        supplyPath.moveTo(x, supplyY);
      } else {
        demandPath.lineTo(x, demandY);
        supplyPath.lineTo(x, supplyY);
      }
    }

    final demandStroke = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final supplyStroke = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawPath(demandPath, demandStroke);
    canvas.drawPath(supplyPath, supplyStroke);

    // Peak Tooltip Dot & Callout (at JAN 24 peak)
    if (points.length > 1) {
      final peakX = 1 * stepX;
      final peakY = size.height - (points[1].demandVal * (size.height - 20));

      // Dotted vertical line
      canvas.drawLine(
        Offset(peakX, peakY),
        Offset(peakX, size.height),
        gridPaint,
      );

      canvas.drawCircle(Offset(peakX, peakY), 4, Paint()..color = primaryColor);

      // Tooltip Box
      const tooltipText = '📍 AI/ML Peak Demand';
      final textPainter = TextPainter(
        text: const TextSpan(
          text: tooltipText,
          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(peakX, peakY - 16),
            width: textPainter.width + 12,
            height: 16,
          ),
          const Radius.circular(6),
        ),
        Paint()..color = AppColors.primaryLight,
      );

      textPainter.paint(
        canvas,
        Offset(peakX - textPainter.width / 2, peakY - 21),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DemandSupplyChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
