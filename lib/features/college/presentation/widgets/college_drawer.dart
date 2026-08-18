import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

/// Production-ready College Navigation Drawer containing strictly the 8 core
/// navigation items synchronized with the web platform.
class CollegeNavigationDrawer extends StatelessWidget {
  final String currentRoute;

  const CollegeNavigationDrawer({
    super.key,
    this.currentRoute = '/college/dashboard',
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Drawer(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Drawer Header
            _buildDrawerHeader(context),
            const Divider(height: 1, color: AppColors.border),

            // Navigation List: Exactly the 8 items from the Web Panel
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                children: [
                  // 1. Dashboard
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.layoutGrid,
                    title: 'Dashboard',
                    route: '/college/dashboard',
                    isSelected: currentRoute == '/college/dashboard',
                  ),

                  // 2. Student Records
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.graduationCap,
                    title: 'Student Records',
                    route: '/college/students',
                    isSelected: currentRoute == '/college/students' || currentRoute.startsWith('/college/students/'),
                  ),

                  // 3. Placement Management
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.briefcase,
                    title: 'Placement Management',
                    route: '/college/drives',
                    isSelected: currentRoute == '/college/drives' || currentRoute.startsWith('/college/drives/'),
                  ),

                  // 4. Broadcast Center
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.megaphone,
                    title: 'Broadcast Center',
                    route: '/college/broadcast',
                    isSelected: currentRoute == '/college/broadcast' || currentRoute == '/college/operations/communication',
                  ),

                  // 5. Recruiter Coordination
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.userCheck,
                    title: 'Recruiter Coordination',
                    route: '/college/recruiters',
                    isSelected: currentRoute == '/college/recruiters',
                  ),

                  // 6. Batch Groups
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.users,
                    title: 'Batch Groups',
                    route: '/college/batches',
                    isSelected: currentRoute == '/college/batches',
                  ),

                  // 7. Reports & Analytics
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.barChart2,
                    title: 'Reports & Analytics',
                    route: '/college/reports',
                    isSelected: currentRoute == '/college/reports',
                  ),

                  // 8. Settings
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.settings,
                    title: 'Settings',
                    route: '/college/settings',
                    isSelected: currentRoute == '/college/settings' || currentRoute == '/college/operations/config',
                  ),
                ],
              ),
            ),

            // Footer Logout Section with Safe Padding
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: EdgeInsets.only(
                left: 12.0,
                right: 12.0,
                top: 10.0,
                bottom: bottomInset == 0 ? 12.0 : bottomInset + 4.0,
              ),
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
                  child: Row(
                    children: [
                      const Icon(LucideIcons.logOut, size: 18, color: AppColors.error),
                      const SizedBox(width: 10),
                      Text(
                        'Logout Session',
                        style: GoogleFonts.plusJakartaSans(
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
      color: AppColors.primaryLight.withValues(alpha: 0.35),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x336366F1),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'C2C',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'College / Institute',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'TPO Administrative Portal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
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

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF3E8FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(
          icon,
          size: 19,
          color: isSelected ? const Color(0xFF7C3AED) : const IconThemeData().color ?? const Color(0xFF64748B),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFF334155),
          ),
        ),
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
