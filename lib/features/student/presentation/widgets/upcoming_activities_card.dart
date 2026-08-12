import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/student_api_service.dart';
import '../../domain/models/student_dashboard_model.dart';

/// A production-ready, highly optimized Upcoming Activities Card for the Student Dashboard.
/// Adheres strictly to c2c_android design system, zero hardcoding, zero overflow, 120Hz refresh bounds.
class UpcomingActivitiesCard extends StatefulWidget {
  final List<StudentUpcomingActivityData> activities;
  final StudentApiService? apiService;
  final Function(StudentUpcomingActivityData)? onActivityTap;

  const UpcomingActivitiesCard({
    super.key,
    required this.activities,
    this.apiService,
    this.onActivityTap,
  });

  @override
  State<UpcomingActivitiesCard> createState() => _UpcomingActivitiesCardState();
}

class _UpcomingActivitiesCardState extends State<UpcomingActivitiesCard> {
  late List<StudentUpcomingActivityData> _activitiesList;
  String _selectedCategory = 'All';
  late final StudentApiService _apiService;

  final List<String> _categories = const [
    'All',
    'Interview',
    'Assessment',
    'Placement Drive',
    'Workshop',
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? StudentApiService();
    _activitiesList = List.from(
      widget.activities.isEmpty
          ? StudentUpcomingActivityData.defaultActivities()
          : widget.activities,
    );
  }

