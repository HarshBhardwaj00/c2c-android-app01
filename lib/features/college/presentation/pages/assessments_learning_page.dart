import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../domain/models/assessments_learning_model.dart';
import '../../data/services/assessments_learning_api_service.dart';
import '../widgets/college_drawer.dart';

class AssessmentsLearningPage extends StatefulWidget {
  const AssessmentsLearningPage({super.key});

  @override
  State<AssessmentsLearningPage> createState() => _AssessmentsLearningPageState();
}

class _AssessmentsLearningPageState extends State<AssessmentsLearningPage> {
  final AssessmentsLearningApiService _apiService = AssessmentsLearningApiService();
  late Future<AssessmentsLearningDataModel> _dataFuture;

  int _navIndex = 1;
  int _selectedCategoryIndex = 0;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dataFuture = _apiService.fetchAssessmentsData();
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    setState(() {
      _loadData();
    });
    await _dataFuture;
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
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/analytics/assessments'),
      appBar: _buildTopAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: FutureBuilder<AssessmentsLearningDataModel>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final data = snapshot.data ?? AssessmentsLearningDataModel.mockData;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isSearchActive) ...[
                      _buildSearchBar(),
                      const SizedBox(height: 14),
                    ],

                    _buildHeaderSection(),
                    const SizedBox(height: 14),

                    _buildActionButtons(context),
                    const SizedBox(height: 16),

                    _buildMetricCards(context, data),
                    const SizedBox(height: 16),

                    _buildAiInsightCard(context, data),
                    const SizedBox(height: 16),

                    _buildAssessmentLibrarySection(context, data),
                    const SizedBox(height: 16),

                    _buildReadinessGrowthCard(context, data),
                    const SizedBox(height: 16),

                    _buildLiveActivitySection(context, data),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search assessments, courses, labs...',
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
        onChanged: (val) => setState(() {}),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Assessments & Learning',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Track assessment performance, certification readiness, and certification readiness.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
            },
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const AutoSizeText(
              'Create Assessment',
              maxLines: 1,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
            },
            icon: const Icon(LucideIcons.download, size: 16),
            label: const AutoSizeText(
              'Export',
              maxLines: 1,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCards(BuildContext context, AssessmentsLearningDataModel data) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'AVG PASS RATE',
            value: '${data.avgPassRate}%',
            trend: data.passRateTrend,
            isPositiveTrend: data.passRateTrend.startsWith('+'),
            icon: LucideIcons.checkCircle2,
            iconBgColor: AppColors.successLight,
            iconColor: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: 'AVG ASSESSMENT SCORE',
            value: '${data.avgAssessmentScore}',
            trend: data.scoreTrend,
            isPositiveTrend: data.scoreTrend.startsWith('+'),
            icon: LucideIcons.barChart3,
            iconBgColor: AppColors.primaryLight,
            iconColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildAiInsightCard(BuildContext context, AssessmentsLearningDataModel data) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x334F46E5), blurRadius: 16, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.sparkles, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      const Text(
                        'AI ASSESSMENT INSIGHTS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              data.aiInsightTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.aiInsightDescription,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.award, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    data.aiInsightBadge,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildAssessmentLibrarySection(BuildContext context, AssessmentsLearningDataModel data) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: const [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Assessment Library',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'All Tests',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(data.categories.length, (index) {
                  final cat = data.categories[index];
                  final isSelected = _selectedCategoryIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat.label),
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
                          setState(() => _selectedCategoryIndex = index);
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.libraryItems.length,
              separatorBuilder: (context, index) => const Divider(height: 16, color: AppColors.border),
              itemBuilder: (context, index) {
                final item = data.libraryItems[index];
                return _buildLibraryItem(context, item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryItem(BuildContext context, AssessmentLibraryItem item) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(LucideIcons.fileText, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildReadinessGrowthCard(BuildContext context, AssessmentsLearningDataModel data) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: const [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Readiness Growth',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: CustomPaint(
                size: Size(double.infinity, 160),
                painter: _BarChartPainter(dataPoints: data.readinessGrowth),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: data.readinessGrowth.map((dp) {
                return Text(
                  dp.label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveActivitySection(BuildContext context, AssessmentsLearningDataModel data) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: const [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.liveActivities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = data.liveActivities[index];
                return _buildLiveActivityItem(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveActivityItem(LiveActivityItem item) {
    IconData iconData = LucideIcons.checkCircle2;
    Color iconColor = AppColors.success;

    if (item.iconType == 'sparkles') {
      iconData = LucideIcons.sparkles;
      iconColor = AppColors.accentViolet;
    } else if (item.iconType == 'user') {
      iconData = LucideIcons.user;
      iconColor = AppColors.primary;
    }

    return Row(
      children: [
        Icon(iconData, size: 16, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

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
                  'Assessment Quick Actions',
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
                    child: Icon(LucideIcons.plus, color: AppColors.primary, size: 18),
                  ),
                  title: const Text('Create New Assessment'),
                  subtitle: const Text('Design a new test or quiz'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.aiBadgeBg,
                    child: Icon(LucideIcons.sparkles, color: AppColors.accentViolet, size: 18),
                  ),
                  title: const Text('View Placement Intelligence'),
                  subtitle: const Text('AI Predictive Placement insights'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/college/analytics/intelligence');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.successLight,
                    child: Icon(LucideIcons.barChart3, color: AppColors.success, size: 18),
                  ),
                  title: const Text('Departmental Analytics'),
                  subtitle: const Text('Back to analytics overview (Screen 7)'),
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

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        context.go('/college/dashboard');
        break;
      case 1:
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isPositiveTrend;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.isPositiveTrend,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: const [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
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
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPositiveTrend ? AppColors.successLight : AppColors.errorLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isPositiveTrend ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            AutoSizeText(
              value,
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
}

class _BarChartPainter extends CustomPainter {
  final List<ReadinessGrowthDataPoint> dataPoints;

  _BarChartPainter({required this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final barPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final barWidth = (size.width / dataPoints.length) * 0.5;
    final spacing = size.width / dataPoints.length;
    final maxValue = dataPoints.map((e) => e.value).reduce(math.max);

    for (int i = 0; i < dataPoints.length; i++) {
      final barHeight = (dataPoints[i].value / maxValue) * (size.height * 0.85);
      final x = (spacing * i) + (spacing - barWidth) / 2;
      final y = size.height - barHeight;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(rrect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints;
  }
}
