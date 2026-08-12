import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

class DirectoryFilterCard extends StatefulWidget {
  final ValueChanged<String>? onBatchChanged;
  final ValueChanged<String>? onDepartmentChanged;
  final ValueChanged<String>? onScoreChanged;
  final VoidCallback? onMoreFiltersTap;
  final VoidCallback? onResetTap;

  const DirectoryFilterCard({
    super.key,
    this.onBatchChanged,
    this.onDepartmentChanged,
    this.onScoreChanged,
    this.onMoreFiltersTap,
    this.onResetTap,
  });

  @override
  State<DirectoryFilterCard> createState() => _DirectoryFilterCardState();
}

class _DirectoryFilterCardState extends State<DirectoryFilterCard> {
  String selectedBatch = '2024 - 2025';
  String selectedDepartment = 'All Departments';
  String selectedScore = 'Any Score';

  final List<String> batchOptions = ['2024 - 2025', '2023 - 2024', '2025 - 2026'];
  final List<String> departmentOptions = [
    'All Departments',
    'Comp. Science',
    'Information Tech',
    'Electronics',
    'Mechanical'
  ];
  final List<String> scoreOptions = ['Any Score', '> 90% Match', '> 80% Match', '> 70% Match'];

  bool _isMoreFiltersPressed = false;
  bool _isResetPressed = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch Field
            _buildDropdownLabel('Batch'),
            const SizedBox(height: 6),
            _buildDropdownField(
              value: selectedBatch,
              items: batchOptions,
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedBatch = val);
                  if (widget.onBatchChanged != null) widget.onBatchChanged!(val);
                }
              },
            ),
            const SizedBox(height: 14),

            // Department Field
            _buildDropdownLabel('Department'),
            const SizedBox(height: 6),
            _buildDropdownField(
              value: selectedDepartment,
              items: departmentOptions,
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedDepartment = val);
                  if (widget.onDepartmentChanged != null) widget.onDepartmentChanged!(val);
                }
              },
            ),
            const SizedBox(height: 14),

            // Readiness Score Field
            _buildDropdownLabel('Readiness Score'),
            const SizedBox(height: 6),
            _buildDropdownField(
              value: selectedScore,
              items: scoreOptions,
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedScore = val);
                  if (widget.onScoreChanged != null) widget.onScoreChanged!(val);
                }
              },
            ),
            const SizedBox(height: 18),

            // Action Buttons Row (More Filters + Refresh) with Micro-Interaction Scaling
            Row(
              children: [
                // More Filters Button
                Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isMoreFiltersPressed = true),
                    onTapUp: (_) => setState(() => _isMoreFiltersPressed = false),
                    onTapCancel: () => setState(() => _isMoreFiltersPressed = false),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (widget.onMoreFiltersTap != null) widget.onMoreFiltersTap!();
                    },
                    child: AnimatedScale(
                      scale: _isMoreFiltersPressed ? 0.96 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.slidersHorizontal, color: AppColors.textPrimary, size: 18),
                            SizedBox(width: 8),
                            AutoSizeText(
                              'More Filters',
                              maxLines: 1,
                              minFontSize: 11,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Refresh / Reset Button with Bouncy Feedback
                GestureDetector(
                  onTapDown: (_) => setState(() => _isResetPressed = true),
                  onTapUp: (_) => setState(() => _isResetPressed = false),
                  onTapCancel: () => setState(() => _isResetPressed = false),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (widget.onResetTap != null) widget.onResetTap!();
                  },
                  child: AnimatedScale(
                    scale: _isResetPressed ? 0.92 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        LucideIcons.rotateCcw,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary, size: 18),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: AutoSizeText(
                item,
                maxLines: 1,
                minFontSize: 11,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
