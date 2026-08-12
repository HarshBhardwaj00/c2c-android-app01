import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/auth_bloc.dart';
import '../widgets/bouncy_button.dart';

class RegisterPage extends StatefulWidget {
  final String role; // 'student', 'mentor', 'college', 'recruiter'

  const RegisterPage({
    super.key,
    required this.role,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _normalizedRole {
    final r = widget.role.toLowerCase();
    if (r == 'admin') return 'admin';
    if (r == 'mentor') return 'mentor';
    if (r == 'college' || r == 'institute') return 'college';
    if (r == 'recruiter') return 'recruiter';
    return 'student';
  }

  Color get _accentColor {
    switch (_normalizedRole) {
      case 'admin':
        return const Color(0xFF64748B); // Slate Gray
      case 'mentor':
        return const Color(0xFF10B981); // Emerald Green
      case 'college':
        return const Color(0xFF2563EB); // Institutional Blue
      case 'recruiter':
        return const Color(0xFFEA580C); // Warm Orange
      case 'student':
      default:
        return const Color(0xFF7C3AED); // Primary Purple
    }
  }

  String get _title {
    switch (_normalizedRole) {
      case 'admin':
        return 'Create Admin Account';
      case 'mentor':
        return 'Create Mentor Account';
      case 'college':
        return 'Institute Registration';
      case 'recruiter':
        return 'Create Recruiter Account';
      case 'student':
      default:
        return 'Create your account';
    }
  }

  String get _subtitle {
    switch (_normalizedRole) {
      case 'admin':
        return 'System administration and platform governance setup.';
      case 'mentor':
        return 'Step 2 of 3: Professional Details';
      case 'college':
        return 'Step 2 of 3: Set up your primary contact details.';
      case 'recruiter':
        return 'Join our ecosystem to connect with top-tier talent and mentors.';
      case 'student':
      default:
        return 'Set up your student profile to start connecting.';
    }
  }

  String get _emailLabel {
    switch (_normalizedRole) {
      case 'admin':
        return 'Administrative Email';
      case 'mentor':
        return 'Corporate Email';
      case 'college':
        return 'Institutional Email';
      case 'recruiter':
        return 'Corporate Email';
      case 'student':
      default:
        return 'College Email Address';
    }
  }

  String get _emailHint {
    switch (_normalizedRole) {
      case 'admin':
        return 'admin@c2c.org';
      case 'mentor':
        return 'jane.doe@company.com';
      case 'college':
        return 'contact@university.edu';
      case 'recruiter':
        return 'jane@company.com';
      case 'student':
      default:
        return 'student@university.edu';
    }
  }

  String get _buttonText {
    switch (_normalizedRole) {
      case 'admin':
        return 'Create Admin Account →';
      case 'mentor':
        return 'Continue →';
      case 'college':
        return 'Continue to Dashboard →';
      case 'recruiter':
        return 'Create Recruiter Account';
      case 'student':
      default:
        return 'Create Account →';
    }
  }

  void _onSubmitted() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the Terms of Service to continue.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          RegisterRequested(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _normalizedRole,
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final horizontalPadding = screenSize.width * 0.06;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome, ${state.userName}! Account created successfully.'),
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
              left: horizontalPadding.clamp(16.0, 32.0),
              right: horizontalPadding.clamp(16.0, 32.0),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Navigation Bar with Back Button & Brand Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
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
                        children: [
                          Text(
                            'C2C',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: _accentColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Optional Role Specific Badge / Progress Bar
                  if (_normalizedRole == 'student') ...[
                    // Step Progress Indicator
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 80,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'STEP 2 OF 2',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ] else if (_normalizedRole == 'college') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.building2, size: 14, color: Color(0xFF2563EB)),
                          SizedBox(width: 6),
                          Text(
                            'College / Institute',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (_normalizedRole == 'recruiter') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDD5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Recruiter Portal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Title Header
                  Text(
                    _title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Input 1: Full Name
                  _buildInputLabel('Full Name'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your full name' : null,
                    decoration: InputDecoration(
                      hintText: 'Jane Doe',
                      prefixIcon: const Icon(LucideIcons.user, size: 20, color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Input 2: Email
                  _buildInputLabel(_emailLabel),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter email address';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: _emailHint,
                      prefixIcon: Icon(
                        _normalizedRole == 'student' ? LucideIcons.graduationCap : LucideIcons.mail,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Input 3: Phone Number
                  _buildInputLabel('Phone Number${_normalizedRole == "student" ? " (Optional)" : ""}'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '(555) 123-4567',
                      prefixIcon: Icon(LucideIcons.phone, size: 20, color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Input 4: Password
                  _buildInputLabel('Password'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter a password';
                      if (val.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(LucideIcons.lock, size: 20, color: AppColors.textMuted),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Terms & Conditions Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreedToTerms,
                          activeColor: _accentColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'I agree to the ',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Terms of Service',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _accentColor,
                                ),
                              ),
                            ),
                            const Text(
                              ' and ',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _accentColor,
                                ),
                              ),
                            ),
                            const Text(
                              '.',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Create Account / Continue Primary Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: BouncyButton(
                          onPressed: isLoading ? null : _onSubmitted,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _accentColor,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: _accentColor.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : AutoSizeText(
                                    _buttonText,
                                    maxLines: 1,
                                    style: const TextStyle(
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

                  // Already Have An Account? Login Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
