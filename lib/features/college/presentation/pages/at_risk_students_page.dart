import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../domain/models/at_risk_students_model.dart';
import '../../data/services/at_risk_students_api_service.dart';
import '../widgets/college_drawer.dart';

class AtRiskStudentsPage extends StatefulWidget {
  const AtRiskStudentsPage({super.key});

  @override
  State<AtRiskStudentsPage> createState() => _AtRiskStudentsPageState();
}

class _AtRiskStudentsPageState extends State<AtRiskStudentsPage> {
  final AtRiskStudentsApiService _apiService = AtRiskStudentsApiService();
  late Future<AtRiskStudentsOverviewModel> _atRiskFuture;

  int _navIndex = 3; // Students tab active
  String _selectedRiskFilter = 'All'; // All, High, Moderate
  bool _isSearchActive = false;
  bool _isActionInProgress = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAtRiskData();
  }

  void _loadAtRiskData() {
    _atRiskFuture = _apiService.fetchAtRiskStudentsData(riskFilter: _selectedRiskFilter);
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    setState(() {
      _loadAtRiskData();
    });
    await _atRiskFuture;
  }

  Future<void> _handleAssignMentor(String studentId) async {
    if (_isActionInProgress) return;
    HapticFeedback.lightImpact();
    setState(() => _isActionInProgress = true);

    final success = await _apiService.assignMentor(
      studentId: studentId,
      mentorName: 'Prof. Rajesh Kumar',
    );

    if (mounted) {
      setState(() => _isActionInProgress = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Mentor assigned to student successfully!'
                : 'Failed to assign mentor.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _handleNotifyEmail(String studentId) async {
    if (_isActionInProgress) return;
    HapticFeedback.lightImpact();
    setState(() => _isActionInProgress = true);

    final success = await _apiService.notifyStudentViaEmail(studentId);

    if (mounted) {
      setState(() => _isActionInProgress = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Intervention email sent to student.'
                : 'Failed to send email.',
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
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/students/at-risk'),
      appBar: _buildTopAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: FutureBuilder<AtRiskStudentsOverviewModel>(
            future: _atRiskFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final data = snapshot.data ?? AtRiskStudentsOverviewModel.mockData;

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
                    _buildHeaderSection(data),
                    const SizedBox(height: 14),

                    // 2. Action Buttons Row (Export Report & Bulk Intervention)
                    _buildActionButtonsRow(context),
                    const SizedBox(height: 16),

                    // 3. Metrics Cards Horizontal Scrollable Row
                    _buildMetricsCardsRow(context, data),
                    const SizedBox(height: 16),

                    // 4. At-Risk Students List Card (Routes to Screen 3)
                    _buildAtRiskStudentsListCard(context, data.atRiskStudents),
                    const SizedBox(height: 16),

                    // 5. AI Intervention Plan Card
                    _buildAiInterventionPlanCard(context, data.featuredInterventionPlan),
                    const SizedBox(height: 16),

                    // 6. Risk Mitigation Stepper Card
                    _buildRiskMitigationStepperCard(context, data.activeMitigationStage),
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
          hintText: 'Search at-risk students by name or department...',
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
  Widget _buildHeaderSection(AtRiskStudentsOverviewModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Students At Risk',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 10),
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
                    'AI INSIGHTS ACTIVE',
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
          ],
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'Plus Jakarta Sans',
              height: 1.4,
            ),
            children: [
              const TextSpan(text: 'Real-time predictive analysis identifying '),
              TextSpan(
                text: '${data.totalAtRiskCount} students',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: ' with high probability of placement failure.'),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. Action Buttons Row (Export Report & Bulk Intervention) ---
  Widget _buildActionButtonsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Downloading At-Risk Student Report PDF...'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.border, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(LucideIcons.download, size: 16, color: AppColors.textPrimary),
            label: const Text(
              'Export Report',
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
                  content: Text('Initiating Bulk Intervention for 42 At-Risk Students...'),
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
            icon: const Icon(LucideIcons.zap, size: 16, color: Colors.white),
            label: const AutoSizeText(
              'Bulk Intervention',
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

  // --- 3. Metrics Cards Horizontal Scrollable Row ---
  Widget _buildMetricsCardsRow(
    BuildContext context,
    AtRiskStudentsOverviewModel data,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Card 1: TOTAL HIGH RISK
          _buildMetricCard(
            title: 'TOTAL HIGH RISK',
            valueText: '${data.highRiskCount}',
            badgeText: data.highRiskGrowth,
            badgeColor: AppColors.errorLight,
            badgeTextColor: AppColors.error,
            barColor: AppColors.error,
            progress: 0.75,
          ),
          const SizedBox(width: 10),

          // Card 2: MODERATE RISK
          _buildMetricCard(
            title: 'MODERATE RISK',
            valueText: '${data.moderateRiskCount}',
            badgeText: data.moderateRiskGrowth,
            badgeColor: AppColors.successLight,
            badgeTextColor: AppColors.success,
            barColor: const Color(0xFFF59E0B),
            progress: 0.50,
          ),
          const SizedBox(width: 10),

          // Card 3: INTERVENTION RATE
          _buildMetricCard(
            title: 'INTERVENTION RATE',
            valueText: '${data.interventionRatePercentage}%',
            barColor: AppColors.primary,
            progress: data.interventionRatePercentage / 100.0,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String valueText,
    String? badgeText,
    Color? badgeColor,
    Color? badgeTextColor,
    required Color barColor,
    required double progress,
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
              valueText,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppColors.inputFill,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. At-Risk Students List Card (Routes to Screen 3) ---
  Widget _buildAtRiskStudentsListCard(
    BuildContext context,
    List<AtRiskStudentItemModel> students,
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
            // Header Row + Filter Segmented Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'At-Risk Students',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                // Filter Pill Selector (All, High, Moderate)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: ['All', 'High', 'Moderate'].map((filter) {
                      final isSelected = _selectedRiskFilter == filter;
                      return InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedRiskFilter = filter;
                            _loadAtRiskData();
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected
                                ? const [BoxShadow(color: AppColors.cardShadow, blurRadius: 4)]
                                : null,
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textMuted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Student Items List -> Tapping routes to Screen 3 (Student Profile)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final student = students[index];
                return _buildStudentItemRow(context, student);
              },
            ),
            const SizedBox(height: 14),

            // Bottom Link Button: View All 42 At-Risk Students ➔ (Routes to Screen 2)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.go('/college/students');
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'View All 42 At-Risk Students ➔',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentItemRow(
    BuildContext context,
    AtRiskStudentItemModel student,
  ) {
    final isHighRisk = student.riskLevel == 'HIGH RISK';

    Color avatarBg = AppColors.primaryLight;
    Color avatarText = AppColors.primary;

    if (student.avatarBgType == 'blue') {
      avatarBg = const Color(0xFFDBEAFE);
      avatarText = const Color(0xFF1D4ED8);
    } else if (student.avatarBgType == 'amber') {
      avatarBg = AppColors.warningLight;
      avatarText = AppColors.warning;
    }

    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // STRICT ROUTING REQUIREMENT: Routes to Screen 3 (Student Profile & AI Resume: /college/students/:id)
          context.go('/college/students/${student.id}');
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.inputFill.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              // Avatar Circle with Hero Transition
              Hero(
                tag: 'student-avatar-${student.id}',
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: avatarBg,
                  child: Text(
                    student.initials,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: avatarText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name & Subtext
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student.departmentYearSubtext,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Risk Badge Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isHighRisk ? AppColors.errorLight : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  student.riskLevel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: isHighRisk ? AppColors.error : AppColors.warning,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Action Trigger Button
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/college/students/${student.id}');
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.zap, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 5. AI Intervention Plan Card ---
  Widget _buildAiInterventionPlanCard(
    BuildContext context,
    AiInterventionPlanModel plan,
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.droplets, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Text(
                  'AI Intervention Plan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Inner Plan Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RECOMMENDED FOR ${plan.studentName}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plan.failurePredictionReason,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Option 1: Assign Mentor
                  InkWell(
                    onTap: _isActionInProgress ? null : () => _handleAssignMentor('s1'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.userCheck, size: 14, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Assign Mentor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ],
                          ),
                          Icon(LucideIcons.chevronRight, size: 14, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Option 2: Notify via Email
                  InkWell(
                    onTap: _isActionInProgress ? null : () => _handleNotifyEmail('s1'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.mail, size: 14, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Notify via Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ],
                          ),
                          Icon(LucideIcons.chevronRight, size: 14, color: AppColors.textMuted),
                        ],
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

  // --- 6. Risk Mitigation Stepper Card ---
  Widget _buildRiskMitigationStepperCard(BuildContext context, int activeStage) {
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
                  'Risk Mitigation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ON TRACK',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stepper Line with 4 Stages
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepperStageCircle(
                  stageNumber: 1,
                  stageLabel: 'STAGE 1\nIdentify',
                  icon: LucideIcons.search,
                  isActive: activeStage >= 1,
                ),
                _buildStepperLine(isActive: activeStage >= 2),
                _buildStepperStageCircle(
                  stageNumber: 2,
                  stageLabel: 'STAGE 2\nNotify',
                  icon: LucideIcons.bell,
                  isActive: activeStage >= 2,
                ),
                _buildStepperLine(isActive: activeStage >= 3),
                _buildStepperStageCircle(
                  stageNumber: 3,
                  stageLabel: 'STAGE 3\nMentoring',
                  icon: LucideIcons.userCheck,
                  isActive: activeStage >= 3,
                ),
                _buildStepperLine(isActive: activeStage >= 4),
                _buildStepperStageCircle(
                  stageNumber: 4,
                  stageLabel: 'STAGE 4\nReady',
                  icon: LucideIcons.checkCircle2,
                  isActive: activeStage >= 4,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperStageCircle({
    required int stageNumber,
    required String stageLabel,
    required IconData icon,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.inputFill,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 16,
            color: isActive ? Colors.white : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          stageLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textMuted,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStepperLine({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? AppColors.primary : AppColors.border,
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
                  'At-Risk Monitoring Actions',
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
                    child: Icon(LucideIcons.user, color: AppColors.accentViolet, size: 18),
                  ),
                  title: const Text('Student Profile (Screen 3)'),
                  subtitle: const Text('Inspect candidate resume and skill scores'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/college/students/s1');
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
        context.go('/college/analytics/department');
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
