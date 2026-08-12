import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/constants/app_colors.dart';
import 'student_nav_panel.dart';
import 'student_profile_menu_pill.dart';

class StudentHeader extends StatelessWidget {
  final VoidCallback onAskAiPressed;
  final VoidCallback onSearchPressed;
  final VoidCallback onNotificationPressed;
  final int unreadCount;
  final String userName;
  final String userEmail;

  const StudentHeader({
    super.key,
    required this.onAskAiPressed,
    required this.onSearchPressed,
    required this.onNotificationPressed,
    this.unreadCount = 3,
    this.userName = 'hh',
    this.userEmail = 'harshbhara70@gmail.com',
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;
    final horizontalPadding = isCompact ? 10.0 : (screenWidth > 600 ? 24.0 : 16.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 8,
      ),
      child: Row(
        children: [
          // Left: User Initial Avatar Badge with Navigation Panel Launcher
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => showStudentNavPanel(
                context,
                notificationCount: unreadCount,
              ),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: isCompact ? 34 : 38,
                height: isCompact ? 34 : 38,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'C',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: isCompact ? 15 : 18,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: isCompact ? 6 : 10),

          // Title & Subtitle Block - Clickable to open Navigation Panel
          Expanded(
            child: InkWell(
              onTap: () => showStudentNavPanel(
                context,
                notificationCount: unreadCount,
              ),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Flexible(
                          child: AutoSizeText(
                            'C2C Student',
                            maxLines: 1,
                            minFontSize: 12,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevronDown,
                          size: 14,
                          color: AppColors.primary.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                    Text(
                      'CAMPUS2CORPORATE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isCompact ? 8 : 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted.withValues(alpha: 0.9),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Action Row - Wrapped in FittedBox to guarantee zero overflow on narrow screens
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Action Icon
                IconButton(
                  onPressed: onSearchPressed,
                  icon: const Icon(
                    LucideIcons.search,
                    size: 19,
                    color: AppColors.textPrimary,
                  ),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  tooltip: 'Search Portal',
                ),
                SizedBox(width: isCompact ? 2 : 4),

                // Notification Bell Icon with Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: onNotificationPressed,
                      icon: const Icon(
                        LucideIcons.bell,
                        size: 19,
                        color: AppColors.textPrimary,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      tooltip: 'Notifications',
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: isCompact ? 4 : 8),

                // "Ask AI" Pill Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAskAiPressed,
                    borderRadius: BorderRadius.circular(24),
                    child: Ink(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 10 : 13,
                        vertical: isCompact ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.sparkles,
                            size: 13,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Ask AI',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isCompact ? 4 : 8),

                // Top Right Profile Pill Button with Dropdown Menu (4 routers + Logout)
                StudentProfileMenuPill(
                  userName: userName,
                  userEmail: userEmail,
                  avatarInitial: userName.isNotEmpty ? userName[0].toUpperCase() : 'H',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
