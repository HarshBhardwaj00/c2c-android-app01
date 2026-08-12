import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../domain/models/company_insights_model.dart';
import '../../data/services/company_insights_api_service.dart';
import '../widgets/college_drawer.dart';

class CompanyInsightsPage extends StatefulWidget {
  final String companyId;

  const CompanyInsightsPage({
    super.key,
    required this.companyId,
  });

  @override
  State<CompanyInsightsPage> createState() => _CompanyInsightsPageState();
}

class _CompanyInsightsPageState extends State<CompanyInsightsPage> {
  final CompanyInsightsApiService _apiService = CompanyInsightsApiService();
  late Future<CompanyDirectoryDataModel> _directoryFuture;

  int _navIndex = 1; // Placement Hub / Drives tab selected
  bool _isGridView = false;
  bool _isLoadingMore = false;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  List<VerifiedPartnerItemModel> _loadedPartners = [];

  @override
  void initState() {
    super.initState();
    _loadDirectoryData();
  }

  void _loadDirectoryData() {
    _directoryFuture = _apiService.fetchCompanyDirectory();
    _directoryFuture.then((data) {
      if (mounted) {
        setState(() {
          _loadedPartners = List.from(data.partners);
        });
      }
    });
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    setState(() {
      _loadDirectoryData();
    });
    await _directoryFuture;
  }

