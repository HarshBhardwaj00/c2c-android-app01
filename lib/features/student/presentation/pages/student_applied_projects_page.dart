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
  bool _hasError = false;
  String? _errorMessage;
  String _selectedFilter = 'All';

  /// Filter tabs are derived from the statuses actually returned by the backend,
  /// so they always reflect real data instead of showing dead filters.
  List<String> get _filterTabs {
    final statuses = <String>{'All'};
    for (final app in _applications) {
      final status = (app['status'] ?? '').toString();
      if (status.isNotEmpty) statuses.add(status);
    }
    return statuses.toList();
  }

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? StudentApiService();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final apps = await _apiService.getApplications();
      if (!mounted) return;
      setState(() {
        _applications = apps;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
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

  Future<void> _confirmWithdraw(Map<String, dynamic> app) async {
    HapticFeedback.mediumImpact();
    final applicationId = (app['id'] ?? '').toString();
    final projectTitle = (app['title'] ?? 'Project Application').toString();

    // Assignment submissions cannot be withdrawn via the student portal
    // (no student-facing backend endpoint exists). Show a clear message
    // instead of attempting a doomed network call.
    if ((app['source'] ?? 'assignment').toString() != 'application') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Withdrawal is not available for assignment submissions on the '
            'student portal. Please contact your college TPO for assistance.',
          ),
          backgroundColor: AppColors.textSecondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      );
      return;
    }

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

  Future<void> _showProjectSubmissionAndDetailsModal(Map<String, dynamic> app) async {
    HapticFeedback.mediumImpact();
    final id = (app['id'] ?? '').toString();
    final title = (app['title'] ?? 'Project Application').toString();
    final company = (app['company'] ?? 'Company').toString();
    final status = (app['status'] ?? 'Applied').toString();
    final initialUrl = (app['submissionUrl'] ?? '').toString();
    final initialContent = (app['content'] ?? '').toString();
    final feedback = (app['feedback'] ?? '').toString();
    final score = app['score'];

    final urlController = TextEditingController(text: initialUrl);
    final notesController = TextEditingController(text: initialContent);
    bool isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final bottomInset = MediaQuery.of(modalContext).viewInsets.bottom;
        final bottomSystemPadding = MediaQuery.of(modalContext).padding.bottom == 0
            ? 16.0
            : MediaQuery.of(modalContext).padding.bottom;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: bottomInset + bottomSystemPadding,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  company,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                AutoSizeText(
                                  title,
                                  maxLines: 2,
                                  minFontSize: 14,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AutoSizeText(
                              status,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Score Badge Banner if available
                      if (score != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.award, size: 18, color: AppColors.success),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AutoSizeText(
                                  'Evaluation Score: $score / 100',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Reviewer Feedback if available
                      if (feedback.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(LucideIcons.messageSquare, size: 14, color: AppColors.primary),
                                  SizedBox(width: 6),
                                  Text(
                                    'Reviewer Feedback',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                feedback,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      const Text(
                        'SUBMISSION DELIVERABLES',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Submission URL TextField
                      TextField(
                        controller: urlController,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'https://github.com/myusername/my-project',
                          hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                          prefixIcon: const Icon(LucideIcons.link, size: 16, color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Content Notes TextField
                      TextField(
                        controller: notesController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Add implementation details or reviewer notes...',
                          hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Submit Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cardDark,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final url = urlController.text.trim();
                                  if (url.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a GitHub or Project Demo URL'),
                                        backgroundColor: AppColors.error,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }

                                  final messenger = ScaffoldMessenger.of(context);
                                  final navigator = Navigator.of(modalContext);
                                  setModalState(() => isSubmitting = true);
                                  try {
                                    await _apiService.submitProjectWork(
                                      projectId: id,
                                      title: title,
                                      submissionUrl: url,
                                      content: notesController.text.trim(),
                                    );

                                    if (!context.mounted) return;
                                    navigator.pop();
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Project deliverable submitted successfully!'),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    _fetchApplications();
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    setModalState(() => isSubmitting = false);
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: AppColors.error,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(LucideIcons.send, size: 16, color: Colors.white),
                          label: Text(
                            isSubmitting ? 'Submitting...' : 'Submit Deliverable Work',
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white),
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
      },
    );
  }

  /// Builds a plain-text summary of the currently loaded applications from local
  /// state and copies it to the clipboard.
  Future<void> _exportReport() async {
    if (_applications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No applications to export yet.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final buffer = StringBuffer()
      ..writeln('C2C — Applied Projects Report')
      ..writeln('Generated: ${DateTime.now().toString().split('.').first}')
      ..writeln('-------------------------------------');

    for (final app in _applications) {
      buffer
        ..writeln('• ${app['title'] ?? 'Untitled Project'}')
        ..writeln('  Company: ${app['company'] ?? '-'}')
        ..writeln('  Status: ${app['status'] ?? '-'}')
        ..writeln('  Applied on: ${app['appliedOn'] ?? '-'}')
        ..writeln('  Stipend: ${app['stipend'] ?? '-'}')
        ..writeln('  Location: ${app['location'] ?? '-'}');
      if (app['score'] != null) {
        buffer.writeln('  Score: ${app['score']}/100');
      }
      buffer.writeln();
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report copied to clipboard'),
        backgroundColor: AppColors.cardDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.width > 600;
    final horizontalPadding = (screenSize.width * 0.045).clamp(14.0, 24.0);

    final submittedCount = _countByStatus('Submitted');
    final gradedCount = _countByStatus('Graded');
    final filteredList = _filteredApplications;

    final bottomPadding = MediaQuery.of(context).padding.bottom == 0
        ? 16.0
        : MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleSafePop();
        }
      },
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.surf,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: context.txtPrimary, size: 20),
            onPressed: _handleSafePop,
            tooltip: 'Back to Dashboard',
          ),
          title: AutoSizeText(
            'Applied Projects',
            maxLines: 1,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.txtPrimary,
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
                bottom: bottomPadding,
                top: 16.0,
                left: horizontalPadding,
                right: horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HERO HEADER CARD
                  RepaintBoundary(child: _buildHeroHeaderCard()),
                  const SizedBox(height: 16),

                  // 2. TOP METRICS STAT CARDS ROW (Zero-Overflow Protected)
                  RepaintBoundary(
                    child: _buildTopMetricsSection(
                      _applications.length,
                      submittedCount,
                      gradedCount,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. HORIZONTAL STATUS FILTER TABS BAR
                  _buildStatusFilterBar(),
                  const SizedBox(height: 18),

                  // 4. MAIN APPLICATIONS CONTAINER CARD
                  RepaintBoundary(
                    child: _buildApplicationsMainCard(filteredList, isTablet),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 1. Hero Header Card
  Widget _buildHeroHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.brdr),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.03),
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
              color: context.priLight,
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
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Main Heading
          AutoSizeText(
            'Applied Projects',
            maxLines: 1,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: context.txtPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle Text
          Text(
            "Follow the status of every project you've applied to, from submission through offer.",
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: context.txtSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Top Metrics Section featuring Applications Card + Submitted & Graded Cards
  /// Protected against all horizontal RenderBox overflows with Flexible & AutoSizeText.
  Widget _buildTopMetricsSection(int totalSubmitted, int submittedCount, int gradedCount) {
    return Column(
      children: [
        // Applications Stat Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.brdr),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.barChart2,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AutoSizeText(
                      'Applications',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: context.txtPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: AutoSizeText(
                      '$totalSubmitted',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: context.txtPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.priLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AutoSizeText(
                'Total submitted',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.txtSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2-Column Row for Submitted & Graded Stat Cards
        Row(
          children: [
            // Submitted Card (Fixed RenderBox overflow with Expanded + AutoSizeText)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: context.surf,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.brdr),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.02),
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
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.send, size: 15, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AutoSizeText(
                            'Submitted',
                            maxLines: 1,
                            minFontSize: 10,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: context.txtPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AutoSizeText(
                      '$submittedCount',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: context.txtPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Graded Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: context.surf,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.brdr),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.02),
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
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.dollarSign, size: 15, color: Color(0xFFD97706)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AutoSizeText(
                            'Graded',
                            maxLines: 1,
                            minFontSize: 10,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: context.txtPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AutoSizeText(
                      '$gradedCount',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: context.txtPrimary,
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

  /// 3. Horizontal Status Filter Bar
  Widget _buildStatusFilterBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.cardDark : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tab,
                        style: TextStyle(
                          fontSize: 12.5,
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
                            fontSize: 10.5,
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

  /// 4. Applications Main Card Container
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
              Expanded(
                child: Column(
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
                    AutoSizeText(
                      _selectedFilter == 'All' ? 'All applications' : '$_selectedFilter applications',
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.share2, size: 18, color: AppColors.textMuted),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _exportReport();
                },
                tooltip: 'Export Report',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dynamic Body: Loading / Error / Empty State / Active List
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(36.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_hasError)
            _buildErrorStateCard()
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

  /// Error State Card with Retry Action
  Widget _buildErrorStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.inputFill.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.alertCircle, size: 30, color: AppColors.error),
          const SizedBox(height: 12),
          const Text(
            'Failed to load applications',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? 'Please check your connection and try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          BouncyButton(
            onPressed: _fetchApplications,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.rotateCcw, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Retry',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Empty State Card Container matching Figma Spec
  Widget _buildFigmaEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.inputFill.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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

  /// Individual Application Card Item (Zero-Overflow Protected)
  Widget _buildApplicationCardItem(Map<String, dynamic> app) {
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

    if (status.toLowerCase().contains('review') || status.toLowerCase().contains('submit')) {
      statusBg = AppColors.warningLight;
      statusText = const Color(0xFFD97706);
    } else if (status.toLowerCase().contains('graded') ||
        status.toLowerCase().contains('interview') ||
        status.toLowerCase().contains('accept')) {
      statusBg = AppColors.successLight;
      statusText = const Color(0xFF059669);
    } else if (status.toLowerCase().contains('reject') || status.toLowerCase().contains('withdraw')) {
      statusBg = AppColors.errorLight;
      statusText = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Company & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AutoSizeText(
                  company,
                  maxLines: 1,
                  minFontSize: 10,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: context.txtSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AutoSizeText(
                  status,
                  maxLines: 1,
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
            minFontSize: 13,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: context.txtPrimary,
              letterSpacing: -0.2,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),

          // Info Metrics Wrap (Stipend & Location & Applied Date) - Zero horizontal overflow
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Stipend
              Row(
                mainAxisSize: MainAxisSize.min,
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
                ],
              ),

              // Location
              if (location.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.mapPin, size: 13, color: context.txtMuted),
                    const SizedBox(width: 3),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: context.txtSecondary,
                      ),
                    ),
                  ],
                ),

              // Applied Date
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.calendar, size: 13, color: context.txtMuted),
                  const SizedBox(width: 3),
                  Text(
                    appliedOn.isNotEmpty ? appliedOn : 'Recently',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.txtMuted,
                    ),
                  ),
                ],
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
                    color: context.surfAlt,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: context.txtPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          Divider(height: 1, color: context.brdr.withValues(alpha: 0.6)),
          const SizedBox(height: 10),

          // Card Action Buttons Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!status.toLowerCase().contains('withdraw') &&
                  !status.toLowerCase().contains('reject') &&
                  (app['source'] ?? '').toString() == 'application') ...[
                TextButton(
                  onPressed: () => _confirmWithdraw(app),
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
              ],
              BouncyButton(
                onPressed: () => _showProjectSubmissionAndDetailsModal(app),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
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
