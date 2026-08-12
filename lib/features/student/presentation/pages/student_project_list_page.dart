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

/// 100% Figma-Fidelity Project List Screen for C2C Student Module.
/// Built with strict architectural, layout, engine, and safety enforcement.
class StudentProjectListPage extends StatefulWidget {
  final StudentApiService? apiService;

  const StudentProjectListPage({super.key, this.apiService});

  @override
  State<StudentProjectListPage> createState() => _StudentProjectListPageState();
}

class _StudentProjectListPageState extends State<StudentProjectListPage> {
  late final StudentApiService _apiService;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allProjects = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isGridView = false;
  final Set<String> _appliedProjectIds = {};

  final List<String> _categories = [
    'All',
    'Frontend',
    'Backend',
    'Full Stack',
    'Mobile',
    'AI / ML',
    'DevOps',
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? StudentApiService();
    _searchController.addListener(_onSearchChanged);
    _fetchProjects();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  Future<void> _fetchProjects() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getProjectsData();
      if (!mounted) return;
      final projects = data['projects'] as List<Map<String, dynamic>>? ?? [];
      final appliedIds = data['appliedProjectIds'] as List<String>? ?? [];

      setState(() {
        _allProjects = projects;
        _appliedProjectIds.clear();
        _appliedProjectIds.addAll(appliedIds);
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

  void _clearFilters() {
    HapticFeedback.lightImpact();
    _searchController.clear();
    setState(() {
      _selectedCategory = 'All';
      _searchQuery = '';
    });
  }

  List<Map<String, dynamic>> get _filteredProjects {
    return _allProjects.where((project) {
      final category = (project['category'] ?? '').toString();
      final title = (project['title'] ?? '').toString().toLowerCase();
      final company = (project['company'] ?? '').toString().toLowerCase();
      final techStack = (project['techStack'] is List)
          ? (project['techStack'] as List).join(' ').toLowerCase()
          : '';

      final matchesCategory = _selectedCategory == 'All' ||
          category.toLowerCase() == _selectedCategory.toLowerCase();

      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          title.contains(query) ||
          company.contains(query) ||
          techStack.contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _applyProject(String projectId, String title) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _appliedProjectIds.add(projectId);
    });

    try {
      final success = await _apiService.applyForProject(projectId);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully applied for "$title"!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _appliedProjectIds.remove(projectId);
      });
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

    final filteredList = _filteredProjects;

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
            'Browse Project Listings',
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
              onPressed: () => showStudentNavPanel(context, activeRoute: '/student/projects'),
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
            onRefresh: _fetchProjects,
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
                  // 1. HERO HEADER CARD (Figma Component 1)
                  _buildHeroHeaderCard(),
                  const SizedBox(height: 16),

                  // 2. METRICS STAT CARDS (Figma Component 2)
                  _buildMetricsRow(_allProjects.length, _categories.length - 1),
                  const SizedBox(height: 16),

                  // 3. SEARCH & FILTERS CONTROL BAR (Figma Component 3)
                  _buildSearchFilterCard(),
                  const SizedBox(height: 18),

                  // 4. RESULTS COUNT LABEL
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredList.length} projects found',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
                        GestureDetector(
                          onTap: _clearFilters,
                          child: const Text(
                            'Clear Filters',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 5. PROJECTS LISTING / EMPTY STATE (Figma Component 4 & 5)
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (filteredList.isEmpty)
                    _buildEmptyStateCard()
                  else if (_isGridView || isTablet)
                    _buildProjectGrid(filteredList)
                  else
                    _buildProjectList(filteredList),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 1. Hero Header Card matching Figma Image 100%
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
          // Small Badge Pill: Live opportunities
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.briefcase, size: 13, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'Live opportunities',
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

          // Heading
          const AutoSizeText(
            'Browse project listings',
            maxLines: 1,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          const Text(
            'Apply to real-world projects from partner companies and build a portfolio recruiters actually look at.',
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

  /// 2. Metrics Stat Cards Row matching Figma Image 100%
  Widget _buildMetricsRow(int openCount, int categoryCount) {
    return Row(
      children: [
        // Open Projects Card (Figma Design Spec 100%)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                      'Open projects',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$openCount',
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
                  'Active opportunities',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Categories Card (Figma Matching Spec)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                      LucideIcons.layoutGrid,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$categoryCount',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Tracks',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tech domains',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 3. Search & Filters Control Card matching Figma Image 100%
  Widget _buildSearchFilterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input Field
          TextField(
            controller: _searchController,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search projects, companies, tech stack..',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textMuted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.inputFill,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filters & Grid/List View Toggle Row
          Row(
            children: [
              // Filters Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.slidersHorizontal, size: 14, color: AppColors.textSecondary),
                    SizedBox(width: 6),
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Grid / List Toggle Buttons
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isGridView = true);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _isGridView ? const Color(0xFF0F172A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.layoutGrid,
                          size: 16,
                          color: _isGridView ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isGridView = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: !_isGridView ? const Color(0xFF0F172A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.list,
                          size: 16,
                          color: !_isGridView ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Category Chips Bar (Horizontal Scrollable)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = cat);
                    },
                    selectedColor: AppColors.primaryLight,
                    checkmarkColor: AppColors.primaryDark,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Empty State Card matching Figma Image 100%
  Widget _buildEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Centered Search Error Badge Icon
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.searchX,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'No projects match your filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          const Text(
            'Try a different search term or clear a filter to see available projects.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // Clear Filters Button
          OutlinedButton(
            onPressed: _clearFilters,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Clear Filters',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 5A. Project List View
  Widget _buildProjectList(List<Map<String, dynamic>> projects) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      separatorBuilder: (_, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: _buildProjectCard(projects[index]),
        );
      },
    );
  }

  /// 5B. Project Grid View
  Widget _buildProjectGrid(List<Map<String, dynamic>> projects) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: _buildProjectCard(projects[index]),
        );
      },
    );
  }

  /// Individual Project Listing Card Item
  Widget _buildProjectCard(Map<String, dynamic> project) {
    final id = (project['id'] ?? '').toString();
    final title = (project['title'] ?? 'Project').toString();
    final company = (project['company'] ?? 'Company').toString();
    final category = (project['category'] ?? 'General').toString();
    final stipend = (project['stipend'] ?? 'Stipend Unspecified').toString();
    final duration = (project['duration'] ?? '3 Months').toString();
    final location = (project['location'] ?? 'Remote').toString();
    final description = (project['description'] ?? '').toString();
    final appliedCount = (project['appliedCount'] ?? 0).toString();
    final deadline = (project['deadline'] ?? '').toString();
    final techStack = (project['techStack'] is List)
        ? (project['techStack'] as List).cast<String>()
        : <String>[];

    final isApplied = _appliedProjectIds.contains(id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
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
          // Header Row: Company Name & Category Badge
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
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
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),

          // Short Description
          if (description.isNotEmpty)
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary.withValues(alpha: 0.9),
                height: 1.35,
              ),
            ),
          const SizedBox(height: 10),

          // Tech Stack Tags Wrap
          if (techStack.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: techStack.take(4).map((tech) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    tech,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),

          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.6)),
          const SizedBox(height: 10),

          // Info Chips: Stipend, Duration, Location
          Row(
            children: [
              const Icon(LucideIcons.dollarSign, size: 13, color: AppColors.success),
              const SizedBox(width: 3),
              Text(
                stipend,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(LucideIcons.clock, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 3),
              Text(
                duration,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(LucideIcons.mapPin, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bottom Action Row: Applicants & Apply Button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$appliedCount applicants',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (deadline.isNotEmpty)
                      Text(
                        deadline,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),
              ),
              BouncyButton(
                onPressed: isApplied ? null : () => _applyProject(id, title),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isApplied ? AppColors.inputFill : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isApplied ? 'Applied ✓' : 'Apply Now',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isApplied ? AppColors.textMuted : Colors.white,
                        ),
                      ),
                      if (!isApplied) ...[
                        const SizedBox(width: 4),
                        const Icon(LucideIcons.arrowRight, size: 14, color: Colors.white),
                      ],
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
