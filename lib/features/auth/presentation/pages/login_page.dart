import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/auth_bloc.dart';
import '../widgets/bouncy_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedRole = 'student';

  final List<Map<String, dynamic>> _roles = [
    {'id': 'student', 'label': 'Student', 'icon': LucideIcons.graduationCap, 'color': Color(0xFF7C3AED)},
    {'id': 'mentor', 'label': 'Mentor', 'icon': LucideIcons.users, 'color': Color(0xFF10B981)},
    {'id': 'college', 'label': 'College', 'icon': LucideIcons.building2, 'color': Color(0xFF2563EB)},
    {'id': 'recruiter', 'label': 'Recruiter', 'icon': LucideIcons.briefcase, 'color': Color(0xFFEA580C)},
    {'id': 'admin', 'label': 'Admin', 'icon': LucideIcons.shieldCheck, 'color': Color(0xFF64748B)},
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Color get _activeRoleColor {
    final match = _roles.firstWhere(
      (r) => r['id'] == _selectedRole,
      orElse: () => _roles.first,
    );
    return match['color'] as Color;
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
          LoginRequested(
            _emailController.text.trim(),
            _passwordController.text,
            role: _selectedRole,
          ),
        );
  }

  Future<void> _showTwoFactorDialog(String pendingToken) async {
    final code = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Two-Factor Authentication',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the 6-digit code from your authenticator app to complete sign-in.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
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
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 12),
                decoration: InputDecoration(
                  hintText: '••••••',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(LucideIcons.shieldCheck, size: 14, color: AppColors.success),
                  const SizedBox(width: 6),
                  const Text(
                    'Secret never leaves your app',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                ],
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

    if (!mounted || code == null || code.length != 6) return;
    context.read<AuthBloc>().add(
          TwoFactorCodeSubmitted(pendingToken: pendingToken, code: code),
        );
  }

  Future<void> _showReactivateSheet() async {
    final emailController = TextEditingController(text: _emailController.text.trim());
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reactivate Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter the email and password of your deactivated student account to bring it back.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'name@domain.com',
                    prefixIcon: Icon(LucideIcons.mail, size: 19, color: AppColors.textMuted),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter your email' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(LucideIcons.lock, size: 19, color: AppColors.textMuted),
                  ),
                  validator: (val) => (val == null || val.isEmpty) ? 'Enter your password' : null,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: BouncyButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      Navigator.of(sheetContext).pop();
                      context.read<AuthBloc>().add(
                            ReactivateAccountRequested(
                              email: emailController.text.trim(),
                              password: passwordController.text,
                            ),
                          );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Reactivate & Sign In',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final horizontalPadding = screenSize.width * 0.05;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back, ${state.userName}!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );

            if (state.role == 'admin') {
              context.go('/admin/dashboard');
            } else if (state.role == 'college') {
              context.go('/college/dashboard');
            } else if (state.role == 'mentor') {
              context.go('/mentor/dashboard');
            } else if (state.role == 'recruiter') {
              context.go('/recruiter/dashboard');
            } else {
              context.go('/student/dashboard');
            }
          } else if (state is TwoFactorRequired) {
            _showTwoFactorDialog(state.pendingToken);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        child: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom == 0 ? 16.0 : MediaQuery.of(context).padding.bottom,
              top: 16.0,
              left: horizontalPadding.clamp(14.0, 28.0),
              right: horizontalPadding.clamp(14.0, 28.0),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Brand Header with Overflow Safety (Flexible & AutoSizeText)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _activeRoleColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.network,
                          color: _activeRoleColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: AutoSizeText(
                          'Campus2Corporate',
                          maxLines: 1,
                          minFontSize: 16,
                          maxFontSize: 24,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Header Title with ShaderMask
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [_activeRoleColor, AppColors.textPrimary],
                    ).createShader(bounds),
                    child: const AutoSizeText(
                      'Welcome Back',
                      maxLines: 1,
                      minFontSize: 20,
                      maxFontSize: 28,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign in to access your customized dashboard and tools.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Role Switcher Label & Demo Fill Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AutoSizeText(
                        'Select Portal Role',
                        maxLines: 1,
                        minFontSize: 12,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _emailController.text = '$_selectedRole.demo@c2c.org';
                            _passwordController.text = 'Password123!';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Filled demo credentials for ${_selectedRole.toUpperCase()}'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: _activeRoleColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Row(
                            children: [
                              Icon(LucideIcons.sparkles, size: 13, color: _activeRoleColor),
                              const SizedBox(width: 4),
                              Text(
                                'Fill Demo Credentials',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _activeRoleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Role Switcher Chips Container
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _roles.map((r) {
                        final isSelected = r['id'] == _selectedRole;
                        final color = r['color'] as Color;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            showCheckmark: false,
                            avatar: Icon(
                              r['icon'] as IconData,
                              size: 15,
                              color: isSelected ? Colors.white : color,
                            ),
                            label: Text(
                              r['label'] as String,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: color,
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? color : AppColors.border,
                              ),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedRole = r['id'] as String);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Email Address Field Label
                  const AutoSizeText(
                    'Email Address',
                    maxLines: 1,
                    minFontSize: 12,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'name@domain.com',
                      prefixIcon: Icon(LucideIcons.mail, size: 19, color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Password Label & Forgot Password Row (Flexible Wrapped)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: AutoSizeText(
                          'Password',
                          maxLines: 1,
                          minFontSize: 11,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Password reset link sent to your registered email.'),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          child: AutoSizeText(
                            'Forgot Password?',
                            maxLines: 1,
                            minFontSize: 10,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _activeRoleColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (val) => val == null || val.isEmpty ? 'Please enter password' : null,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(LucideIcons.lock, size: 19, color: AppColors.textMuted),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                          size: 19,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Sign In Action Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: BouncyButton(
                          onPressed: isLoading ? null : _onLogin,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _activeRoleColor,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: _activeRoleColor.withValues(alpha: 0.28),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const AutoSizeText(
                                    'Sign In',
                                    maxLines: 1,
                                    minFontSize: 14,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),

                  // Don't have an account? Register Now Link (FittedBox Wrapped)
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/auth/role-select'),
                            child: Text(
                              'Register Now',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: _activeRoleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Account deactivated? Reactivate link
                  Center(
                    child: TextButton.icon(
                      onPressed: _showReactivateSheet,
                      icon: const Icon(LucideIcons.rotateCcw, size: 15, color: AppColors.textMuted),
                      label: const Text(
                        'Account deactivated? Reactivate',
                        style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
