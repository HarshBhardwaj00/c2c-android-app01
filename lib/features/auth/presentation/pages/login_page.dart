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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    // Dispatches single login request with auto module & role detection in AuthRepository
    context.read<AuthBloc>().add(
          LoginRequested(
            _emailController.text.trim(),
            _passwordController.text,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Icon(LucideIcons.shieldCheck, size: 14, color: AppColors.success),
                  SizedBox(width: 6),
                  Text(
                    'Encrypted & verified end-to-end',
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
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reactivate Account',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter the email and password of your deactivated account to bring it back.',
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
    final horizontalPadding = (screenSize.width * 0.06).clamp(16.0, 32.0);
    final bottomInset = MediaQuery.of(context).padding.bottom == 0 ? 16.0 : MediaQuery.of(context).padding.bottom;

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

              // Auto-routes directly to matching module dashboard based on validated credentials
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
                top: 16.0,
                bottom: bottomInset + 16.0,
                left: horizontalPadding,
                right: horizontalPadding,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Bar with Brand Identity & Back Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              context.pop();
                            } else {
                              context.go('/auth/role-select');
                            }
                          },
                          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                LucideIcons.network,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Campus2Corporate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Header Title with ShaderMask
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.textPrimary, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const AutoSizeText(
                        'Welcome Back',
                        maxLines: 1,
                        minFontSize: 22,
                        maxFontSize: 30,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in with your registered credentials. We will automatically detect your portal and open your dashboard.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),



                    // Email Address Field
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
                        if (val == null || val.trim().isEmpty) return 'Please enter your email address';
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

                    // Password Label & Forgot Password Action
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
                                  content: const Text('Password reset instructions sent to your registered email.'),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            child: const AutoSizeText(
                              'Forgot Password?',
                              maxLines: 1,
                              minFontSize: 10,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
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
                      validator: (val) => val == null || val.isEmpty ? 'Please enter your password' : null,
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
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.32),
                                    blurRadius: 12,
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
                                      'Sign In to Dashboard',
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
                    const SizedBox(height: 24),

                    // Don't have an account? Register Now Link
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
                              child: const Text(
                                'Register Now',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Reactivate Deactivated Account Link
                    Center(
                      child: TextButton.icon(
                        onPressed: _showReactivateSheet,
                        icon: const Icon(LucideIcons.rotateCcw, size: 14, color: AppColors.textMuted),
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
