import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../domain/models/job_pipeline_model.dart';
import '../../data/services/job_pipeline_api_service.dart';
import '../widgets/college_drawer.dart';

class JobPipelinePage extends StatefulWidget {
  final String driveId;

  const JobPipelinePage({
    super.key,
    required this.driveId,
  });

  @override
  State<JobPipelinePage> createState() => _JobPipelinePageState();
}

class _JobPipelinePageState extends State<JobPipelinePage> {
  final JobPipelineApiService _apiService = JobPipelineApiService();
  late Future<JobPipelineOverviewModel> _pipelineFuture;

  int _navIndex = 1; // Reports / Pipeline tab active
  AiCandidateMatchModel? _currentMatchCandidate;
  bool _isGeneratingMatch = false;
  bool _isShortlisting = false;
  bool _isShortlisted = false;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPipelineData();
  }

  void _loadPipelineData() {
    _pipelineFuture = _apiService.fetchPipelineOverview(widget.driveId);
    _pipelineFuture.then((data) {
      if (mounted) {
        setState(() {
          _currentMatchCandidate = data.topMatchCandidate;
          _isShortlisted = data.topMatchCandidate.isShortlisted;
        });
      }
    });
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    setState(() {
      _loadPipelineData();
    });
    await _pipelineFuture;
  }

  Future<void> _handleShortlistCandidate() async {
    if (_currentMatchCandidate == null || _isShortlisting) return;
    HapticFeedback.mediumImpact();
    setState(() => _isShortlisting = true);

    final success = await _apiService.shortlistCandidate(
      driveId: widget.driveId,
      candidateId: _currentMatchCandidate!.candidateId,
    );

    if (mounted) {
      setState(() {
        _isShortlisting = false;
        _isShortlisted = success ? !_isShortlisted : _isShortlisted;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isShortlisted
                ? 'Candidate ${_currentMatchCandidate!.name} shortlisted successfully!'
                : 'Candidate removed from shortlist.',
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleGenerateMoreMatches() async {
    if (_isGeneratingMatch) return;
    HapticFeedback.lightImpact();
    setState(() => _isGeneratingMatch = true);

    final newCandidate = await _apiService.generateMoreMatches(widget.driveId);

    if (mounted) {
      setState(() {
        _isGeneratingMatch = false;
        _currentMatchCandidate = newCandidate;
        _isShortlisted = newCandidate.isShortlisted;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generated new AI candidate match: ${newCandidate.name}'),
          backgroundColor: AppColors.accentViolet,
          duration: const Duration(seconds: 2),
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
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/drives'),
      appBar: _buildTopAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: FutureBuilder<JobPipelineOverviewModel>(
            future: _pipelineFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  _currentMatchCandidate == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final pipelineData = snapshot.data ?? JobPipelineOverviewModel.mockData;

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

                    // 1. Metrics Overview Section (Card 1 + Row of 2 Cards)
                    _buildTotalApplicationsCard(context, pipelineData, screenWidth),
                    const SizedBox(height: 12),
                    _buildMetricsRowCards(context, pipelineData),
                    const SizedBox(height: 16),

                    // 2. Pipeline Stages Live Tracking Card
                    _buildPipelineStagesCard(context, pipelineData),
                    const SizedBox(height: 16),

                    // 3. AI Candidate Matching Card
                    _buildAiCandidateMatchingCard(context, screenWidth),
                    const SizedBox(height: 20),

                    // 4. Recent Job Performance Section
                    _buildRecentJobPerformanceSection(context, pipelineData),
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
          // C2C Brand Badge
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
          const Expanded(
            child: Text(
              'Pipeline',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Search Button
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

        // Notification Bell Icon with Red Dot Badge
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

        // User Avatar Circle -> Routes to Config/Profile
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
          hintText: 'Search pipeline candidates, roles, or drives...',
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

  // --- Card 1: Total Applications Card ---
  Widget _buildTotalApplicationsCard(
    BuildContext context,
    JobPipelineOverviewModel data,
    double screenWidth,
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Label
                const Text(
                  'TOTAL APPLICATIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),

                // Main Value Number
                AutoSizeText(
                  _formatNumber(data.totalApplications),
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),

                // Growth Pill Indicator
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.trendingUp,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.applicationsGrowth,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Top Right Elevated Arrow Icon Badge
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.arrowUpRight,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Row of 2 Cards: Conv. Rate & Active Drives ---
  Widget _buildMetricsRowCards(BuildContext context, JobPipelineOverviewModel data) {
    return Row(
      children: [
        // Left Card: CONV. RATE
        Expanded(
          child: RepaintBoundary(
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
                  const Text(
                    'CONV. RATE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AutoSizeText(
                    data.conversionRate,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.avgConversionRate,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Right Card: ACTIVE DRIVES
        Expanded(
          child: RepaintBoundary(
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
                  const Text(
                    'ACTIVE DRIVES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AutoSizeText(
                    '${data.activeDrives}',
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data.drivesClosingSoon} closing soon',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentViolet,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Pipeline Stages Card ---
  Widget _buildPipelineStagesCard(BuildContext context, JobPipelineOverviewModel data) {
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
            // Header + Live Tracking Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pipeline Stages',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIVE TRACKING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4 Stages Grid / Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stage 1: APPLIED
                Expanded(
                  child: _buildStageItem(
                    icon: LucideIcons.fileText,
                    iconColor: const Color(0xFF3B82F6),
                    iconBgColor: const Color(0xFFEFF6FF),
                    count: _formatNumber(data.appliedCount),
                    label: 'APPLIED',
                  ),
                ),

                // Stage 2: SHORTLISTED
                Expanded(
                  child: _buildStageItem(
                    icon: LucideIcons.clipboardCheck,
                    iconColor: const Color(0xFFC084FC),
                    iconBgColor: const Color(0xFFFAF5FF),
                    count: _formatNumber(data.shortlistedCount),
                    label: 'SHORTLISTED',
                  ),
                ),

                // Stage 3: INTERVIEWED
                Expanded(
                  child: _buildStageItem(
                    icon: LucideIcons.messageSquare,
                    iconColor: const Color(0xFF06B6D4),
                    iconBgColor: const Color(0xFFECFEFF),
                    count: _formatNumber(data.interviewedCount),
                    label: 'INTERVIEWED',
                  ),
                ),

                // Stage 4: PLACED (Filled Purple Icon)
                Expanded(
                  child: _buildStageItem(
                    icon: LucideIcons.triangle,
                    iconColor: Colors.white,
                    iconBgColor: AppColors.primary,
                    count: _formatNumber(data.placedCount),
                    label: 'PLACED',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String count,
    required String label,
  }) {
    return Column(
      children: [
        // Circular Icon Badge
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(height: 8),

        // Count Text
        AutoSizeText(
          count,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),

        // Label Text
        AutoSizeText(
          label,
          maxLines: 1,
          minFontSize: 8,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // --- AI Candidate Matching Card ---
  Widget _buildAiCandidateMatchingCard(BuildContext context, double screenWidth) {
    final candidate = _currentMatchCandidate ?? AiCandidateMatchModel.defaultMatch;

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
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                const Icon(
                  LucideIcons.sparkles,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI Candidate Matching',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Subtitle
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'Plus Jakarta Sans',
                ),
                children: [
                  const TextSpan(text: 'Top matches for '),
                  TextSpan(
                    text: candidate.roleTitle,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Inner Candidate Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Candidate Row (Avatar with Badge, Name, Skills)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar Container with Hero + Match % Pill
                      Hero(
                        tag: 'student-avatar-${candidate.candidateId}',
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage('assets/images/hero_student.webp'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            // Match % Pill
                            Positioned(
                              bottom: -6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${candidate.matchPercentage}%',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Name & Skills
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              candidate.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              candidate.skills.join(' • '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // AI Reasoning Quote Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      candidate.matchReasoning,
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppColors.accentViolet,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Action Buttons Row: SHORTLIST & PROFILE
                  Row(
                    children: [
                      // SHORTLIST Button -> Triggers API action
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isShortlisting ? null : _handleShortlistCandidate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isShortlisted ? AppColors.success : AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isShortlisting
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isShortlisted) ...[
                                      const Icon(LucideIcons.check, size: 14, color: Colors.white),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      _isShortlisted ? 'SHORTLISTED' : 'SHORTLIST',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // PROFILE Button -> Navigates to Screen 3 Student Profile
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.go('/college/students/${candidate.candidateId}');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppColors.border, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'PROFILE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Dashed / Light Outlined Button: "Generate More Matches"
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isGeneratingMatch ? null : _handleGenerateMoreMatches,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isGeneratingMatch
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(LucideIcons.sparkles, size: 14, color: AppColors.primary),
                label: Text(
                  _isGeneratingMatch ? 'Analyzing AI Profiles...' : 'Generate More Matches',
                  style: const TextStyle(
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

  // --- Recent Job Performance Section ---
  Widget _buildRecentJobPerformanceSection(
    BuildContext context,
    JobPipelineOverviewModel data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Job Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.go('/college/drives');
              },
              child: const Text(
                'View All',
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

        // Job Performance Cards List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.recentJobPerformance.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final job = data.recentJobPerformance[index];
            return _buildJobPerformanceCard(context, job);
          },
        ),
      ],
    );
  }

  Widget _buildJobPerformanceCard(BuildContext context, JobPerformanceItemModel job) {
    final isCode = job.categoryIcon == 'code';
    final isExpiring = job.status == 'EXPIRING';

    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // Routes to Screen 6: Company Info (/college/companies/:id)
          context.go('/college/companies/${job.companyId}');
        },
        borderRadius: BorderRadius.circular(18),
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
              // Header Row: Icon, Title, Code, Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon Square
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isCode
                          ? const Color(0xFFEEF2FF)
                          : const Color(0xFFFAF5FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isCode ? LucideIcons.code : LucideIcons.image,
                      size: 20,
                      color: isCode ? AppColors.primary : AppColors.accentViolet,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title & JD Code
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.roleTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.jdCode,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge (ACTIVE / EXPIRING)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isExpiring
                          ? AppColors.warningLight
                          : AppColors.successLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      job.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isExpiring
                            ? AppColors.warning
                            : AppColors.success,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Bottom Stats Row: VIEWS & APPLICATIONS
              Row(
                children: [
                  // VIEWS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VIEWS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatNumber(job.viewsCount),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // APPLICATIONS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'APPLICATIONS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatNumber(job.applicationsCount),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Quick Action Modal Bottom Sheet (FAB + trigger) ---
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
                  'Pipeline Quick Actions',
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
                    child: Icon(LucideIcons.userPlus, color: AppColors.primary, size: 18),
                  ),
                  title: const Text('Add Candidate to Drive'),
                  subtitle: const Text('Nominate student for backend developer role'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/college/students');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.aiBadgeBg,
                    child: Icon(LucideIcons.sparkles, color: AppColors.accentViolet, size: 18),
                  ),
                  title: const Text('Run AI Batch Shortlist'),
                  subtitle: const Text('Automatically match and filter top candidates'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleGenerateMoreMatches();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.successLight,
                    child: Icon(LucideIcons.fileSpreadsheet, color: AppColors.success, size: 18),
                  ),
                  title: const Text('Export Pipeline Report'),
                  subtitle: const Text('Download CSV / PDF shortlist report'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downloading Pipeline Shortlist PDF...')),
                    );
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
        // Already on Reports / Pipeline
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
