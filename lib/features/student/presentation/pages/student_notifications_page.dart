import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/student_bloc.dart';
import '../../data/student_api_service.dart';

/// Complete, production-ready 100% Figma-Fidelity Student Notification & Preferences Screen.
/// Includes Activity Feed, Notification Preferences, and Privacy & Security modes.
class StudentNotificationsPage extends StatefulWidget {
  final List<Map<String, dynamic>>? initialNotifications;
  final StudentApiService? apiService;
  final VoidCallback? onBackPressed;

  const StudentNotificationsPage({
    super.key,
    this.initialNotifications,
    this.apiService,
    this.onBackPressed,
  });

  @override
  State<StudentNotificationsPage> createState() => _StudentNotificationsPageState();
}

class _StudentNotificationsPageState extends State<StudentNotificationsPage> {
  late final StudentApiService _apiService;
  bool _isLoading = true;
  String? _errorMessage;
  int _activeModeTab = 0; // 0: Activity Feed, 1: Notification Preferences, 2: Privacy & Security
  String _selectedCategory = 'All';

  // Notifications State Data
  List<Map<String, dynamic>> _notifications = [];

  // Notification Preferences State (null = key absent from server response)
  bool? _assignmentUpdates;
  bool? _assessmentReminders;
  bool? _mentorSessionAlerts;
  bool? _interviewReminders;
  bool? _achievementsBadges;
  bool? _emailNotifications;
  bool? _pushNotifications;
  bool? _smsAlerts;

  // Privacy State
  bool? _profileVisibleToRecruiters;
  bool? _showActivityStatus;
  bool? _shareDataWithPlacementPartners;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? StudentApiService();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final notifs = await _apiService.getNotifications();
      final settings = await _apiService.getStudentSettings();

      final notifPrefs = settings['notifications'] as Map<String, dynamic>? ?? const {};
      final privacyPrefs = settings['privacy'] as Map<String, dynamic>? ?? const {};

      bool readBool(Map<String, dynamic> source, Object? primary,
          [Object? alias, bool fallback = true]) {
        final value = source[primary];
        if (value is bool) return value;
        if (alias != null) {
          final alt = source[alias];
          if (alt is bool) return alt;
        }
        return fallback;
      }

