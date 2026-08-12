import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onFabPressed;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 6,
        bottom: bottomInset > 0 ? bottomInset + 4 : 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _NavItem(
              icon: LucideIcons.home,
              activeIcon: LucideIcons.home,
              label: 'Home',
              isSelected: currentIndex == 0,
              onTap: () => _handleTap(0),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: LucideIcons.fileText,
              activeIcon: LucideIcons.fileText,
              label: 'Reports',
              isSelected: currentIndex == 1,
              onTap: () => _handleTap(1),
            ),
          ),

          // Center Floating Action Button (+) with Micro-Interaction
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (onFabPressed != null) onFabPressed!();
            },
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x406366F1),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.plus,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),

          Expanded(
            child: _NavItem(
              icon: LucideIcons.users,
              activeIcon: LucideIcons.users,
              label: 'Students',
              isSelected: currentIndex == 3,
              onTap: () => _handleTap(3),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: LucideIcons.settings,
              activeIcon: LucideIcons.settings,
              label: 'Settings',
              isSelected: currentIndex == 4,
              onTap: () => _handleTap(4),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(int index) {
    HapticFeedback.lightImpact();
    onTap(index);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      // Active Pill Style matching Figma (Purple Pill with White Icon & Text - Overflow Safe)
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(activeIcon, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Flexible(
                child: AutoSizeText(
                  label,
                  maxLines: 1,
                  minFontSize: 9,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(height: 2),
            AutoSizeText(
              label,
              maxLines: 1,
              minFontSize: 8,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
