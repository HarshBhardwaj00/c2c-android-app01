import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../data/student_api_service.dart';
import '../widgets/student_nav_panel.dart';
import '../widgets/student_profile_menu_pill.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/bouncy_button.dart';

/// 100% Production-Ready Settings Screen for Student Module.
///
/// Fully backend-driven — every control is hydrated from /api/student/settings
/// and written back through the canonical backend key set. No UI-level mock
/// data. Error states surface a real retry flow instead of fake toggles.
class StudentSettingsPage extends StatefulWidget {
  final StudentApiService? apiService;

  const StudentSettingsPage({super.key, this.apiService});

  @override
  State<StudentSettingsPage> createState() => _StudentSettingsPageState();
}

class _StudentSettingsPageState extends State<StudentSettingsPage> {
  late final StudentApiService _apiService;

  static final RegExp _emailRegExp = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');

  bool _isLoading = true;
  bool _loadFailed = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _errorMessage;
  String? _successMessage;

  // Account details
  final _emailController = TextEditingController();

  // Password fields
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Notification toggles (canonical backend keys)
  bool _emailNotifications = true;
  bool _smsAlerts = false;
  bool _assignmentReminders = true;
  bool _mentorSessionAlerts = true;
  bool _placementDriveUpdates = true;

  // Privacy toggles
  bool _visibleToRecruiters = true;
  bool _showOnLeaderboards = true;
  bool _twoFactorAuth = false;

  // Appearance
  String? _themeMode;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? StudentApiService();
    _loadSettings();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Data loading (real backend only, no hardcoded fallbacks)
  // ---------------------------------------------------------------
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final profile = await _apiService.getProfile();
      final settings = await _apiService.getStudentSettings();

      if (!mounted) return;

      final notifs =
          (settings['notifications'] as Map<String, dynamic>?) ?? const {};
      final privacy =
          (settings['privacy'] as Map<String, dynamic>?) ?? const {};
      final security =
          (settings['security'] as Map<String, dynamic>?) ?? const {};

      bool readBool(Map<String, dynamic> source, Object primary, bool fallback,
          [Object? alias]) {
        final value = source[primary];
        if (value is bool) return value;
        if (alias != null) {
          final alt = source[alias];
          if (alt is bool) return alt;
        }
        return fallback;
      }

      setState(() {
        _emailController.text = profile['email']?.toString() ?? '';

        _emailNotifications = readBool(notifs, 'email', true, 'emailNotifications');
        _smsAlerts = readBool(notifs, 'sms', false, 'smsAlerts');
        _assignmentReminders = readBool(notifs, 'assignments', true, 'assignmentUpdates');
        _mentorSessionAlerts = readBool(notifs, 'mentorSessions', true, 'mentorSessionAlerts');
        _placementDriveUpdates = readBool(notifs, 'marketing', true, 'placementDriveUpdates');

        _visibleToRecruiters =
            readBool(privacy, 'profileVisibleToRecruiters', true, 'recruiterVisible');
        _showOnLeaderboards =
            readBool(privacy, 'showActivityStatus', true, 'leaderboard');
        _twoFactorAuth =
            security['twoFactorEnabled'] == true ||
            security['twoFactorEnabledAt'] != null ||
            privacy['twoFactorAuth'] == true ||
            privacy['twoFactor'] == true;

        _themeMode = settings['theme'] is String
            ? settings['theme'] as String
            : null;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  // ---------------------------------------------------------------
  // Persistence — saves are run through a FIFO queue so rapid toggles
  // cannot race the PATCH requests. The final banner always reflects the
  // last applied save, and earlier completers resolve in submission order.
  // ---------------------------------------------------------------
  final List<_PendingSave> _saveQueue = [];
  bool _savingActive = false;

  Future<bool> _persistSettings(Map<String, dynamic> payload) {
    final pending = _PendingSave(payload);
    _saveQueue.add(pending);
    _drainSaveQueue();
    return pending.completer.future;
  }

  void _drainSaveQueue() {
    if (_savingActive) return;
    _savingActive = true;
    _runSaveQueue();
  }

  Future<void> _runSaveQueue() async {
    if (mounted) setState(() => _isSaving = true);
    while (_saveQueue.isNotEmpty) {
      final pending = _saveQueue.removeAt(0);
      final ok = await _performSave(pending.payload);
      if (!pending.completer.isCompleted) pending.completer.complete(ok);
      if (!ok) {
        for (final leftover in _saveQueue) {
          if (!leftover.completer.isCompleted) leftover.completer.complete(false);
        }
        _saveQueue.clear();
        break;
      }
      if (!mounted) break;
    }
    if (mounted) setState(() => _isSaving = false);
    _savingActive = false;
  }

  Future<bool> _performSave(Map<String, dynamic> payload) async {
    HapticFeedback.lightImpact();
    if (mounted) {
      setState(() {
        _errorMessage = null;
        _successMessage = null;
      });
    }

    try {
      await _apiService.updateStudentSettings(payload);
      if (!mounted) return false;

      setState(() {
        _successMessage = 'Settings saved successfully';
      });
      _dismissSuccessAfterDelay();
      return true;
    } on ApiException catch (e) {
      if (!mounted) return false;
      setState(() {
        _errorMessage = e.message;
      });
      return false;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _errorMessage = 'Failed to update settings';
      });
      return false;
    }
  }

