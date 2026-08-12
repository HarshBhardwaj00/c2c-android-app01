import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/student_bloc.dart';
import 'student_profile_view.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  void _handleSafePop(BuildContext context) {
    HapticFeedback.lightImpact();
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      context.go('/student/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudentDashboardBloc>().state;
    final profile = (state is StudentDashboardLoadedState) ? state.data.profile : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleSafePop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary, size: 20),
            onPressed: () => _handleSafePop(context),
            tooltip: 'Back to Dashboard',
          ),
          title: const Text(
            'My Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.sparkles, color: AppColors.primary, size: 20),
              onPressed: () => context.push('/student/ask-ai'),
              tooltip: 'Ask AI Career Coach',
            ),
          ],
        ),
        body: SafeArea(
          bottom: true,
          child: StudentProfileView(initialProfile: profile),
        ),
      ),
    );
  }
}
