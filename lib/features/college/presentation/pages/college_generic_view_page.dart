import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/college_drawer.dart';

/// Production-ready College module screen wrapper with Safe Area,
/// Back action, Theme consistency, and zero UI clipping.
class CollegeGenericViewPage extends StatelessWidget {
  final String title;
  final String currentRoute;
  final IconData icon;
  final String description;

  const CollegeGenericViewPage({
    super.key,
    required this.title,
    required this.currentRoute,
    this.icon = LucideIcons.layoutGrid,
    this.description = 'Manage and monitor institutional records seamlessly.',
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: CollegeNavigationDrawer(currentRoute: currentRoute),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 12.0,
            bottom: bottomInset == 0 ? 16.0 : bottomInset + 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header with Back / Drawer Navigation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        if (Navigator.canPop(context)) {
                          context.pop();
                        } else {
                          context.go('/college/dashboard');
                        }
                      },
                      icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary, size: 22),
                      tooltip: 'Back',
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Builder(
                      builder: (scaffoldCtx) => IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Scaffold.of(scaffoldCtx).openDrawer();
                        },
                        icon: const Icon(LucideIcons.menu, color: AppColors.textPrimary, size: 20),
                        tooltip: 'Open Menu',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Content Hero Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 36, color: AppColors.primary),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Hello, TPO Admin!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome to $title',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.go('/college/dashboard');
                        },
                        icon: const Icon(LucideIcons.layoutGrid, size: 16, color: Colors.white),
                        label: Text(
                          'Back to Dashboard',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