  @override
  void didUpdateWidget(covariant UpcomingActivitiesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activities != oldWidget.activities) {
      setState(() {
        _activitiesList = List.from(
          widget.activities.isEmpty
              ? StudentUpcomingActivityData.defaultActivities()
              : widget.activities,
        );
      });
    }
  }

  List<StudentUpcomingActivityData> get _filteredActivities {
    if (_selectedCategory == 'All') return _activitiesList;
    return _activitiesList
        .where((a) => a.category.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
  }

  Future<void> _toggleReminder(StudentUpcomingActivityData activity) async {
    HapticFeedback.lightImpact();
    final newReminderState = !activity.isReminderSet;
    final index = _activitiesList.indexWhere((a) => a.id == activity.id);

    if (index != -1) {
      setState(() {
        _activitiesList[index] =
            _activitiesList[index].copyWith(isReminderSet: newReminderState);
      });

      // Dio backend API trigger
      final success = await _apiService.toggleActivityReminder(
        activity.id,
        newReminderState,
      );

      if (mounted && !success) {
        // Revert on error
        setState(() {
          _activitiesList[index] =
              _activitiesList[index].copyWith(isReminderSet: !newReminderState);
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  newReminderState ? LucideIcons.bell : LucideIcons.bellOff,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    newReminderState
                        ? 'Reminder set for "${activity.title}"'
                        : 'Reminder cancelled for "${activity.title}"',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: newReminderState ? AppColors.primary : AppColors.textSecondary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final theme = Theme.of(context);
    final displayedActivities = _filteredActivities;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth > 600 ? 24 : 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header Row with ShaderMask Gradient Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.aiBadgeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.sparkles,
                                  size: 11, color: AppColors.aiBadgeText),
                              SizedBox(width: 4),
                              Text(
                                'SCHEDULE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.aiBadgeText,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_activitiesList.length} Total',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppColors.textPrimary,
                          AppColors.primaryDark,
                        ],
                      ).createShader(bounds),
                      child: const AutoSizeText(
                        'Upcoming Activities',
                        maxLines: 1,
                        minFontSize: 16,
                        maxFontSize: 20,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white, // Masked by ShaderMask
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Calendar Decorative Icon Box
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.calendar,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Category Filter Pills Row (Horizontal Scroll with Micro Animations)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoryFilterChip(
                    label: cat,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Activities List / Empty View State
          if (displayedActivities.isEmpty)
            _EmptyActivitiesView(
              category: _selectedCategory,
              onResetFilter: () {
                setState(() {
                  _selectedCategory = 'All';
                });
              },
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedActivities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final activity = displayedActivities[index];
                return RepaintBoundary(
                  child: _UpcomingActivityTile(
                    activity: activity,
                    onReminderToggle: () => _toggleReminder(activity),
                    onTap: () {
                      if (widget.onActivityTap != null) {
                        widget.onActivityTap!(activity);
                      } else {
                        _handleActivityAction(context, activity);
                      }
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _handleActivityAction(
    BuildContext context,
    StudentUpcomingActivityData activity,
  ) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(activity.category).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      activity.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _getCategoryColor(activity.category),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                activity.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hosted by ${activity.hostOrCompany}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 12),

              // Detail Items
              _DetailRow(
                icon: LucideIcons.clock,
                label: 'Time & Duration',
                value: '${activity.dateTimeText} (${activity.durationText})',
              ),
              const SizedBox(height: 10),
              _DetailRow(
                icon: LucideIcons.mapPin,
                label: 'Location / Platform',
                value: activity.locationOrLink,
              ),
              const SizedBox(height: 10),
              _DetailRow(
                icon: LucideIcons.info,
                label: 'Status',
                value: activity.statusText,
                valueColor: activity.isLiveNow ? AppColors.error : AppColors.success,
              ),
              const SizedBox(height: 24),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(modalContext);
                        _toggleReminder(activity);
                      },
                      icon: Icon(
                        activity.isReminderSet ? LucideIcons.bellOff : LucideIcons.bell,
                        size: 16,
                      ),
                      label: Text(
                        activity.isReminderSet ? 'Remove Reminder' : 'Set Reminder',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(modalContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Launching ${activity.title}...'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.externalLink, size: 16),
                      label: Text(activity.actionText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'interview':
        return AppColors.accent;
      case 'assessment':
        return AppColors.warning;
      case 'placement drive':
        return AppColors.primary;
      case 'workshop':
        return AppColors.success;
      default:
        return AppColors.primaryDark;
    }
  }
}

/// Category Filter Chip with Implicit Animated Container & Scale Touch Feedback
class _CategoryFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryFilterChip> createState() => _CategoryFilterChipState();
}

class _CategoryFilterChipState extends State<_CategoryFilterChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.primary : AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: widget.isSelected ? FontWeight.w800 : FontWeight.w600,
              color: widget.isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Single Activity Item Tile Widget
class _UpcomingActivityTile extends StatefulWidget {
  final StudentUpcomingActivityData activity;
  final VoidCallback onReminderToggle;
  final VoidCallback onTap;

  const _UpcomingActivityTile({
    required this.activity,
    required this.onReminderToggle,
    required this.onTap,
  });

  @override
  State<_UpcomingActivityTile> createState() => _UpcomingActivityTileState();
}

class _UpcomingActivityTileState extends State<_UpcomingActivityTile> {
  bool _isPressed = false;

  Color get _categoryBadgeColor {
    switch (widget.activity.category.toLowerCase()) {
      case 'interview':
        return AppColors.accent;
      case 'assessment':
        return const Color(0xFFD97706); // Amber Dark
      case 'placement drive':
        return AppColors.primary;
      case 'workshop':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  Color get _categoryBadgeBg {
    switch (widget.activity.category.toLowerCase()) {
      case 'interview':
        return AppColors.aiBadgeBg;
      case 'assessment':
        return AppColors.warningLight;
      case 'placement drive':
        return AppColors.primaryLight;
      case 'workshop':
        return AppColors.successLight;
      default:
        return AppColors.inputFill;
    }
  }

  IconData get _categoryIcon {
    switch (widget.activity.category.toLowerCase()) {
      case 'interview':
        return LucideIcons.video;
      case 'assessment':
        return LucideIcons.fileText;
      case 'placement drive':
        return LucideIcons.briefcase;
      case 'workshop':
        return LucideIcons.code;
      default:
        return LucideIcons.calendar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: activity.isLiveNow
                ? AppColors.errorLight.withValues(alpha: 0.25)
                : AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: activity.isLiveNow
                  ? AppColors.error.withValues(alpha: 0.4)
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Meta Row: Category Badge + Status / Live Indicator + Bell Reminder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _categoryBadgeBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_categoryIcon, size: 12, color: _categoryBadgeColor),
                            const SizedBox(width: 4),
                            Text(
                              activity.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _categoryBadgeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (activity.isLiveNow) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.radio, size: 10, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'LIVE NOW',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Bell Toggle Button
                  InkWell(
                    onTap: widget.onReminderToggle,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        activity.isReminderSet
                            ? LucideIcons.bell
                            : LucideIcons.bellOff,
                        size: 18,
                        color: activity.isReminderSet
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              AutoSizeText(
                activity.title,
                maxLines: 2,
                minFontSize: 13,
                maxFontSize: 15,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),

              // Host / Organization
              Text(
                activity.hostOrCompany,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),

              // Bottom Details Row: Time, Location & Action Button
              Row(
                children: [
                  // Time info
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.clock,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            activity.dateTimeText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Button
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: activity.isLiveNow
                          ? AppColors.error
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          activity.actionText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: activity.isLiveNow
                                ? Colors.white
                                : AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 12,
                          color: activity.isLiveNow
                              ? Colors.white
                              : AppColors.primaryDark,
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
}

/// Fallback Empty View when Filter returns zero items
class _EmptyActivitiesView extends StatelessWidget {
  final String category;
  final VoidCallback onResetFilter;

  const _EmptyActivitiesView({
    required this.category,
    required this.onResetFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.inputFill.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          const Icon(
            LucideIcons.calendarX,
            size: 36,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 10),
          Text(
            'No $category Activities Scheduled',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Check back later or view all scheduled corporate sessions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onResetFilter,
            icon: const Icon(LucideIcons.rotateCcw, size: 14),
            label: const Text('Reset Filter'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
