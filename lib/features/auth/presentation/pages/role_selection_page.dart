import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/role_selection_card.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final horizontalPadding = (screenSize.width * 0.06).clamp(16.0, 32.0);

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom == 0 ? 16.0 : MediaQuery.of(context).padding.bottom,
              top: 16.0,
              left: horizontalPadding,
              right: horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // C2C Brand Header Logo & Quick Log In Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            LucideIcons.network,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'C2C',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => context.push('/login'),
                      icon: const Icon(LucideIcons.logIn, size: 16, color: AppColors.primary),
                      label: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Title with Sleek Gradient Fade / ShaderMask
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.textPrimary, Color(0xFF334155)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const AutoSizeText(
                    'How will you be using C2C?',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Select your primary role to customize your portal. We\'ll tailor your dashboard, tools, and recommendations to fit your goals.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Role Card 1: Student
                RoleSelectionCard(
                  title: 'Student',
                  description: 'Find internships, connect with mentors, and kickstart your career journey.',
                  buttonText: 'Continue as Student',
                  icon: LucideIcons.graduationCap,
                  accentColor: const Color(0xFF7C3AED),
                  iconBgColor: const Color(0xFFEDE9FE),
                  onTap: () => context.push('/auth/register/student'),
                ),

                // Role Card 2: Mentor
                RoleSelectionCard(
                  title: 'Mentor',
                  description: 'Share your expertise, guide emerging talent, and give back to the community.',
                  buttonText: 'Continue as Mentor',
                  icon: LucideIcons.users,
                  accentColor: const Color(0xFF10B981),
                  iconBgColor: const Color(0xFFD1FAE5),
                  onTap: () => context.push('/auth/register/mentor'),
                ),

                // Role Card 3: College / Institute
                RoleSelectionCard(
                  title: 'College / Institute',
                  description: 'Manage student placements, track alumni success, and partner with top recruiters.',
                  buttonText: 'Continue as Institute',
                  icon: LucideIcons.building2,
                  accentColor: const Color(0xFF2563EB),
                  iconBgColor: const Color(0xFFE0F2FE),
                  onTap: () => context.push('/auth/register/college'),
                ),

                // Role Card 4: Recruiter
                RoleSelectionCard(
                  title: 'Recruiter',
                  description: 'Post opportunities, source top talent, and build your employer brand effortlessly.',
                  buttonText: 'Continue as Recruiter',
                  icon: LucideIcons.briefcase,
                  accentColor: const Color(0xFFEA580C),
                  iconBgColor: const Color(0xFFFFEDD5),
                  onTap: () => context.push('/auth/register/recruiter'),
                ),

                // Role Card 5: System Admin
                RoleSelectionCard(
                  title: 'System Admin',
                  description: 'Platform management, analytics, user approvals, and system-wide controls.',
                  buttonText: 'Continue as Admin',
                  icon: LucideIcons.shieldCheck,
                  accentColor: const Color(0xFF64748B),
                  iconBgColor: const Color(0xFFF1F5F9),
                  onTap: () => context.push('/auth/register/admin'),
                ),
                const SizedBox(height: 16),

                // Bottom Log In Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.userCheck, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Already have an account?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Sign in to access your dashboard across all 5 portals.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => context.push('/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Log In', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
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
    );
  }
}
