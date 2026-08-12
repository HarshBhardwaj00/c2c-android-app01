import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../domain/models/college_student_model.dart';
import '../../data/services/student_directory_api_service.dart';
import '../widgets/college_drawer.dart';

class CollegeStudentDetailPage extends StatefulWidget {
  final String studentId;

  const CollegeStudentDetailPage({super.key, required this.studentId});

  @override
  State<CollegeStudentDetailPage> createState() => _CollegeStudentDetailPageState();
}

class _CollegeStudentDetailPageState extends State<CollegeStudentDetailPage> {
  late Future<CollegeStudentModel> _studentFuture;
  int _navIndex = 3;

  @override
  void initState() {
    super.initState();
    _studentFuture = StudentDirectoryApiService().fetchStudentById(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/students'),
      appBar: AppBar(
        title: const Text('Student Profile & AI Resume'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.go('/college/students');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Student profile link copied to clipboard!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<CollegeStudentModel>(
          future: _studentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final student = snapshot.data ?? CollegeStudentModel.mockStudents.first;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Hero Header Profile Card
                  _buildProfileHeaderCard(context, student),
                  const SizedBox(height: 16),

                  // 2. Metrics Grid (CGPA, Attendance, Backlogs, Readiness)
                  _buildAcademicMetricsGrid(context, student),
                  const SizedBox(height: 16),

                  // 3. Readiness Breakdown Banner ➔ Routes to Screen 9
                  _buildReadinessBreakdownBanner(context, student),
                  const SizedBox(height: 16),

                  // 4. AI Resume & ATS Score Section
                  _buildAiResumeCard(context, student),
                  const SizedBox(height: 16),

                  // 5. Applied Placement Drives Timeline
                  _buildAppliedDrivesSection(context, student),
                  const SizedBox(height: 16),

                  // 6. TPO Admin Quick Actions
                  _buildTpoActionButtons(context, student),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() => _navIndex = index);
          _handleNavigation(index);
        },
        onFabPressed: () {},
      ),
    );
  }

  // --- 1. Profile Header Card ---
  Widget _buildProfileHeaderCard(BuildContext context, CollegeStudentModel student) {
    Color statusBg = student.placementStatus == 'Placed' ? AppColors.successLight : AppColors.primaryLight;
    Color statusText = student.placementStatus == 'Placed' ? AppColors.success : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(18),
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
        children: [
          Row(
            children: [
              // Hero Avatar Widget
              Hero(
                tag: 'student-avatar-${student.id}',
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    student.name.isNotEmpty ? student.name.substring(0, 1) : 'S',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            student.placementStatus,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${student.studentCode} • ${student.department}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Class of ${student.batch} • ${student.year}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Contact Details Row
          Row(
            children: [
              const Icon(LucideIcons.mail, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  student.email,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              const Icon(LucideIcons.phone, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                student.phone,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. Core Academic & Placement Metrics Grid ---
  Widget _buildAcademicMetricsGrid(BuildContext context, CollegeStudentModel student) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'CGPA',
            value: '${student.cgpa}',
            subtitle: 'Scale 10.0',
            icon: LucideIcons.award,
            color: AppColors.primary,
            bgColor: AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            title: 'ATTENDANCE',
            value: '${student.attendance}%',
            subtitle: 'Eligible',
            icon: LucideIcons.calendarCheck,
            color: AppColors.success,
            bgColor: AppColors.successLight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            title: 'BACKLOGS',
            value: '${student.activeBacklogs}',
            subtitle: student.activeBacklogs == 0 ? 'Clear' : 'Active',
            icon: LucideIcons.fileX,
            color: student.activeBacklogs == 0 ? AppColors.success : AppColors.error,
            bgColor: student.activeBacklogs == 0 ? AppColors.successLight : AppColors.errorLight,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AutoSizeText(
            value,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- 3. Readiness Breakdown Action Banner ➔ Routes to Screen 9 ---
  Widget _buildReadinessBreakdownBanner(BuildContext context, CollegeStudentModel student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.target, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Student Placement Readiness',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${student.readinessScore}% Score',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Evaluated across Technical Coding, Aptitude, Soft Skills, and Domain Benchmarks.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // Explicit Navigation Trigger to Screen 9: Readiness Analytics
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                // Route to Screen 9: Student Readiness Analytics
                context.go('/college/analytics/readiness');
              },
              icon: const Icon(LucideIcons.sparkles, size: 16),
              label: const Text(
                'View Detailed Readiness Breakdown ➔',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. AI Resume & ATS Score Card ---
  Widget _buildAiResumeCard(BuildContext context, CollegeStudentModel student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI Resume & ATS Benchmark',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ATS: ${student.atsScore}/100',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            student.bio,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),

          // Verified Skills
          const Text(
            'Verified Skill Competencies:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: student.skills.map((skill) {
              return Chip(
                label: Text(skill),
                backgroundColor: AppColors.primaryLight,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Download PDF Resume Action Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading AI Resume PDF for ${student.name}...')),
                );
              },
              icon: const Icon(LucideIcons.fileText, size: 16),
              label: const Text('Download AI Resume (PDF)'),
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Applied Placement Drives Section ---
  Widget _buildAppliedDrivesSection(BuildContext context, CollegeStudentModel student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Applied Campus Placement Drives',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          if (student.appliedDrives.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No active placement drive applications yet.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            )
          else
            Column(
              children: student.appliedDrives.map((drive) {
                Color statusColor = drive.status == 'Offered'
                    ? AppColors.success
                    : drive.status == 'Shortlisted'
                        ? AppColors.primary
                        : AppColors.textSecondary;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.building2, size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              drive.companyName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              drive.role,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            drive.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          Text(
                            drive.date,
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // --- 6. TPO Admin Quick Actions ---
  Widget _buildTpoActionButtons(BuildContext context, CollegeStudentModel student) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mock interview scheduled for ${student.name}')),
              );
            },
            icon: const Icon(LucideIcons.calendar, size: 14),
            label: const AutoSizeText('Schedule Mock', maxLines: 1, style: TextStyle(fontSize: 11)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.go('/college/operations/communication');
            },
            icon: const Icon(LucideIcons.send, size: 14),
            label: const AutoSizeText('Send Alert', maxLines: 1, style: TextStyle(fontSize: 11)),
          ),
        ),
      ],
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
