import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/student_bloc.dart';

/// Production-Ready 100% Figma-Fidelity Profile Menu Pill Widget matching Image specifications.
/// Displays user avatar, name, and opens a dropdown card with 4 screen routers + secure Logout.
class StudentProfileMenuPill extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String avatarInitial;

  const StudentProfileMenuPill({
    super.key,
    this.userName = 'Student',
    this.userEmail = 'student@c2c.org',
    this.avatarInitial = 'S',
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 500;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showStudentProfileDropdown(
          context,
          userName: userName,
          userEmail: userEmail,
          avatarInitial: avatarInitial,
        ),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 6 : 10,
            vertical: isCompact ? 4 : 5,
          ),
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.brdr),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Blue Circular Avatar Initial Badge
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB), // Vibrant Blue
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  avatarInitial.isNotEmpty ? avatarInitial[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(width: 6),
                // User Short Name
                Flexible(
                  child: AutoSizeText(
                    userName,
                    maxLines: 1,
                    minFontSize: 10,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.txtPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  LucideIcons.chevronDown,
                  size: 14,
                  color: context.txtSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Launcher function to present the Profile Dropdown Menu anchored below the top-right pill
void showStudentProfileDropdown(
  BuildContext context, {
  String userName = 'Student',
  String userEmail = 'student@c2c.org',
  String avatarInitial = 'S',
}) {
  HapticFeedback.lightImpact();
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss Profile Menu',
    barrierColor: Colors.black.withValues(alpha: context.isDark ? 0.5 : 0.25),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 48),
            child: Material(
              color: Colors.transparent,
              child: _ProfileDropdownMenuCard(
                userName: userName,
                userEmail: userEmail,
                avatarInitial: avatarInitial,
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
        alignment: Alignment.topRight,
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );
    },
  );
}

class _ProfileDropdownMenuCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String avatarInitial;

  const _ProfileDropdownMenuCard({
    required this.userName,
    required this.userEmail,
    required this.avatarInitial,
  });

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 230.0;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.35 : 0.12),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: context.brdr),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. User Information Header matching Image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.txtPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: context.txtSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: context.brdr),
          const SizedBox(height: 8),

          // 2. The 4 Screen Router Items
          _buildMenuItem(
            context,
            title: 'My Profile',
            icon: LucideIcons.user,
            route: '/student/profile',
            tabIndex: 1,
          ),
          _buildMenuItem(
            context,
            title: 'Applied Projects',
            icon: LucideIcons.clipboardCheck,
            route: '/student/applied-projects',
          ),
          _buildMenuItem(
            context,
            title: 'Certificates',
            icon: LucideIcons.award,
            route: '/student/certificates',
          ),
          _buildMenuItem(
            context,
            title: 'Settings',
            icon: LucideIcons.settings,
            route: '/student/settings',
          ),

          const SizedBox(height: 4),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 4),

          // 3. Logout Action Button matching Image
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _confirmAndLogout(context),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: const [
                    Icon(
                      LucideIcons.logOut,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
    int? tabIndex,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          if (tabIndex != null) {
            try {
              context.read<StudentDashboardBloc>().add(ChangeStudentTabEvent(tabIndex));
            } catch (_) {}
          }

          switch (route) {
            case '/student/dashboard':
            case '/student/profile':
            case '/student/projects':
            case '/student/notifications':
              context.go(route);
              break;
            default:
              context.push(route);
              break;
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: context.txtSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.txtPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndLogout(BuildContext context) async {
    HapticFeedback.lightImpact();
    final router = GoRouter.of(context);

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(LucideIcons.logOut, color: AppColors.error, size: 22),
              SizedBox(width: 10),
              Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: const Text(
            'Are you sure you want to log out of Campus2Corporate?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  const storage = FlutterSecureStorage();
                  await storage.delete(key: 'jwt_token');
                  await storage.deleteAll();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                } catch (_) {}

                router.go('/auth/role-select');
              },
              child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
