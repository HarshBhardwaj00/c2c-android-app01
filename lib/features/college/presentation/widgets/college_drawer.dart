import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

class CollegeNavigationDrawer extends StatelessWidget {
  final String currentRoute;

  const CollegeNavigationDrawer({
    super.key,
    this.currentRoute = '/college/dashboard',
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            _buildDrawerHeader(context),
            const Divider(height: 1, color: AppColors.border),

            // Navigation List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                children: [
                  _buildSectionHeader('CORE DASHBOARD'),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.layoutDashboard,
                    title: 'Executive Overview',
                    route: '/college/dashboard',
                    isSelected: currentRoute == '/college/dashboard',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.users,
                    title: 'Student Directory',
                    route: '/college/students',
                    isSelected: currentRoute == '/college/students',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.briefcase,
                    title: 'Placement Hub',
                    route: '/college/drives',
                    isSelected: currentRoute == '/college/drives',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.gitCommit,
                    title: 'Job Pipeline',
                    route: '/college/drives/d1/pipeline',
                    isSelected: currentRoute.contains('/pipeline'),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.building2,
                    title: 'Company Directory',
                    route: '/college/companies/c1',
                    isSelected: currentRoute.contains('/companies'),
                  ),

                  const SizedBox(height: 12),
                  _buildSectionHeader('ANALYTICS & READINESS'),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.barChart3,
                    title: 'Departmental Analytics',
                    route: '/college/analytics/department',
                    isSelected: currentRoute == '/college/analytics/department',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.gitCompare,
                    title: 'Department Comparison',
                    route: '/college/analytics/compare',
                    isSelected: currentRoute == '/college/analytics/compare',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.target,
                    title: 'Readiness Analytics',
                    route: '/college/analytics/readiness',
                    isSelected: currentRoute == '/college/analytics/readiness',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.alertTriangle,
                    title: 'At-Risk Students',
                    route: '/college/students/at-risk',
                    isSelected: currentRoute == '/college/students/at-risk',
                    badge: 'Alerts',
                    badgeColor: AppColors.errorLight,
                    badgeTextColor: AppColors.error,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.sparkles,
                    title: 'Placement Intelligence',
                    route: '/college/analytics/intelligence',
                    isSelected: currentRoute == '/college/analytics/intelligence',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.graduationCap,
                    title: 'Assessments & Learning',
                    route: '/college/analytics/assessments',
                    isSelected: currentRoute == '/college/analytics/assessments',
                  ),

                  const SizedBox(height: 12),
                  _buildSectionHeader('OPERATIONS & ADMIN'),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.megaphone,
                    title: 'Communication Hub',
                    route: '/college/operations/communication',
                    isSelected: currentRoute == '/college/operations/communication',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.settings,
                    title: 'Institutional Settings',
                    route: '/college/operations/config',
                    isSelected: currentRoute == '/college/operations/config',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.fileSpreadsheet,
                    title: 'Reports & Analytics',
                    route: '/college/reports',
                    isSelected: currentRoute == '/college/reports',
                  ),
                ],
              ),
            ),

            // Footer Logout Section
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  context.go('/login');
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.logOut, size: 18, color: AppColors.error),
                      SizedBox(width: 10),
                      Text(
                        'Logout Session',
                        style: TextStyle(
                          fontSize: 13,
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
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primaryLight.withValues(alpha: 0.4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text(
              'C2C',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apex Tech Institute',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'TPO Officer Admin',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
    String? badge,
    Color? badgeColor,
    Color? badgeTextColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Icon(
          icon,
          size: 18,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor ?? AppColors.primary,
                  ),
                ),
              )
            : null,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context); // Close Drawer
          if (!isSelected) {
            context.go(route);
          }
        },
      ),
    );
  }
}
