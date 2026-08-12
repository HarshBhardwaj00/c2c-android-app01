import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/student_api_service.dart';
import '../widgets/student_nav_panel.dart';
import '../widgets/student_profile_menu_pill.dart';
import '../../../auth/presentation/widgets/bouncy_button.dart';

/// 100% Figma-Fidelity Applied Projects Screen for C2C Student Module.
/// Built with strict architectural, layout, engine, and safety enforcement.
class StudentAppliedProjectsPage extends StatefulWidget {
  final StudentApiService? apiService;

  const StudentAppliedProjectsPage({super.key, this.apiService});

  @override
  State<StudentAppliedProjectsPage> createState() => _StudentAppliedProjectsPageState();
}

class _StudentAppliedProjectsPageState extends State<StudentAppliedProjectsPage> {
  late final StudentApiService _apiService;
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  final List<String> _filterTabs = [
    'All',
    'Applied',
    'Under Review',
    'Interviewing',
    'Accepted',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? StudentApiService();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() => _isLoading = true);
    try {
      final apps = await _apiService.getApplications();
      if (!mounted) return;
      setState(() {
        _applications = apps;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _handleSafePop() {
    HapticFeedback.lightImpact();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      context.go('/student/dashboard');
    }
  }

  List<Map<String, dynamic>> get _filteredApplications {
    if (_selectedFilter == 'All') return _applications;
    return _applications.where((app) {
      final status = (app['status'] ?? '').toString().toLowerCase();
      return status == _selectedFilter.toLowerCase();
    }).toList();
  }

  int _countByStatus(String status) {
    if (status == 'All') return _applications.length;
    return _applications.where((app) {
      final appStatus = (app['status'] ?? '').toString().toLowerCase();
      return appStatus == status.toLowerCase();
    }).length;
  }

  Future<void> _confirmWithdraw(String applicationId, String projectTitle) async {
    HapticFeedback.mediumImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Withdraw Application?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to withdraw your application for "$projectTitle"? This action cannot be undone.',
          style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Withdraw', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final success = await _apiService.withdrawApplication(applicationId);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application for "$projectTitle" withdrawn'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _fetchApplications();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.width > 600;
    final horizontalPadding = (screenSize.width * 0.045).clamp(14.0, 24.0);

    final appliedCount = _countByStatus('Applied');
    final underReviewCount = _countByStatus('Under Review');
    final filteredList = _filteredApplications;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleSafePop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary, size: 20),
            onPressed: _handleSafePop,
            tooltip: 'Back to Dashboard',
          ),
          title: const AutoSizeText(
            'Applied Projects',
            maxLines: 1,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.menu, size: 20, color: AppColors.primary),
              onPressed: () => showStudentNavPanel(context, activeRoute: '/student/applied-projects'),
              tooltip: 'Navigation Menu',
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: StudentProfileMenuPill(),
            ),
          ],
        ),
        body: SafeArea(
          bottom: true,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _fetchApplications,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom == 0
                    ? 16.0
                    : MediaQuery.of(context).padding.bottom,
                top: 16.0,
                left: horizontalPadding,
                right: horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HERO HEADER CARD (Figma Spec Image 1)
                  _buildHeroHeaderCard(),
                  const SizedBox(height: 16),

                  // 2. TOP METRICS STAT CARDS ROW (Figma Spec Image 1 & Image 2)
                  _buildTopMetricsSection(_applications.length, appliedCount, underReviewCount),
                  const SizedBox(height: 16),

                  // 3. HORIZONTAL STATUS FILTER TABS BAR (Figma Spec Image 1)
                  _buildStatusFilterBar(),
                  const SizedBox(height: 18),

                  // 4. MAIN APPLICATIONS CONTAINER CARD (Figma Spec Image 1)
                  _buildApplicationsMainCard(filteredList, isTablet),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 1. Hero Header Card matching Figma Image 1 100%
  Widget _buildHeroHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Track your applications pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.shield, size: 13, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'Track your applications',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Main Heading
          const AutoSizeText(
            'Applied Projects',
            maxLines: 1,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle Text
          const Text(
            "Follow the status of every project you've applied to, from submission through offer.",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Top Metrics Section featuring Applications Card (Image 2) + Applied & Under Review (Image 1)
  Widget _buildTopMetricsSection(int totalSubmitted, int appliedCount, int underReviewCount) {
    return Column(
      children: [
        // Applications Stat Card (Figma Spec Image 2)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(
                    LucideIcons.barChart2,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Applications',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$totalSubmitted',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Total submitted',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2-Column Row for Applied & Under Review Stat Cards (Figma Spec Image 1)
        Row(
          children: [
            // Applied Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.send, size: 16, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Applied',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$appliedCount',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Under Review Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.dollarSign, size: 16, color: Color(0xFFD97706)),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Under Review',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$underReviewCount',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 3. Horizontal Status Filter Bar matching Figma Image 1 100%
  Widget _buildStatusFilterBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _filterTabs.map((tab) {
            final isSelected = _selectedFilter == tab;
            final count = _countByStatus(tab);

            return Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedFilter = tab);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        tab,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1E293B)
                              : AppColors.inputFill,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 4. Applications Main Card Container matching Figma Spec 100%
  Widget _buildApplicationsMainCard(List<Map<String, dynamic>> filteredList, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Row: Title & Export Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'APPLICATIONS',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _selectedFilter == 'All' ? 'All applications' : '$_selectedFilter applications',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(LucideIcons.share2, size: 18, color: AppColors.textMuted),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exporting applications summary report...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                tooltip: 'Export Report',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dynamic Body: Loading / Empty State (Figma Dotted Card) / Active List
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(36.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (filteredList.isEmpty)
            _buildFigmaEmptyStateCard()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return RepaintBoundary(
                  child: _buildApplicationCardItem(filteredList[index]),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Empty State Card Container matching Figma Dotted Design 100%
  Widget _buildFigmaEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.inputFill.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          // Centered Document Icon Container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              LucideIcons.fileText,
              size: 26,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),

          // Title
          const Text(
            'No applications here',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          const Text(
            'Nothing matches this filter yet.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Individual Application Card Item
  Widget _buildApplicationCardItem(Map<String, dynamic> app) {
    final id = (app['id'] ?? '').toString();
    final title = (app['title'] ?? 'Project Application').toString();
    final company = (app['company'] ?? 'Company').toString();
    final status = (app['status'] ?? 'Applied').toString();
    final appliedOn = (app['appliedOn'] ?? '').toString();
    final stipend = (app['stipend'] ?? 'Stipend Unspecified').toString();
    final location = (app['location'] ?? 'Remote').toString();
    final skills = (app['skills'] is List)
        ? (app['skills'] as List).cast<String>()
        : <String>[];

    // Status styling maps
    Color statusBg = const Color(0xFFEFF6FF);
    Color statusText = const Color(0xFF2563EB);

    if (status.toLowerCase().contains('review')) {
      statusBg = const Color(0xFFFEF3C7);
      statusText = const Color(0xFFD97706);
    } else if (status.toLowerCase().contains('interview') || status.toLowerCase().contains('accept')) {
      statusBg = const Color(0xFFECFDF5);
      statusText = const Color(0xFF059669);
    } else if (status.toLowerCase().contains('reject') || status.toLowerCase().contains('withdraw')) {
      statusBg = const Color(0xFFFEF2F2);
      statusText = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Company & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: statusText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Project Title
          AutoSizeText(
            title,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),

          // Info Metrics Row: Stipend & Location & Applied Date
          Row(
            children: [
              const Icon(LucideIcons.dollarSign, size: 13, color: AppColors.success),
              const SizedBox(width: 2),
              Text(
                stipend,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              if (location.isNotEmpty) ...[
                const Icon(LucideIcons.mapPin, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 3),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              const Icon(LucideIcons.calendar, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  appliedOn.isNotEmpty ? appliedOn : 'Recently',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tech Skills Wrap
          if (skills.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills.take(3).map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.6)),
          const SizedBox(height: 10),

          // Card Action Buttons Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!status.toLowerCase().contains('withdraw') && !status.toLowerCase().contains('reject'))
                TextButton(
                  onPressed: () => _confirmWithdraw(id, title),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Withdraw',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              BouncyButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Viewing status timeline for "$title"'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(LucideIcons.chevronRight, size: 14, color: Colors.white),
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
}