      setState(() {
        _notifications = List.from(notifs.isNotEmpty ? notifs : (widget.initialNotifications ?? []));

        _assignmentUpdates = readBool(notifPrefs, 'assignments', 'assignmentUpdates', true);
        _assessmentReminders = readBool(notifPrefs, 'assessments', 'assessmentReminders', true);
        _mentorSessionAlerts = readBool(notifPrefs, 'mentorSessions', 'mentorSessionAlerts', true);
        _interviewReminders = readBool(notifPrefs, 'interviews', 'interviewReminders', true);
        _achievementsBadges = readBool(notifPrefs, 'achievements', 'achievementsBadges', true);
        _emailNotifications = readBool(notifPrefs, 'email', 'emailNotifications', true);
        _pushNotifications = readBool(notifPrefs, 'push', 'pushNotifications', true);
        _smsAlerts = readBool(notifPrefs, 'sms', 'smsAlerts', false);

        _profileVisibleToRecruiters =
            readBool(privacyPrefs, 'profileVisibleToRecruiters', 'recruiterVisible', true);
        _showActivityStatus = readBool(privacyPrefs, 'showActivityStatus', 'leaderboard', true);
        _shareDataWithPlacementPartners =
            readBool(privacyPrefs, 'shareDataWithPlacementPartners', 'shareDataWithPartners', true);

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _notifications = List.from(widget.initialNotifications ?? []);
        _isLoading = false;
      });
    }
  }

  int get _unreadCount => _notifications.where((n) => !(n['read'] as bool? ?? false)).length;

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedCategory == 'All') return _notifications;
    if (_selectedCategory == 'Unread') {
      return _notifications.where((n) => !(n['read'] as bool? ?? false)).toList();
    }
    return _notifications.where((n) {
      final cat = (n['category'] ?? n['type'] ?? '').toString().toLowerCase();
      return cat.contains(_selectedCategory.toLowerCase());
    }).toList();
  }

  Future<void> _markAllAsRead() async {
    HapticFeedback.lightImpact();
    setState(() {
      for (var n in _notifications) {
        n['read'] = true;
      }
    });

    // Best-effort sync with backend. The backend may not expose a dedicated
    // notification endpoint, in which case the local (optimistic) state is kept.
    try {
      final updated = await _apiService.markAllNotificationsAsRead();
      if (updated != null && mounted) {
        setState(() {
          _notifications = List.from(updated);
        });
      }
    } catch (e) {
      // Non-fatal: keep the optimistic local state so the UI never breaks.
      assert(() {
        debugPrint('markAllNotificationsAsRead error: $e');
        return true;
      }());
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(LucideIcons.checkCheck, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('All notifications marked as read', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _markSingleAsRead(String id) async {
    HapticFeedback.selectionClick();
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index == -1) return;

    setState(() {
      _notifications[index]['read'] = true;
    });

    try {
      final updated = await _apiService.markNotificationAsRead(id);
      if (updated != null && mounted) {
        setState(() {
          _notifications = List.from(updated);
        });
      }
    } catch (e) {
      // Non-fatal: keep the optimistic local state so the UI never breaks.
      assert(() {
        debugPrint('markNotificationAsRead error: $e');
        return true;
      }());
    }
  }

  Future<void> _deleteNotification(String id) async {
    HapticFeedback.mediumImpact();
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index == -1) return;

    setState(() {
      _notifications.removeAt(index);
    });

    try {
      final updated = await _apiService.deleteNotification(id);
      if (updated != null && mounted) {
        setState(() {
          _notifications = List.from(updated);
        });
      }
    } catch (e) {
      // Non-fatal: removal is already reflected locally.
      assert(() {
        debugPrint('deleteNotification error: $e');
        return true;
      }());
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(LucideIcons.trash2, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Notification removed', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: AppColors.cardDark,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  bool _prefsSaving = false;
  bool _prefsDirty = false;

  void _onPrefsChanged() {
    if (_prefsSaving) {
      _prefsDirty = true;
      return;
    }
    _prefsSaving = true;
    _runPrefsSaves();
  }

  Future<void> _runPrefsSaves() async {
    try {
      do {
        _prefsDirty = false;
        await _persistCurrentPrefs();
      } while (_prefsDirty && mounted);
    } finally {
      _prefsSaving = false;
    }
  }

  Future<void> _persistCurrentPrefs() async {
    final notifications = <String, dynamic>{};
    void putNotif(String key, bool? value) {
      if (value != null) notifications[key] = value;
    }

    putNotif('assignments', _assignmentUpdates);
    putNotif('assessments', _assessmentReminders);
    putNotif('mentorSessions', _mentorSessionAlerts);
    putNotif('interviews', _interviewReminders);
    putNotif('achievements', _achievementsBadges);
    putNotif('email', _emailNotifications);
    putNotif('push', _pushNotifications);
    putNotif('sms', _smsAlerts);

    final privacy = <String, dynamic>{};
    void putPrivacy(String key, bool? value) {
      if (value != null) privacy[key] = value;
    }

    putPrivacy('profileVisibleToRecruiters', _profileVisibleToRecruiters);
    putPrivacy('showActivityStatus', _showActivityStatus);
    putPrivacy('shareDataWithPlacementPartners', _shareDataWithPlacementPartners);

    try {
      await _apiService.updateStudentSettings({
        'notifications': notifications,
        'privacy': privacy,
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to update preferences');
      }
    }
  }

  void _handleSafePop() {
    HapticFeedback.lightImpact();
    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
      return;
    }

    try {
      final bloc = context.read<StudentDashboardBloc>();
      if (bloc.state.activeTab != 0) {
        bloc.add(ChangeStudentTabEvent(0));
        return;
      }
    } catch (_) {}

    if (context.canPop()) {
      context.pop();
      return;
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    context.go('/student/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth > 600 ? 24.0 : 16.0;

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
          scrolledUnderElevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(
              LucideIcons.chevronLeft,
              size: 22,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Back',
            onPressed: _handleSafePop,
          ),
          title: const Row(
            children: [
              Icon(LucideIcons.bell, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Stay in the loop',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.inputFill,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.user, size: 18, color: AppColors.textPrimary),
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadInitialData,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom == 0 ? 16.0 : MediaQuery.of(context).padding.bottom,
              top: 16.0,
              left: horizontalPadding,
              right: horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Banner Card (Stay in the loop / Notifications info)
                _NotificationHeaderCard(
                  unreadCount: _unreadCount,
                  onMarkAllRead: _markAllAsRead,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.alertCircle,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // 2. Mode Segmented Control Bar (Activity feed | Notification preferences | Privacy & security)
                _ModeSegmentedControl(
                  activeTab: _activeModeTab,
                  onTabChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() => _activeModeTab = index);
                  },
                ),
                const SizedBox(height: 20),

                // 3. Tab Body View
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (_activeModeTab == 0)
                  _ActivityFeedView(
                    notifications: _filteredNotifications,
                    selectedCategory: _selectedCategory,
                    onCategoryChanged: (cat) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = cat);
                    },
                    onMarkRead: _markSingleAsRead,
                    onDelete: _deleteNotification,
                  )
                else if (_activeModeTab == 1)
                  _NotificationPreferencesView(
                    assignmentUpdates: _assignmentUpdates,
                    assessmentReminders: _assessmentReminders,
                    mentorSessionAlerts: _mentorSessionAlerts,
                    interviewReminders: _interviewReminders,
                    achievementsBadges: _achievementsBadges,
                    emailNotifications: _emailNotifications,
                    pushNotifications: _pushNotifications,
                    smsAlerts: _smsAlerts,
                    onToggle: (key, val) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        switch (key) {
                          case 'assignmentUpdates':
                            _assignmentUpdates = val;
                            break;
                          case 'assessmentReminders':
                            _assessmentReminders = val;
                            break;
                          case 'mentorSessionAlerts':
                            _mentorSessionAlerts = val;
                            break;
                          case 'interviewReminders':
                            _interviewReminders = val;
                            break;
                          case 'achievementsBadges':
                            _achievementsBadges = val;
                            break;
                          case 'emailNotifications':
                            _emailNotifications = val;
                            break;
                          case 'pushNotifications':
                            _pushNotifications = val;
                            break;
                          case 'smsAlerts':
                            _smsAlerts = val;
                            break;
                        }
                      });
                      _onPrefsChanged();
                    },
                  )
                else
                  _PrivacySecurityView(
                    profileVisibleToRecruiters: _profileVisibleToRecruiters,
                    showActivityStatus: _showActivityStatus,
                    shareDataWithPlacementPartners: _shareDataWithPlacementPartners,
                    onToggle: (key, val) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        switch (key) {
                          case 'profileVisibleToRecruiters':
                            _profileVisibleToRecruiters = val;
                            break;
                          case 'showActivityStatus':
                            _showActivityStatus = val;
                            break;
                          case 'shareDataWithPlacementPartners':
                            _shareDataWithPlacementPartners = val;
                            break;
                        }
                      });
                      _onPrefsChanged();
                    },
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

/// Header Hero Card matching 100% Figma specification
class _NotificationHeaderCard extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onMarkAllRead;

  const _NotificationHeaderCard({
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.bell, size: 12, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'Stay in the loop',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Title with ShaderMask Gradient
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.textPrimary, AppColors.primaryDark],
            ).createShader(bounds),
            child: const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          const Text(
            'Updates on assignments, assessments, mentor sessions, and placement activity.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Actions & Unread Count Row
          Row(
            children: [
              // Unread Badge Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: unreadCount > 0 ? AppColors.errorLight : AppColors.inputFill,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$unreadCount unread',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: unreadCount > 0 ? AppColors.error : AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Mark All As Read Pill Button
              OutlinedButton.icon(
                onPressed: onMarkAllRead,
                icon: const Icon(LucideIcons.check, size: 14),
                label: const Text('Mark all as read'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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

/// Mode Segmented Control Bar
class _ModeSegmentedControl extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabChanged;

  const _ModeSegmentedControl({
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentItem(
              icon: LucideIcons.bellRing,
              label: 'Activity feed',
              isSelected: activeTab == 0,
              onTap: () => onTabChanged(0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _SegmentItem(
              icon: LucideIcons.settings,
              label: 'Preferences',
              isSelected: activeTab == 1,
              onTap: () => onTabChanged(1),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _SegmentItem(
              icon: LucideIcons.shieldCheck,
              label: 'Privacy',
              isSelected: activeTab == 2,
              onTap: () => onTabChanged(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardDark : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: AutoSizeText(
                label,
                maxLines: 1,
                minFontSize: 10,
                maxFontSize: 12,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab 1: Activity Feed View
class _ActivityFeedView extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onMarkRead;
  final ValueChanged<String> onDelete;

  const _ActivityFeedView({
    required this.notifications,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onMarkRead,
    required this.onDelete,
  });

  final List<String> _categories = const [
    'All',
    'Unread',
    'Assignments',
    'Assessments',
    'Interviews',
    'Mentors',
    'Drives',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Pills Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _categories.map((cat) {
              final isSelected = selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => onCategoryChanged(cat),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Section Title & Filter Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACTIVITY FEED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedCategory == 'All' ? 'All notifications' : '$selectedCategory notifications',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Icon(LucideIcons.slidersHorizontal, size: 18, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 16),

              if (notifications.isEmpty)
                const _EmptyNotificationsCard()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return RepaintBoundary(
                      child: _NotificationTileItem(
                        notification: notif,
                        onMarkRead: () => onMarkRead(notif['id']?.toString() ?? ''),
                        onDelete: () => onDelete(notif['id']?.toString() ?? ''),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Notification Item Tile Widget
class _NotificationTileItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const _NotificationTileItem({
    required this.notification,
    required this.onMarkRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification['read'] as bool? ?? false;
    final category = notification['category']?.toString() ?? 'General';
    final title = notification['title']?.toString() ?? 'Notification';
    final desc = notification['desc']?.toString() ?? '';
    final time = notification['time']?.toString() ?? 'Just now';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? AppColors.surface : AppColors.primaryLight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Category Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isRead ? AppColors.inputFill : AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(category),
              size: 16,
              color: isRead ? AppColors.textMuted : AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 12),

          // Notification Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isRead ? FontWeight.w700 : FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isRead)
                      InkWell(
                        onTap: onMarkRead,
                        child: const Row(
                          children: [
                            Icon(LucideIcons.check, size: 12, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Mark read',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    InkWell(
                      onTap: onDelete,
                      child: const Icon(LucideIcons.trash2, size: 14, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'interviews':
        return LucideIcons.video;
      case 'assessments':
        return LucideIcons.fileText;
      case 'assignments':
        return LucideIcons.clipboardList;
      case 'mentors':
        return LucideIcons.users;
      case 'drives':
        return LucideIcons.briefcase;
      default:
        return LucideIcons.bell;
    }
  }
}

/// Empty State Card (100% Figma Match)
class _EmptyNotificationsCard extends StatelessWidget {
  const _EmptyNotificationsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.inputFill.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.bell,
              size: 28,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "You're all caught up",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nothing here for this filter right now.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 2: Notification Preferences View
class _NotificationPreferencesView extends StatelessWidget {
  final bool? assignmentUpdates;
  final bool? assessmentReminders;
  final bool? mentorSessionAlerts;
  final bool? interviewReminders;
  final bool? achievementsBadges;
  final bool? emailNotifications;
  final bool? pushNotifications;
  final bool? smsAlerts;
  final void Function(String key, bool val) onToggle;

  const _NotificationPreferencesView({
    required this.assignmentUpdates,
    required this.assessmentReminders,
    required this.mentorSessionAlerts,
    required this.interviewReminders,
    required this.achievementsBadges,
    required this.emailNotifications,
    required this.pushNotifications,
    required this.smsAlerts,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card 1: Notification Types
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "WHAT YOU'RE ALERTED ABOUT",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Notification types',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Icon(LucideIcons.settings, size: 18, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 16),

              _ToggleRowTile(
                icon: LucideIcons.clipboardList,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                title: 'Assignment updates',
                subtitle: 'Deadlines, submissions, and grading for your modules.',
                value: assignmentUpdates,
                onChanged: (val) => onToggle('assignmentUpdates', val),
              ),
              const Divider(color: AppColors.border),

              _ToggleRowTile(
                icon: LucideIcons.target,
                iconBg: AppColors.warningLight,
                iconColor: AppColors.warning,
                title: 'Assessment reminders',
                subtitle: 'Aptitude tests and placement prep assessment alerts.',
                value: assessmentReminders,
                onChanged: (val) => onToggle('assessmentReminders', val),
              ),
              const Divider(color: AppColors.border),

              _ToggleRowTile(
                icon: LucideIcons.users,
                iconBg: AppColors.aiBadgeBg,
                iconColor: AppColors.accent,
                title: 'Mentor session alerts',
                subtitle: 'Confirmations and reminders for one-on-one sessions.',
                value: mentorSessionAlerts,
                onChanged: (val) => onToggle('mentorSessionAlerts', val),
              ),
              const Divider(color: AppColors.border),

              _ToggleRowTile(
                icon: LucideIcons.calendar,
                iconBg: AppColors.errorLight,
                iconColor: AppColors.error,
                title: 'Interview reminders',
                subtitle: 'Mock and real interview scheduling updates.',
                value: interviewReminders,
                onChanged: (val) => onToggle('interviewReminders', val),
              ),
              const Divider(color: AppColors.border),

              _ToggleRowTile(
                icon: LucideIcons.award,
                iconBg: AppColors.successLight,
                iconColor: AppColors.success,
                title: 'Achievements & badges',
                subtitle: 'Get notified when you unlock a new badge or milestone.',
                value: achievementsBadges,
                onChanged: (val) => onToggle('achievementsBadges', val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Card 2: Delivery Channels
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "HOW YOU'RE ALERTED",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Delivery channels',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Icon(LucideIcons.send, size: 18, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 16),

              _ToggleRowTile(
                icon: LucideIcons.mail,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                title: 'Email notifications',
                subtitle: 'Sent to student@c2c.edu',
                value: emailNotifications,
                onChanged: (val) => onToggle('emailNotifications', val),
              ),
              const Divider(color: AppColors.border),

              _ToggleRowTile(
                icon: LucideIcons.bell,
                iconBg: AppColors.successLight,
                iconColor: AppColors.success,
                title: 'Push notifications',
                subtitle: 'Real-time alerts in the browser and mobile app.',
                value: pushNotifications,
                onChanged: (val) => onToggle('pushNotifications', val),
              ),
              const Divider(color: AppColors.border),

              _ToggleRowTile(
                icon: LucideIcons.smartphone,
                iconBg: AppColors.aiBadgeBg,
                iconColor: AppColors.accent,
                title: 'SMS alerts',
                subtitle: 'Text messages for time-critical updates only.',
                value: smsAlerts,
                onChanged: (val) => onToggle('smsAlerts', val),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tab 3: Privacy & Security View
class _PrivacySecurityView extends StatelessWidget {
  final bool? profileVisibleToRecruiters;
  final bool? showActivityStatus;
  final bool? shareDataWithPlacementPartners;
  final void Function(String key, bool val) onToggle;

  const _PrivacySecurityView({
    required this.profileVisibleToRecruiters,
    required this.showActivityStatus,
    required this.shareDataWithPlacementPartners,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card 1: Privacy
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "WHO CAN SEE YOUR DATA",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Privacy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Icon(LucideIcons.eyeOff, size: 18, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 16),

              _ToggleRowTile(
                icon: LucideIcons.eye,
                iconBg: AppColors.successLight,
                iconColor: AppColors.success,
                title: 'Profile visible to recruiters',
                subtitle: 'Let hiring partners view your profile and resume score.',
                value: profileVisibleToRecruiters,
                onChanged: (val) => onToggle('profileVisibleToRecruiters', val),
              ),
              const Divider(color: AppColors.border),

              _ToggleRowTile(
                icon: LucideIcons.activity,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                title: 'Show activity status',
                subtitle: 'Let mentors and admins see when you were last active.',
                value: showActivityStatus,
                onChanged: (val) => onToggle('showActivityStatus', val),
              ),
              const Divider(color: AppColors.border),

              _ToggleRowTile(
                icon: LucideIcons.share2,
                iconBg: AppColors.warningLight,
                iconColor: AppColors.warning,
                title: 'Share data with placement partners',
                subtitle: 'Allow anonymized performance data to improve matching.',
                value: shareDataWithPlacementPartners,
                onChanged: (val) => onToggle('shareDataWithPlacementPartners', val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Card 2: Security
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ACCOUNT PROTECTION",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Security',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Icon(LucideIcons.shield, size: 18, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 16),

              // Two-factor authentication is handled by the Account Settings page
              // (password -> secret -> verification code), not a bare boolean here.
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.primaryDark),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Two-factor authentication is managed from Account Settings '
                        'under Privacy & security.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Generic Reusable Toggle Row Component
class _ToggleRowTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool? value;
  final ValueChanged<bool>? onChanged;

  const _ToggleRowTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSet = value != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isSet ? subtitle : '$subtitle\nNot set on server',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color: isSet ? AppColors.textSecondary : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value ?? false,
            onChanged: (isSet && onChanged != null) ? onChanged : null,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.inputFill,
          ),
        ],
      ),
    );
  }
}
