import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../bloc/student_directory_bloc.dart';
import '../../domain/models/college_student_model.dart';
import '../widgets/college_drawer.dart';

class StudentDirectoryPage extends StatelessWidget {
  const StudentDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StudentDirectoryBloc()..add(FetchStudentsEvent()),
      child: const _StudentDirectoryContentView(),
    );
  }
}

class _StudentDirectoryContentView extends StatefulWidget {
  const _StudentDirectoryContentView();

  @override
  State<_StudentDirectoryContentView> createState() => _StudentDirectoryContentViewState();
}

class _StudentDirectoryContentViewState extends State<_StudentDirectoryContentView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDept = 'All';
  int _navIndex = 3;

  final List<String> _departments = ['All', 'CSE', 'ECE', 'ME', 'Civil', 'IT'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/students'),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            HapticFeedback.lightImpact();
            context.read<StudentDirectoryBloc>().add(
                  FetchStudentsEvent(
                    query: _searchController.text,
                    department: _selectedDept,
                  ),
                );
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header Bar
                _buildHeaderBar(context),
                const SizedBox(height: 16),

                // 2. Quick Route Shortcut Cards to Screen 9 (Readiness) & Screen 10 (At-Risk)
                _buildQuickRouteBanners(context),
                const SizedBox(height: 16),

                // 3. Search & Filter Bar
                _buildSearchBar(context),
                const SizedBox(height: 14),

                // 4. Department Chips Filter Carousel
                _buildDepartmentChips(context),
                const SizedBox(height: 16),

                // 5. Student List Content
                BlocBuilder<StudentDirectoryBloc, StudentDirectoryState>(
                  builder: (context, state) {
                    if (state is StudentDirectoryLoading) {
                      return const SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      );
                    }

                    final students = (state is StudentDirectoryLoaded)
                        ? state.students
                        : CollegeStudentModel.mockStudents;

                    if (students.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Icon(LucideIcons.userX, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'No Students Found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Try searching for a different name, skill, or department.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _selectedDept = 'All');
                                context.read<StudentDirectoryBloc>().add(FetchStudentsEvent());
                              },
                              child: const Text('Clear Filters'),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Result Count Summary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Showing ${students.length} Students',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                // Route to Screen 10: At-Risk Students
                                context.go('/college/students/at-risk');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.errorLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(LucideIcons.alertTriangle, size: 12, color: AppColors.error),
                                    SizedBox(width: 4),
                                    Text(
                                      'View At-Risk Center ➔',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Student Cards List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return RepaintBoundary(
                              child: _buildStudentCard(context, student),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() => _navIndex = index);
          _handleNavigation(index);
        },
        onFabPressed: () => _showAddStudentModal(context),
      ),
    );
  }

  // --- 1. Top Header Bar ---
  Widget _buildHeaderBar(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (scaffoldContext) {
            return InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Scaffold.of(scaffoldContext).openDrawer();
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(LucideIcons.menu, size: 20, color: AppColors.textPrimary),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student Directory',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Batch 2025 Master Student Records',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. Quick Route Shortcut Banners (Screen 9 & Screen 10 Triggers) ---
  Widget _buildQuickRouteBanners(BuildContext context) {
    return Row(
      children: [
        // Shortcut to Screen 9: Readiness Analytics
        Expanded(
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              // Route to Screen 9
              context.go('/college/analytics/readiness');
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.target, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          'Readiness Analytics',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Screen 9 ➔',
                          style: TextStyle(fontSize: 10, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Shortcut to Screen 10: At-Risk Students
        Expanded(
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              // Route to Screen 10
              context.go('/college/students/at-risk');
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          'At-Risk Students',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        Text(
                          'Screen 10 ➔',
                          style: TextStyle(fontSize: 10, color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. Search Input Bar ---
  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: (val) {
        context.read<StudentDirectoryBloc>().add(
              FetchStudentsEvent(
                query: val,
                department: _selectedDept,
              ),
            );
      },
      decoration: InputDecoration(
        hintText: 'Search by name, roll no, or skill...',
        prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textMuted),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                onPressed: () {
                  _searchController.clear();
                  context.read<StudentDirectoryBloc>().add(
                        FetchStudentsEvent(
                          query: '',
                          department: _selectedDept,
                        ),
                      );
                },
              )
            : null,
      ),
    );
  }

  // --- 4. Department Filter Chips Carousel ---
  Widget _buildDepartmentChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _departments.map((dept) {
          final isSelected = _selectedDept == dept;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(dept),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
              onSelected: (selected) {
                if (selected) {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedDept = dept);
                  context.read<StudentDirectoryBloc>().add(
                        FetchStudentsEvent(
                          query: _searchController.text,
                          department: dept,
                        ),
                      );
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 5. Student Card Widget ---
  Widget _buildStudentCard(BuildContext context, CollegeStudentModel student) {
    Color statusBgColor;
    Color statusTextColor;
    if (student.placementStatus == 'Placed') {
      statusBgColor = AppColors.successLight;
      statusTextColor = AppColors.success;
    } else if (student.isAtRisk) {
      statusBgColor = AppColors.errorLight;
      statusTextColor = AppColors.error;
    } else {
      statusBgColor = AppColors.primaryLight;
      statusTextColor = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: student.isAtRisk ? AppColors.error.withValues(alpha: 0.3) : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // Navigate to Screen 3: Student Detail
          context.go('/college/students/${student.id}');
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Hero Avatar Widget
                  Hero(
                    tag: 'student-avatar-${student.id}',
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        student.name.isNotEmpty ? student.name.substring(0, 1) : 'S',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Student Name & Roll Code
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AutoSizeText(
                                student.name,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: student.isAtRisk
                                  ? () {
                                      HapticFeedback.lightImpact();
                                      // Navigate to Screen 10 if At-Risk badge clicked
                                      context.go('/college/students/at-risk');
                                    }
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusBgColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  student.placementStatus,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${student.studentCode} • ${student.department}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Metrics Pill Row
              Row(
                children: [
                  _buildMetricPill('CGPA', '${student.cgpa}', AppColors.inputFill, AppColors.textPrimary),
                  const SizedBox(width: 8),

                  // Interactive Readiness Score Pill ➔ Routes explicitly to Screen 9
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Navigate to Screen 9: Readiness Analytics
                      context.go('/college/analytics/readiness');
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.target, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Readiness: ${student.readinessScore}% ➔',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${student.attendance}% Attd',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Skills Chips Wrap
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: student.skills.take(4).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.tagBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(fontSize: 10, color: AppColors.tagText),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricPill(String label, String val, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $val',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textCol,
        ),
      ),
    );
  }

  void _showAddStudentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Student Record',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              const TextField(decoration: InputDecoration(hintText: 'Student Full Name')),
              const SizedBox(height: 10),
              const TextField(decoration: InputDecoration(hintText: 'Roll Number (e.g. C2C-2024-8890)')),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Create Record'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        context.go('/college/dashboard');
        break;
      case 1:
        context.go('/college/drives');
        break;
      case 3:
        context.go('/college/students');
        break;
      case 4:
        context.go('/college/operations/config');
        break;
    }
  }
}
