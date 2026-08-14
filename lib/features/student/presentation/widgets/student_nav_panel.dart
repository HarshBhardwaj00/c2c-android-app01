import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/student_bloc.dart';

/// Navigation item data model
class _NavItemData {
  final String title;
  final IconData icon;
  final String route;
  final int? tabIndex;
  final int? badgeCount;

  const _NavItemData({
    required this.title,
    required this.icon,
    required this.route,
    this.tabIndex,
    this.badgeCount,
  });
}

/// 100% Figma-Fidelity Navigation Panel Widget matching Image 2 specifications.
/// Displays routes to all Student module screens with active states, badges, and adaptive popping.
class StudentNavPanel extends StatelessWidget {
  final String activeRoute;
  final int appliedCount;
  final int notificationCount;
  final Function(String route)? onNavigate;

  const StudentNavPanel({
    super.key,
    this.activeRoute = '/student/dashboard',
    this.appliedCount = 2,
    this.notificationCount = 3,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = screenWidth > 600 ? 320.0 : (screenWidth * 0.78).clamp(260.0, 310.0);

    final items = [
      _NavItemData(
        title: 'Dashboard',
        icon: LucideIcons.layoutGrid,
        route: '/student/dashboard',
        tabIndex: 0,
      ),
      _NavItemData(
        title: 'My Profile',
        icon: LucideIcons.userCheck,
        route: '/student/profile',
        tabIndex: 1,
      ),
      _NavItemData(
        title: 'Project List',
        icon: LucideIcons.briefcase,
        route: '/student/projects',
        tabIndex: 2,
      ),
      _NavItemData(
        title: 'Applied Projects',
        icon: LucideIcons.clipboardCheck,
        route: '/student/applied-projects',
        badgeCount: appliedCount,
      ),
      _NavItemData(
        title: 'Hiring Process',
        icon: LucideIcons.building2,
        route: '/student/hiring-process',
      ),
      _NavItemData(
        title: 'Notifications',
        icon: LucideIcons.bell,
        route: '/student/notifications',
        tabIndex: 3,
        badgeCount: notificationCount,
      ),
      _NavItemData(
        title: 'Certificates',
        icon: LucideIcons.award,
        route: '/student/certificates',
      ),
      _NavItemData(
        title: 'Settings',
        icon: LucideIcons.settings,
        route: '/student/settings',
      ),
      _NavItemData(
        title: 'AI Resume Builder',
        icon: LucideIcons.fileText,
        route: '/student/ai-resume-builder',
      ),
    ];

    return Container(
      width: panelWidth,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom == 0 ? 16.0 : MediaQuery.of(context).padding.bottom,
        top: 16.0,
        left: 14.0,
        right: 14.0,
      ),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.35 : 0.12),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: context.brdr,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Logo & Quick Title
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12, top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.compass,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Navigation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: context.txtPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.brdr),
          const SizedBox(height: 10),

          // Dynamic Navigation Items List
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: items.map((item) {
                  final isSelected = activeRoute == item.route;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleItemTap(context, item),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2563EB) // Primary Blue matching Image 2
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 19,
                                color: isSelected
                                    ? Colors.white
                                    : context.txtSecondary,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: AutoSizeText(
                                  item.title,
                                  maxLines: 1,
                                  minFontSize: 12,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : context.txtPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),

                              // Optional Pill Badge
                              if (item.badgeCount != null && item.badgeCount! > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${item.badgeCount}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleItemTap(BuildContext context, _NavItemData item) {
    HapticFeedback.lightImpact();

    // Close open navigation modal if applicable
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (onNavigate != null) {
      onNavigate!(item.route);
      return;
    }

    // Handle BLoC Tab switching if applicable
    if (item.tabIndex != null) {
      try {
        final bloc = context.read<StudentDashboardBloc>();
        bloc.add(ChangeStudentTabEvent(item.tabIndex!));
      } catch (_) {}
    }

    // Route handling via GoRouter
    switch (item.route) {
      case '/student/dashboard':
      case '/student/profile':
      case '/student/projects':
      case '/student/notifications':
        context.go(item.route);
        break;
      case '/student/ai-resume-builder':
        context.push('/student/ai-resume');
        break;
      default:
        context.push(item.route);
        break;
    }
  }
}

/// Helper function to present the Navigation Panel anchored at the top-left of the screen
void showStudentNavPanel(
  BuildContext context, {
  String activeRoute = '/student/dashboard',
  int appliedCount = 2,
  int notificationCount = 3,
}) {
  HapticFeedback.lightImpact();
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss Navigation Panel',
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 12),
            child: Material(
              color: Colors.transparent,
              child: StudentNavPanel(
                activeRoute: activeRoute,
                appliedCount: appliedCount,
                notificationCount: notificationCount,
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
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.3, -0.05),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );
    },
  );
}
