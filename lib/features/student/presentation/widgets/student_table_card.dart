import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/student_model.dart';

class StudentTableCard extends StatefulWidget {
  final List<StudentModel> students;
  final int totalCount;
  final VoidCallback? onPreviousTap;
  final VoidCallback? onNextTap;
  final ValueChanged<StudentModel>? onStudentTap;

  const StudentTableCard({
    super.key,
    required this.students,
    this.totalCount = 1248,
    this.onPreviousTap,
    this.onNextTap,
    this.onStudentTap,
  });

  @override
  State<StudentTableCard> createState() => _StudentTableCardState();
}

class _StudentTableCardState extends State<StudentTableCard> {
  final Set<String> selectedIds = {};
  bool selectAll = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Table Header (Overflow Safe)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: selectAll,
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) {
                      setState(() {
                        selectAll = val ?? false;
                        if (selectAll) {
                          selectedIds.addAll(widget.students.map((e) => e.id));
                        } else {
                          selectedIds.clear();
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  flex: 5,
                  child: AutoSizeText(
                    'STUDENT NAME',
                    maxLines: 1,
                    minFontSize: 9,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 4,
                  child: AutoSizeText(
                    'DEPT & YEAR',
                    maxLines: 1,
                    minFontSize: 9,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Student List Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.students.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: AppColors.border,
              indent: 12,
              endIndent: 12,
            ),
            itemBuilder: (context, index) {
              final student = widget.students[index];
              final isSelected = selectedIds.contains(student.id);

              return RepaintBoundary(
                child: InkWell(
                  onTap: () {
                    if (widget.onStudentTap != null) widget.onStudentTap!(student);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Checkbox
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: isSelected,
                            activeColor: AppColors.primary,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedIds.add(student.id);
                                } else {
                                  selectedIds.remove(student.id);
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Student Avatar with AspectRatio 1:1
                        SizedBox(
                          width: 34,
                          height: 34,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              backgroundImage: student.avatarUrl.isNotEmpty
                                  ? NetworkImage(student.avatarUrl)
                                  : null,
                              onBackgroundImageError: (error, stackTrace) {},
                              child: Text(
                                student.name.isNotEmpty ? student.name[0] : 'S',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Student Name & ID
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                student.name,
                                maxLines: 1,
                                minFontSize: 11,
                                maxFontSize: 14,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AutoSizeText(
                                'ID: ${student.studentCode}',
                                maxLines: 1,
                                minFontSize: 9,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Dept & Year
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                student.department,
                                maxLines: 1,
                                minFontSize: 10,
                                maxFontSize: 13,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AutoSizeText(
                                '${student.year} • ${student.batch}',
                                maxLines: 1,
                                minFontSize: 9,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const Divider(height: 1, color: AppColors.border),

          // Pagination Footer (Adaptive & 100% Overflow Safe)
          Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 340;

                if (isNarrow) {
                  return Column(
                    children: [
                      AutoSizeText(
                        'Showing ${widget.students.length} of ${widget.totalCount} students',
                        maxLines: 1,
                        minFontSize: 9,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPrevButton(),
                          const SizedBox(width: 8),
                          _buildNextButton(),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        'Showing ${widget.students.length} of ${widget.totalCount} students',
                        maxLines: 1,
                        minFontSize: 9,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildPrevButton(),
                    const SizedBox(width: 6),
                    _buildNextButton(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrevButton() {
    return OutlinedButton(
      onPressed: widget.onPreviousTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textMuted,
        side: BorderSide.none,
        backgroundColor: AppColors.inputFill,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.chevronLeft, size: 14),
          SizedBox(width: 2),
          Text('Previous', style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        if (widget.onNextTap != null) widget.onNextTap!();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Next',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 2),
          Icon(LucideIcons.chevronRight, size: 14),
        ],
      ),
    );
  }
}