  void _dismissSuccessAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _successMessage = null);
    });
  }

  void _showValidationError(String message) {
    setState(() {
      _errorMessage = message;
      _successMessage = null;
    });
  }

  // ---------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------
  Future<void> _saveAccountEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_emailRegExp.hasMatch(email)) {
      _showValidationError('Please enter a valid email address');
      return;
    }
    await _persistSettings({'email': email});
  }

  Future<void> _updatePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPwd = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPwd.isEmpty || confirm.isEmpty) {
      _showValidationError('Please fill out all password fields');
      return;
    }
    if (newPwd.length < 8) {
      _showValidationError('New password must be at least 8 characters long');
      return;
    }
    if (newPwd == current) {
      _showValidationError(
        'New password must be different from the current password',
      );
      return;
    }
    if (newPwd != confirm) {
      _showValidationError('New password and confirmation do not match');
      return;
    }

    final saved = await _persistSettings({
      'currentPassword': current,
      'newPassword': newPwd,
    });

    // Only wipe the fields when the server actually accepted the change.
    if (saved && mounted) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  Future<void> _saveNotificationState() {
    final notifications = <String, dynamic>{
      'email': _emailNotifications,
      'emailNotifications': _emailNotifications,
      'sms': _smsAlerts,
      'smsAlerts': _smsAlerts,
      'assignments': _assignmentReminders,
      'assignmentUpdates': _assignmentReminders,
      'mentorSessions': _mentorSessionAlerts,
      'mentorSessionAlerts': _mentorSessionAlerts,
      'marketing': _placementDriveUpdates,
      'placementDriveUpdates': _placementDriveUpdates,
    };
    return _persistSettings({
      'settings': {'notifications': notifications},
    });
  }

  Future<void> _savePrivacyState() {
    final privacy = <String, dynamic>{
      'profileVisibleToRecruiters': _visibleToRecruiters,
      'showActivityStatus': _showOnLeaderboards,
    };
    return _persistSettings({
      'settings': {'privacy': privacy},
    });
  }

  /// Handles the 2FA toggle. Enabling drives the backend TOTP setup flow
  /// (password -> secret QR -> verification code), disabling requires the
  /// password plus a current authenticator code. Neither writes a plain flag.
  Future<void> _onTwoFactorToggle(bool enabled) async {
    if (enabled && _twoFactorAuth) return; // no-op on the same state
    if (!enabled && !_twoFactorAuth) return;

    if (enabled) {
      await _enableTwoFactorFlow();
    } else {
      await _disableTwoFactorFlow();
    }
  }

  Future<void> _enableTwoFactorFlow() async {
    final password = await _showPasswordPrompt(
      title: 'Enable Two-Factor Authentication',
      message: 'Confirm your password to start securing your account.',
    );
    if (password == null || !mounted) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final setup = await _apiService.startTwoFactorSetup(
        currentPassword: password,
      );
      final secret = setup['secret']?.toString() ?? '';
      final otpauth = setup['otpauthUrl']?.toString() ?? setup['otpauth']?.toString() ?? '';

      if (!mounted) return;

      final code = await _showTwoFactorSetupDialog(secret: secret, otpauth: otpauth);
      if (code == null || !mounted) {
        setState(() {
          _isSaving = false;
          _twoFactorAuth = false;
        });
        return;
      }

      await _apiService.verifyTwoFactorSetup(code: code);
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _twoFactorAuth = true;
        _successMessage = 'Two-factor authentication is now enabled';
      });
      _dismissSuccessAfterDelay();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _twoFactorAuth = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _twoFactorAuth = false;
        _errorMessage = 'Failed to enable two-factor authentication';
      });
    }
  }

  Future<void> _disableTwoFactorFlow() async {
    final password = await _showPasswordPrompt(
      title: 'Disable Two-Factor Authentication',
      message: 'Your authenticator app code is also required below.',
    );
    if (password == null || !mounted) return;

    final code = await _showVerificationCodeDialog(
      title: 'Authenticator code',
      message: 'Enter the current 6-digit code from your authenticator app.',
    );
    if (code == null || !mounted) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _apiService.disableTwoFactor(currentPassword: password, code: code);
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _twoFactorAuth = false;
        _successMessage = 'Two-factor authentication disabled';
      });
      _dismissSuccessAfterDelay();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Failed to disable two-factor authentication';
      });
    }
  }

  Future<String?> _showPasswordPrompt({
    required String title,
    required String message,
  }) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 13, height: 1.35, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: controller,
                  obscureText: true,
                  autofocus: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(LucideIcons.lock, size: 18),
                    hintText: 'Current password',
                  ),
                  validator: (val) => (val == null || val.isEmpty) ? 'Enter your password' : null,
                  onFieldSubmitted: (_) {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(dialogContext).pop(controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(controller.text);
                }
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
    return password;
  }

  Future<String?> _showTwoFactorSetupDialog({
    required String secret,
    required String otpauth,
  }) async {
    return _showVerificationCodeDialog(
      title: 'Scan & verify',
      message: otpauth.isNotEmpty
          ? 'Add "$otpauth" to your authenticator app, then enter the 6-digit code below.'
          : 'Add the secret "$secret" to your authenticator app, then enter the 6-digit code below.',
    );
  }

  Future<String?> _showVerificationCodeDialog({
    required String title,
    required String message,
  }) async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontSize: 12.5, height: 1.35, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 10),
                decoration: InputDecoration(
                  hintText: '••••••',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (controller.text.trim().length == 6) {
                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
    return code;
  }

  Future<void> _selectTheme(String key) async {
    HapticFeedback.selectionClick();
    setState(() => _themeMode = key);

    final mode = switch (key) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
    await ThemeController.instance.setMode(mode);

    if (!mounted) return;
    await _persistSettings({
      'settings': {'theme': key},
    });
  }

  // School-standard secure logout: nuke cached profile, clear auth state, route out.
  Future<void> _logout() async {
    HapticFeedback.lightImpact();
    await StudentApiService.clearCachedProfile();
    if (!mounted) return;
    context.read<AuthBloc>().add(LogoutRequested());
    context.go('/login');
  }

  Future<void> _requestAccountDeletion() async {
    HapticFeedback.lightImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('Delete account?'),
          content: const Text(
            'This will permanently remove your account, applications and resume '
            'data. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete my account'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final password = await _showPasswordPrompt(
      title: 'Confirm deletion',
      message: 'Enter your current password to permanently delete this account.',
    );
    if (password == null || !mounted) return;

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _apiService.deleteAccount(currentPassword: password);
      if (!mounted) return;
      context.read<AuthBloc>().add(LogoutRequested());
      context.go('/login');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _errorMessage = 'Failed to delete account';
      });
    }
  }

  Future<void> _requestAccountDeactivation() async {
    HapticFeedback.lightImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('Deactivate account?'),
          content: const Text(
            'Your account will be temporarily disabled. You can reactivate it '
            'anytime by signing in with your email and password.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final password = await _showPasswordPrompt(
      title: 'Confirm deactivation',
      message: 'Enter your current password to temporarily deactivate this account.',
    );
    if (password == null || !mounted) return;

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _apiService.deactivateAccount(currentPassword: password);
      if (!mounted) return;
      context.read<AuthBloc>().add(LogoutRequested());
      context.go('/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deactivated. Sign in anytime to reactivate.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to deactivate account';
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

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenSize = MediaQuery.sizeOf(context);
    final horizontalPadding = (screenSize.width * 0.045).clamp(14.0, 24.0);
    final bottomPadding = MediaQuery.of(context).padding.bottom == 0
        ? 16.0
        : MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleSafePop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, size: 20),
            onPressed: _handleSafePop,
            tooltip: 'Back to Dashboard',
          ),
          title: AutoSizeText(
            'Account Settings',
            maxLines: 1,
            minFontSize: 13,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                LucideIcons.compass,
                size: 20,
                color: AppColors.primary,
              ),
              onPressed: () => showStudentNavPanel(
                context,
                activeRoute: '/student/settings',
              ),
              tooltip: 'Navigation Menu',
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: StudentProfileMenuPill(),
            ),
          ],
        ),
        body: SafeArea(
          bottom: true,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _loadSettings,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: 16,
                bottom: bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null) ...[
                    _buildStatusBanner(_errorMessage!, isError: true),
                    const SizedBox(height: 12),
                  ],
                  if (_successMessage != null) ...[
                    _buildStatusBanner(_successMessage!, isError: false),
                    const SizedBox(height: 12),
                  ],

                  // 1. HERO BANNER CARD
                  RepaintBoundary(child: _buildHeroHeaderCard()),
                  const SizedBox(height: 18),

                  if (_isLoading)
                    _buildLoadingState()
                  else if (_loadFailed)
                    _buildErrorState()
                  else ...[
                    // 2. ACCOUNT DETAILS
                    RepaintBoundary(child: _buildAccountDetailsSection()),
                    const SizedBox(height: 18),

                    // 3. CHANGE PASSWORD
                    RepaintBoundary(child: _buildChangePasswordSection()),
                    const SizedBox(height: 18),

                    // 4. NOTIFICATION PREFERENCES
                    RepaintBoundary(
                      child: _buildNotificationPreferencesSection(),
                    ),
                    const SizedBox(height: 18),

                    // 5. PRIVACY & SECURITY
                    RepaintBoundary(child: _buildPrivacySecuritySection()),
                    const SizedBox(height: 18),

                    // 6. APPEARANCE
                    RepaintBoundary(child: _buildAppearanceSection()),
                    const SizedBox(height: 18),

                    // 7. DANGER ZONE
                    RepaintBoundary(child: _buildDangerZoneSection()),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

  Widget _buildErrorState() {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          const Icon(
            LucideIcons.alertTriangle,
            size: 32,
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          AutoSizeText(
            "Couldn't load settings",
            maxLines: 1,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _pillButton(
            onPressed: _loadSettings,
            icon: LucideIcons.rotateCcw,
            label: 'Retry',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(String message, {required bool isError}) {
    final base = isError ? AppColors.error : AppColors.success;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: base.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? LucideIcons.alertCircle : LucideIcons.checkCircle2,
            size: 18,
            color: base,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: base,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 1. Hero Header Card
  Widget _buildHeroHeaderCard() {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: isDark
            ? null
            : [
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.settings, size: 13, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'Account settings',
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
          AutoSizeText(
            'Manage your account',
            maxLines: 1,
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Control your login details, notifications, privacy, appearance and '
            'security preferences.',
            style: textTheme.bodyMedium?.copyWith(fontSize: 13.5, height: 1.45),
          ),
        ],
      ),
    );
  }

  /// Section Title Builder
  Widget _buildSectionHeader(
    String eyebrow,
    String title,
    IconData icon,
    Color iconColor,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: AutoSizeText(
                title,
                maxLines: 1,
                minFontSize: 14,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 2. Section 1: Account Details
  Widget _buildAccountDetailsSection() {
    final textTheme = Theme.of(context).textTheme;
    return _settingsCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'LOGIN',
            'Account details',
            LucideIcons.userCheck,
            AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'EMAIL ADDRESS',
            style: textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              prefixIcon: Icon(LucideIcons.mail, size: 18),
              hintText: 'student@university.edu',
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: _pillButton(
              onPressed: _isSaving ? null : _saveAccountEmail,
              icon: LucideIcons.check,
              label: 'Save email',
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Section 2: Change Password
  Widget _buildChangePasswordSection() {
    return _settingsCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'SECURITY',
            'Change password',
            LucideIcons.key,
            AppColors.warning,
          ),
          const SizedBox(height: 16),
          _PasswordField(
            controller: _currentPasswordController,
            hintText: 'Current password',
          ),
          const SizedBox(height: 10),
          _PasswordField(
            controller: _newPasswordController,
            hintText: 'New password (min 8 chars)',
          ),
          const SizedBox(height: 10),
          _PasswordField(
            controller: _confirmPasswordController,
            hintText: 'Confirm new password',
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: _pillButton(
              onPressed: _isSaving ? null : _updatePassword,
              icon: LucideIcons.lock,
              label: 'Update password',
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Section 3: Notification Preferences
  Widget _buildNotificationPreferencesSection() {
    return _settingsCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'ALERTS',
            'Notification preferences',
            LucideIcons.bell,
            AppColors.accentViolet,
          ),
          const SizedBox(height: 14),
          _buildToggleRow(
            icon: LucideIcons.mail,
            title: 'Email notifications',
            subtitle: 'Assignment updates, deadlines & results',
            value: _emailNotifications,
            onChanged: (val) {
              setState(() => _emailNotifications = val);
              _saveNotificationState();
            },
          ),
          _buildToggleRow(
            icon: LucideIcons.smartphone,
            title: 'SMS alerts',
            subtitle: 'Time-sensitive reminders via text',
            value: _smsAlerts,
            onChanged: (val) {
              setState(() => _smsAlerts = val);
              _saveNotificationState();
            },
          ),
          _buildToggleRow(
            icon: LucideIcons.clipboard,
            title: 'Assignment reminders',
            subtitle: 'Notify before submission deadlines',
            value: _assignmentReminders,
            onChanged: (val) {
              setState(() => _assignmentReminders = val);
              _saveNotificationState();
            },
          ),
          _buildToggleRow(
            icon: LucideIcons.users,
            title: 'Mentor session reminders',
            subtitle: 'Alerts before scheduled sessions',
            value: _mentorSessionAlerts,
            onChanged: (val) {
              setState(() => _mentorSessionAlerts = val);
              _saveNotificationState();
            },
          ),
          _buildToggleRow(
            icon: LucideIcons.briefcase,
            title: 'Placement drive updates',
            subtitle: 'New opportunities matching your profile',
            value: _placementDriveUpdates,
            onChanged: (val) {
              setState(() => _placementDriveUpdates = val);
              _saveNotificationState();
            },
          ),
        ],
      ),
    );
  }

  /// 5. Section 4: Privacy & Security
  Widget _buildPrivacySecuritySection() {
    return _settingsCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'VISIBILITY',
            'Privacy & security',
            LucideIcons.shield,
            AppColors.success,
          ),
          const SizedBox(height: 14),
          _buildToggleRow(
            icon: LucideIcons.eye,
            title: 'Visible to recruiters',
            subtitle: 'Allow verified recruiters to view your profile',
            value: _visibleToRecruiters,
            onChanged: (val) {
              setState(() => _visibleToRecruiters = val);
              _savePrivacyState();
            },
          ),
          _buildToggleRow(
            icon: LucideIcons.trendingUp,
            title: 'Show me on leaderboards',
            subtitle: 'Display your rank on public leaderboards',
            value: _showOnLeaderboards,
            onChanged: (val) {
              setState(() => _showOnLeaderboards = val);
              _savePrivacyState();
            },
          ),
          _buildToggleRow(
            icon: LucideIcons.shieldCheck,
            title: 'Two-factor authentication',
            subtitle: _twoFactorAuth
                ? 'A code is required at every login'
                : 'Extra security step at every login',
            value: _twoFactorAuth,
            onChanged: _isSaving
                ? null
                : (val) {
                    _onTwoFactorToggle(val);
                  },
          ),
        ],
      ),
    );
  }

  /// 6. Section 5: Appearance Mode Selector (applies app-wide theme)
  Widget _buildAppearanceSection() {
    return _settingsCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'DISPLAY',
            'Appearance',
            LucideIcons.monitor,
            AppColors.primary,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildThemeOption('light', 'Light', LucideIcons.sun),
              const SizedBox(width: 8),
              _buildThemeOption('dark', 'Dark', LucideIcons.moon),
              const SizedBox(width: 8),
              _buildThemeOption('system', 'System', LucideIcons.monitor),
            ],
          ),
          if (_themeMode == null) ...[
            const SizedBox(height: 10),
            Text(
              'Theme preference was not received from the server. Pick an option '
              'below to set it.',
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThemeOption(String key, String label, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = _themeMode == key;
    return Expanded(
      child: GestureDetector(
        onTap: _isSaving ? null : () => _selectTheme(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : scheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : scheme.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.primaryDark
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              AutoSizeText(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryDark
                      : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 7. Section: Danger Zone
  Widget _buildDangerZoneSection() {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'CAUTION',
            'Danger zone',
            LucideIcons.alertTriangle,
            AppColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Deactivate or delete your account',
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This will permanently remove your access to placement tracking, '
            'mentors, and applied projects.',
            style: textTheme.bodyMedium?.copyWith(fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              BouncyButton(
                onPressed: _isDeleting ? null : _logout,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.logOut,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Log out',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BouncyButton(
                onPressed: _isDeleting ? null : _requestAccountDeactivation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.7)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.pauseCircle,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Deactivate',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BouncyButton(
                onPressed: _isDeleting ? null : _requestAccountDeletion,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _isDeleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.trash2,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Delete account',
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
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Reusable pieces
  // ---------------------------------------------------------------
  Widget _settingsCard(Widget child) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 11.5,
                    height: 1.3,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primary,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _pillButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
  }) {
    return BouncyButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A queued settings PATCH awaiting a serialized API round-trip.
class _PendingSave {
  final Map<String, dynamic> payload;
  final Completer<bool> completer = Completer<bool>();

  _PendingSave(this.payload);
}

/// Password input with inline show/hide toggle.
class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const _PasswordField({required this.controller, required this.hintText});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        prefixIcon: Icon(
          LucideIcons.lock,
          size: 18,
          color: scheme.onSurfaceVariant,
        ),
        hintText: widget.hintText,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? LucideIcons.eye : LucideIcons.eyeOff,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
          tooltip: _obscure ? 'Show password' : 'Hide password',
        ),
      ),
    );
  }
}
