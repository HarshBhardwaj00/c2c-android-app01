import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';

/// ============================================================================
/// AI Resume Builder — Experience / Education / Certifications section UI.
///
/// Mobile-first, Impeller-friendly redesign that consumes the central design
/// system (AppColors tokens) and the app theme. Zero hardcoded screen-level
/// widths: every entry uses LayoutBuilder to adapt between stacked and
/// side-by-side field rows. Text overflow is handled with AutoSizeText,
/// gradient fade-outs (ShaderMask) and constrained chips — never raw ellipsis
/// where avoidable.
/// ============================================================================

/// Press-and-release micro-interaction wrapper with a light haptic tick.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.95,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              HapticFeedback.lightImpact();
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Shared 18px rounded section shell with tinted icon chip, gradient-faded
/// title, entry-count badge and optional trailing action.
class ResumeSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final Widget? trailing;
  final int? entryCount;

  const ResumeSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.trailing,
    this.entryCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TintedIconChip(icon: icon, color: iconColor),
              const SizedBox(width: 10),
              Expanded(child: _GradientTitle(title)),
              if (entryCount != null) ...[
                const SizedBox(width: 8),
                _CountBadge(count: entryCount ?? 0),
              ],
              if (trailing != null) ...[
                const SizedBox(width: 4),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Compact "+ Add" pill used at the end of section headers.
class ResumeAddButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const ResumeAddButton({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.plus, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filled rounded input with a tinted prefix icon. Bounds come from the parent
/// (Expanded) — never given fixed widths.
class ResumeInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const ResumeInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.onChanged,
    this.iconColor = AppColors.primary,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// Light grey empty-state hint shown when a section has no entries yet.
class ResumeEmptySection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const ResumeEmptySection({
    super.key,
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color.withValues(alpha: 0.55)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Redesigned single experience entry card.
class ExperienceEntryCard extends StatelessWidget {
  final int index;
  final bool isEnhancing;
  final TextEditingController roleController;
  final TextEditingController organizationController;
  final TextEditingController durationController;
  final TextEditingController bulletsController;
  final ValueChanged<String> onFieldChanged;
  final VoidCallback? onEnhance;
  final VoidCallback? onDelete;

  const ExperienceEntryCard({
    super.key,
    required this.index,
    required this.isEnhancing,
    required this.roleController,
    required this.organizationController,
    required this.durationController,
    required this.bulletsController,
    required this.onFieldChanged,
    this.onEnhance,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EntryHeader(
              icon: LucideIcons.briefcase,
              accentColor: AppColors.primary,
              title: 'Experience ${index + 1}',
              previewChip: durationController.text.trim().isEmpty
                  ? null
                  : _InfoChip(
                      icon: LucideIcons.calendar,
                      label: durationController.text.trim(),
                    ),
              onDelete: onDelete,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 320;
                if (wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ResumeInputField(
                              label: 'Role / Position',
                              controller: roleController,
                              icon: LucideIcons.userCheck,
                              iconColor: AppColors.primary,
                              onChanged: onFieldChanged,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ResumeInputField(
                              label: 'Organization / Company',
                              controller: organizationController,
                              icon: LucideIcons.building2,
                              iconColor: AppColors.primary,
                              onChanged: onFieldChanged,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ResumeInputField(
                        label: 'Duration (e.g. Summer 2025)',
                        controller: durationController,
                        icon: LucideIcons.calendar,
                        iconColor: AppColors.primary,
                        onChanged: onFieldChanged,
                      ),
                      const SizedBox(height: 10),
                      _BulletsEditor(
                        isEnhancing: isEnhancing,
                        controller: bulletsController,
                        onFieldChanged: onFieldChanged,
                        onEnhance: onEnhance,
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResumeInputField(
                      label: 'Role / Position',
                      controller: roleController,
                      icon: LucideIcons.userCheck,
                      iconColor: AppColors.primary,
                      onChanged: onFieldChanged,
                    ),
                    const SizedBox(height: 10),
                    ResumeInputField(
                      label: 'Organization / Company',
                      controller: organizationController,
                      icon: LucideIcons.building2,
                      iconColor: AppColors.primary,
                      onChanged: onFieldChanged,
                    ),
                    const SizedBox(height: 10),
                    ResumeInputField(
                      label: 'Duration (e.g. Summer 2025)',
                      controller: durationController,
                      icon: LucideIcons.calendar,
                      iconColor: AppColors.primary,
                      onChanged: onFieldChanged,
                    ),
                    const SizedBox(height: 10),
                    _BulletsEditor(
                      isEnhancing: isEnhancing,
                      controller: bulletsController,
                      onFieldChanged: onFieldChanged,
                      onEnhance: onEnhance,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Redesigned single education entry card.
class EducationEntryCard extends StatelessWidget {
  final int index;
  final TextEditingController degreeController;
  final TextEditingController institutionController;
  final TextEditingController durationController;
  final TextEditingController gpaController;
  final ValueChanged<String> onFieldChanged;
  final VoidCallback? onDelete;

  const EducationEntryCard({
    super.key,
    required this.index,
    required this.degreeController,
    required this.institutionController,
    required this.durationController,
    required this.gpaController,
    required this.onFieldChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EntryHeader(
              icon: LucideIcons.graduationCap,
              accentColor: AppColors.success,
              title: 'Education ${index + 1}',
              previewChip: gpaController.text.trim().isEmpty
                  ? null
                  : _InfoChip(
                      icon: LucideIcons.award,
                      label: gpaController.text.trim(),
                    ),
              onDelete: onDelete,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 320;
                if (wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ResumeInputField(
                              label: 'Degree / Program',
                              controller: degreeController,
                              icon: LucideIcons.graduationCap,
                              iconColor: AppColors.success,
                              onChanged: onFieldChanged,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ResumeInputField(
                              label: 'Institution',
                              controller: institutionController,
                              icon: LucideIcons.building2,
                              iconColor: AppColors.success,
                              onChanged: onFieldChanged,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ResumeInputField(
                              label: 'Duration (e.g. 2022 - 2026)',
                              controller: durationController,
                              icon: LucideIcons.calendar,
                              iconColor: AppColors.success,
                              onChanged: onFieldChanged,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ResumeInputField(
                              label: 'CGPA / Marks',
                              controller: gpaController,
                              icon: LucideIcons.award,
                              iconColor: AppColors.success,
                              onChanged: onFieldChanged,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResumeInputField(
                      label: 'Degree / Program',
                      controller: degreeController,
                      icon: LucideIcons.graduationCap,
                      iconColor: AppColors.success,
                      onChanged: onFieldChanged,
                    ),
                    const SizedBox(height: 10),
                    ResumeInputField(
                      label: 'Institution',
                      controller: institutionController,
                      icon: LucideIcons.building2,
                      iconColor: AppColors.success,
                      onChanged: onFieldChanged,
                    ),
                    const SizedBox(height: 10),
                    ResumeInputField(
                      label: 'Duration (e.g. 2022 - 2026)',
                      controller: durationController,
                      icon: LucideIcons.calendar,
                      iconColor: AppColors.success,
                      onChanged: onFieldChanged,
                    ),
                    const SizedBox(height: 10),
                    ResumeInputField(
                      label: 'CGPA / Marks',
                      controller: gpaController,
                      icon: LucideIcons.award,
                      iconColor: AppColors.success,
                      onChanged: onFieldChanged,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Redesigned single certification entry card.
class CertificationEntryCard extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final TextEditingController issuerController;
  final TextEditingController dateController;
  final ValueChanged<String> onFieldChanged;
  final VoidCallback? onDelete;

  const CertificationEntryCard({
    super.key,
    required this.index,
    required this.nameController,
    required this.issuerController,
    required this.dateController,
    required this.onFieldChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EntryHeader(
              icon: LucideIcons.award,
              accentColor: AppColors.accentViolet,
              title: 'Certification ${index + 1}',
              previewChip: dateController.text.trim().isEmpty
                  ? null
                  : _InfoChip(
                      icon: LucideIcons.calendar,
                      label: dateController.text.trim(),
                    ),
              onDelete: onDelete,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 320;
                if (wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ResumeInputField(
                              label: 'Certificate Name',
                              controller: nameController,
                              icon: LucideIcons.award,
                              iconColor: AppColors.accentViolet,
                              onChanged: onFieldChanged,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ResumeInputField(
                              label: 'Issuing Authority',
                              controller: issuerController,
                              icon: LucideIcons.building2,
                              iconColor: AppColors.accentViolet,
                              onChanged: onFieldChanged,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ResumeInputField(
                        label: 'Issue Date',
                        controller: dateController,
                        icon: LucideIcons.calendar,
                        iconColor: AppColors.accentViolet,
                        onChanged: onFieldChanged,
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResumeInputField(
                      label: 'Certificate Name',
                      controller: nameController,
                      icon: LucideIcons.award,
                      iconColor: AppColors.accentViolet,
                      onChanged: onFieldChanged,
                    ),
                    const SizedBox(height: 10),
                    ResumeInputField(
                      label: 'Issuing Authority',
                      controller: issuerController,
                      icon: LucideIcons.building2,
                      iconColor: AppColors.accentViolet,
                      onChanged: onFieldChanged,
                    ),
                    const SizedBox(height: 10),
                    ResumeInputField(
                      label: 'Issue Date',
                      controller: dateController,
                      icon: LucideIcons.calendar,
                      iconColor: AppColors.accentViolet,
                      onChanged: onFieldChanged,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared header row for an entry card: tinted icon chip, gradient title,
/// optional live preview chip and delete action.
class _EntryHeader extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final Widget? previewChip;
  final VoidCallback? onDelete;

  const _EntryHeader({
    required this.icon,
    required this.accentColor,
    required this.title,
    this.previewChip,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TintedIconChip(icon: icon, color: accentColor),
        const SizedBox(width: 10),
        Expanded(child: _GradientTitle(title)),
        if (previewChip != null) ...[
          const SizedBox(width: 6),
          previewChip!,
        ],
        const SizedBox(width: 2),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              LucideIcons.trash2,
              size: 17,
              color: AppColors.error,
            ),
            tooltip: 'Delete entry',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 34, height: 34),
          ),
      ],
    );
  }
}

/// Bullet-points editor row with the AI "Enhance" pill.
class _BulletsEditor extends StatelessWidget {
  final bool isEnhancing;
  final TextEditingController controller;
  final ValueChanged<String> onFieldChanged;
  final VoidCallback? onEnhance;

  const _BulletsEditor({
    required this.isEnhancing,
    required this.controller,
    required this.onFieldChanged,
    this.onEnhance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Bullet Points (One per line)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (onEnhance != null)
              PressableScale(
                onTap: isEnhancing ? null : onEnhance,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.aiBadgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEnhancing)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentViolet,
                          ),
                        )
                      else
                        const Icon(
                          LucideIcons.sparkles,
                          size: 13,
                          color: AppColors.accentViolet,
                        ),
                      const SizedBox(width: 5),
                      Text(
                        isEnhancing ? 'Enhancing...' : 'Enhance with AI',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentViolet,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 3,
          onChanged: onFieldChanged,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: '• Engineered microservices...\n• Reduced query latency by 40%...',
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.inputFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accentViolet, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small tinted rounded icon chip used in section + entry headers.
class _TintedIconChip extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _TintedIconChip({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: color),
    );
  }
}

/// Editorial "01 / 02" entry-count badge shown in section headers.
class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        count < 10 ? '0$count' : '$count',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Compact live preview chip (duration / CGPA / date) shown beside entry title.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 90),
            child: AutoSizeText(
              label,
              maxLines: 1,
              minFontSize: 8,
              maxFontSize: 11,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient fade-out for titles/headers (avoids raw ellipsis).
class _GradientTitle extends StatelessWidget {
  final String text;

  const _GradientTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          AppColors.textPrimary,
          AppColors.textPrimary,
          AppColors.textPrimary.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.9, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: AutoSizeText(
        text,
        maxLines: 1,
        minFontSize: 11,
        maxFontSize: 14,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