  Future<void> _handleLoadMorePartners() async {
    if (_isLoadingMore) return;
    HapticFeedback.lightImpact();
    setState(() => _isLoadingMore = true);

    final extraPartners = await _apiService.loadMorePartners();

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
        _loadedPartners.addAll(extraPartners);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loaded additional verified partner companies!'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleOnboardPartner() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final domainController = TextEditingController();
        final emailController = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(LucideIcons.building2, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text('Onboard New Partner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Company Name', hintText: 'e.g. Acme Corp'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: domainController,
                  decoration: const InputDecoration(labelText: 'Industry / Domain', hintText: 'e.g. Software & AI'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Recruiter Contact Email', hintText: 'hr@acme.com'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                final success = await _apiService.onboardPartnerCompany(
                  companyName: nameController.text.isNotEmpty ? nameController.text : 'New Enterprise',
                  domain: domainController.text,
                  contactEmail: emailController.text,
                );
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Partner Onboarding request submitted successfully!' : 'Failed to submit.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
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
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/drives'),
      appBar: _buildTopAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: FutureBuilder<CompanyDirectoryDataModel>(
            future: _directoryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _loadedPartners.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final directoryData = snapshot.data ?? CompanyDirectoryDataModel.mockData;
              final partners = _loadedPartners.isNotEmpty ? _loadedPartners : directoryData.partners;

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

                    // 2. Action Row (+ Onboard Partner & Filter Button)
                    _buildActionRow(context),
                    const SizedBox(height: 16),

                    // 3. Metrics Cards (PARTNER COMPANIES & SATISFACTION)
                    _buildMetricsRowCards(context, directoryData),
                    const SizedBox(height: 20),

                    // 4. Verified Partner Directory Section
                    _buildDirectoryHeaderRow(),
                    const SizedBox(height: 12),

                    // 5. Partners List / Grid Cards
                    if (_isGridView)
                      _buildPartnersGrid(context, partners)
                    else
                      _buildPartnersList(context, partners),

                    const SizedBox(height: 14),

                    // 6. Dashed Load More Partners Button
                    _buildLoadMoreButton(),
                    const SizedBox(height: 20),

                    // 7. Featured Vibrant Purple PENDING REQUESTS Card
                    _buildPendingRequestsCard(context, directoryData.featuredPendingRequest),
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
        // Search Icon
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

        // Notification Bell Icon with Red Alert Badge
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

        // User Avatar Circle
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
          hintText: 'Search partners, industries, or tier levels...',
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

  // --- 1. Header Section ---
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Company & Recruiter\nEcosystem',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.25,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Manage verified industry partners and monitor engagement metrics.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // --- 2. Action Row (+ Onboard Partner & Filter Button) ---
  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: [
        // Primary Large + Onboard Partner Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _handleOnboardPartner,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
            label: const AutoSizeText(
              'Onboard Partner',
              maxLines: 1,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Filter Button
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showFilterBottomSheet(context);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.slidersHorizontal,
              color: AppColors.textPrimary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. Metrics Row Cards (PARTNER COMPANIES & SATISFACTION) ---
  Widget _buildMetricsRowCards(
    BuildContext context,
    CompanyDirectoryDataModel data,
  ) {
    return Row(
      children: [
        // Left Card: PARTNER COMPANIES
        Expanded(
          child: RepaintBoundary(
            child: Container(
              padding: const EdgeInsets.all(14),
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
                  // Top Row: Building Icon + Growth Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.building2,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          data.partnerGrowthYoY,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Label
                  const Text(
                    'PARTNER COMPANIES',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Value Number
                  AutoSizeText(
                    '${data.totalPartnerCompanies}',
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.70,
                      minHeight: 4,
                      backgroundColor: AppColors.inputFill,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Right Card: SATISFACTION
        Expanded(
          child: RepaintBoundary(
            child: Container(
              padding: const EdgeInsets.all(14),
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
                  // Top Row: Smile Icon + Excellent Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.aiBadgeBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.smile,
                          size: 16,
                          color: AppColors.accentViolet,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Excellent',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Label
                  const Text(
                    'SATISFACTION',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Value Number
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${data.satisfactionRating}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        const TextSpan(
                          text: ' /5.0',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Star Rating Icons Row (4 filled, 1 empty)
                  Row(
                    children: List.generate(5, (index) {
                      final isFilled = index < 4;
                      return Padding(
                        padding: const EdgeInsets.only(right: 2.0),
                        child: Icon(
                          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 14,
                          color: isFilled ? AppColors.accentViolet : AppColors.textMuted,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 4. Directory Header Row ---
  Widget _buildDirectoryHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Verified Partner Directory',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        // List / Grid View Switcher
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isGridView = false);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: !_isGridView ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: !_isGridView
                        ? const [BoxShadow(color: AppColors.cardShadow, blurRadius: 4)]
                        : null,
                  ),
                  child: Icon(
                    LucideIcons.list,
                    size: 16,
                    color: !_isGridView ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isGridView = true);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isGridView ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: _isGridView
                        ? const [BoxShadow(color: AppColors.cardShadow, blurRadius: 4)]
                        : null,
                  ),
                  child: Icon(
                    LucideIcons.layoutGrid,
                    size: 16,
                    color: _isGridView ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 5. Partners List View ---
  Widget _buildPartnersList(BuildContext context, List<VerifiedPartnerItemModel> partners) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: partners.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final partner = partners[index];
        return _buildPartnerCard(context, partner);
      },
    );
  }

  // --- Partners Grid View ---
  Widget _buildPartnersGrid(BuildContext context, List<VerifiedPartnerItemModel> partners) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: 195,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: partners.length,
      itemBuilder: (context, index) {
        final partner = partners[index];
        return _buildPartnerGridCard(context, partner);
      },
    );
  }

  // --- Partner Card (Exact Figma Style with Left Accent Line) ---
  Widget _buildPartnerCard(BuildContext context, VerifiedPartnerItemModel partner) {
    final isTier1 = partner.tierBadge.contains('TIER 1');
    final isStrategic = partner.tierBadge.contains('STRATEGIC');

    Color badgeBg = AppColors.primaryLight;
    Color badgeText = AppColors.primary;

    if (!isTier1 && !isStrategic) {
      badgeBg = AppColors.inputFill;
      badgeText = AppColors.textSecondary;
    } else if (isStrategic) {
      badgeBg = const Color(0xFFE0F2FE);
      badgeText = const Color(0xFF0284C7);
    }

    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // STRICT ROUTING REQUIREMENT: Clicking partner card routes back to Screen 4 (Filtered Drives)
          context.go('/college/drives');
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          clipBehavior: Clip.antiAlias,
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
          child: Row(
            children: [
              // Left Vertical Purple Accent Indicator Line
              Container(
                width: 4,
                height: 110,
                color: AppColors.primary,
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Logo, Company Name, Tier Badge
                      Row(
                        children: [
                          Hero(
                            tag: 'company-logo-${partner.id}',
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/college_building.webp'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        partner.companyName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),

                                    // Tier Badge Pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        partner.tierBadge,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: badgeText,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),

                                // Location & Domain
                                Text(
                                  '📍 ${partner.location} • ${partner.domain}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Bottom Stats Row: ENGAGEMENT & LAST VISIT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Engagement Progress Bar & %
                          Row(
                            children: [
                              const Text(
                                'ENGAGEMENT',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${partner.engagementPercentage}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 50,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: partner.engagementPercentage / 100.0,
                                    minHeight: 4,
                                    backgroundColor: AppColors.inputFill,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Last Visit Date
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'LAST VISIT',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                partner.lastVisitDate,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Partner Grid Card ---
  Widget _buildPartnerGridCard(BuildContext context, VerifiedPartnerItemModel partner) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.go('/college/drives');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/college_building.webp'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      partner.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                partner.tierBadge,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                '📍 ${partner.location}',
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
              const Spacer(),
              Text(
                'Engagement: ${partner.engagementPercentage}%',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 6. Dashed Load More Partners Button ---
  Widget _buildLoadMoreButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoadingMore ? null : _handleLoadMorePartners,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1.2,
          ),
          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: _isLoadingMore
            ? const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              )
            : const Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
        label: Text(
          _isLoadingMore ? 'Fetching Partners...' : 'Load More Partners',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  // --- 7. Featured Vibrant Purple PENDING REQUESTS Card ---
  Widget _buildPendingRequestsCard(
    BuildContext context,
    PendingDriveRequestModel pendingRequest,
  ) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6366F1), // Vibrant Purple Primary
              Color(0xFF4F46E5), // Dark Indigo
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Label
            const Text(
              'PENDING REQUESTS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),

            // Main Title
            Text(
              '${pendingRequest.totalPendingRequestsCount} Campus Drives',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),

            // Inner Glass Card (Stellar Robotics)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pendingRequest.companyName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pendingRequest.driveType,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // High Priority Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pendingRequest.priorityBadge,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Bottom Action Button: VIEW ALL REQUESTS (12)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // STRICT ROUTING REQUIREMENT: Routes back to Screen 4 (Filtered Drives: /college/drives)
                  context.go('/college/drives');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'VIEW ALL REQUESTS (${pendingRequest.totalPendingRequestsCount})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(LucideIcons.arrowRight, size: 14, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Filter Options Bottom Sheet ---
  void _showFilterBottomSheet(BuildContext context) {
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
                  'Filter Partner Directory',
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
                      label: const Text('All Partners'),
                      selected: true,
                      onSelected: (val) {},
                      selectedColor: AppColors.primaryLight,
                      labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    FilterChip(
                      label: const Text('Tier 1'),
                      selected: false,
                      onSelected: (val) {},
                    ),
                    FilterChip(
                      label: const Text('Fortune 500'),
                      selected: false,
                      onSelected: (val) {},
                    ),
                    FilterChip(
                      label: const Text('New Strategic'),
                      selected: false,
                      onSelected: (val) {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Routes to Screen 4 Filtered Drives
                      context.go('/college/drives');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Apply Filter & View Drives ➔', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  'Partner Ecosystem Actions',
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
                  title: const Text('Onboard New Enterprise Partner'),
                  subtitle: const Text('Register verified company & recruiter contact'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleOnboardPartner();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.aiBadgeBg,
                    child: Icon(LucideIcons.briefcase, color: AppColors.accentViolet, size: 18),
                  ),
                  title: const Text('View Screen 4 (Filtered Placement Drives)'),
                  subtitle: const Text('Browse all active and scheduled drive cycles'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/college/drives');
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
        // Screen 4: Placement Hub / Filtered Drives
        context.go('/college/drives');
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
