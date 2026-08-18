import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';

import '../../features/student/presentation/pages/student_dashboard_page.dart';
import '../../features/student/presentation/pages/ai_resume_page.dart';
import '../../features/student/presentation/pages/student_notifications_page.dart';
import '../../features/student/presentation/pages/student_applied_projects_page.dart';
import '../../features/student/presentation/pages/student_hiring_process_page.dart';
import '../../features/student/presentation/pages/student_certificates_page.dart';
import '../../features/student/presentation/pages/student_settings_page.dart';
import '../../features/student/presentation/pages/student_profile_page.dart';
import '../../features/student/presentation/pages/student_project_list_page.dart';
import '../../features/student/presentation/pages/ask_ai_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/mentor/presentation/pages/mentor_dashboard_page.dart';
import '../../features/recruiter/presentation/pages/recruiter_dashboard_page.dart';

import 'package:lucide_icons/lucide_icons.dart';

// College Module Page Imports
import '../../features/college/presentation/pages/college_dashboard_page.dart';
import '../../features/college/presentation/pages/student_directory_page.dart';
import '../../features/college/presentation/pages/college_student_detail_page.dart';
import '../../features/college/presentation/pages/placement_hub_page.dart';
import '../../features/college/presentation/pages/job_pipeline_page.dart';
import '../../features/college/presentation/pages/company_insights_page.dart';
import '../../features/college/presentation/pages/departmental_analytics_page.dart';
import '../../features/college/presentation/pages/department_comparison_page.dart';
import '../../features/college/presentation/pages/student_readiness_analytics_page.dart';
import '../../features/college/presentation/pages/at_risk_students_page.dart';
import '../../features/college/presentation/pages/placement_intelligence_page.dart';
import '../../features/college/presentation/pages/assessments_learning_page.dart';
import '../../features/college/presentation/pages/communication_hub_page.dart';
import '../../features/college/presentation/pages/institutional_config_page.dart';
import '../../features/college/presentation/pages/reports_admin_analytics_page.dart';
import '../../features/college/presentation/pages/college_generic_view_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth/role-select',
    routes: [
      // Authentication Routes
      GoRoute(
        path: '/auth/role-select',
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: '/auth/register/:role',
        builder: (context, state) {
          final role = state.pathParameters['role'] ?? 'student';
          return RegisterPage(role: role);
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      // Role Dashboards
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/mentor/dashboard',
        builder: (context, state) => const MentorDashboardPage(),
      ),
      GoRoute(
        path: '/recruiter/dashboard',
        builder: (context, state) => const RecruiterDashboardPage(),
      ),

      // Student Module Routes
      GoRoute(
        path: '/student/dashboard',
        builder: (context, state) => const StudentDashboardPage(),
      ),
      GoRoute(
        path: '/student/projects',
        builder: (context, state) => const StudentProjectListPage(),
      ),
      GoRoute(
        path: '/student/project-list',
        builder: (context, state) => const StudentProjectListPage(),
      ),
      GoRoute(
        path: '/student/directory',
        builder: (context, state) => const StudentDirectoryPage(),
      ),
      GoRoute(
        path: '/student/ai-resume',
        builder: (context, state) => const StudentAIResumePage(),
      ),
      GoRoute(
        path: '/student/ai-resume-builder',
        builder: (context, state) => const StudentAIResumePage(),
      ),
      GoRoute(
        path: '/student/notifications',
        builder: (context, state) => const StudentNotificationsPage(),
      ),
      GoRoute(
        path: '/student/applied-projects',
        builder: (context, state) => const StudentAppliedProjectsPage(),
      ),
      GoRoute(
        path: '/student/hiring-process',
        builder: (context, state) => const StudentHiringProcessPage(),
      ),
      GoRoute(
        path: '/student/certificates',
        builder: (context, state) => const StudentCertificatesPage(),
      ),
      GoRoute(
        path: '/student/settings',
        builder: (context, state) => const StudentSettingsPage(),
      ),
      GoRoute(
        path: '/student/profile',
        builder: (context, state) => const StudentProfilePage(),
      ),
      GoRoute(
        path: '/student/ask-ai',
        builder: (context, state) => const AskAiPage(),
      ),
      GoRoute(
        path: '/student/ai-coach',
        builder: (context, state) => const AskAiPage(),
      ),

      // ==========================================
      // College Module Routes (Screens 1 to 15)
      // ==========================================
      
      // Screen 1: Executive Overview / College Dashboard
      GoRoute(
        path: '/college/dashboard',
        builder: (context, state) => const CollegeDashboardPage(),
      ),

      // Screen 2: Student Directory
      GoRoute(
        path: '/college/students',
        builder: (context, state) => const StudentDirectoryPage(),
      ),

      // Screen 10: At-Risk Students (Registered before :id parameter route)
      GoRoute(
        path: '/college/students/at-risk',
        builder: (context, state) => const AtRiskStudentsPage(),
      ),

      // Screen 3: Student Profile & AI Resume Detail
      GoRoute(
        path: '/college/students/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 's1';
          return CollegeStudentDetailPage(studentId: id);
        },
      ),

      // Screen 4: Placement Hub / Coordinator Hub
      GoRoute(
        path: '/college/drives',
        builder: (context, state) => const PlacementHubPage(),
      ),

      // Screen 5: Job Pipeline Tracker
      GoRoute(
        path: '/college/drives/:id/pipeline',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'd1';
          return JobPipelinePage(driveId: id);
        },
      ),

      // Screen 6: Company & Recruiter Insights
      GoRoute(
        path: '/college/companies/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'c1';
          return CompanyInsightsPage(companyId: id);
        },
      ),

      // Screen 7: Departmental Analytics
      GoRoute(
        path: '/college/analytics/department',
        builder: (context, state) => const DepartmentalAnalyticsPage(),
      ),

      // Screen 8: Department Comparison
      GoRoute(
        path: '/college/analytics/compare',
        builder: (context, state) => const DepartmentComparisonPage(),
      ),

      // Screen 9: Student Readiness Analytics
      GoRoute(
        path: '/college/analytics/readiness',
        builder: (context, state) => const StudentReadinessAnalyticsPage(),
      ),

      // Screen 11: Placement Intelligence
      GoRoute(
        path: '/college/analytics/intelligence',
        builder: (context, state) => const PlacementIntelligencePage(),
      ),

      // Screen 12: Assessments & Learning Analytics
      GoRoute(
        path: '/college/analytics/assessments',
        builder: (context, state) => const AssessmentsLearningPage(),
      ),

      // Screen 13: Communication / Broadcast Center
      GoRoute(
        path: '/college/operations/communication',
        builder: (context, state) => const CommunicationHubPage(),
      ),
      GoRoute(
        path: '/college/broadcast',
        builder: (context, state) => const CommunicationHubPage(),
      ),

      // Screen 14: Institutional Configuration / Settings
      GoRoute(
        path: '/college/operations/config',
        builder: (context, state) => const InstitutionalConfigPage(),
      ),
      GoRoute(
        path: '/college/settings',
        builder: (context, state) => const InstitutionalConfigPage(),
      ),

      // Screen 15: Reports & Admin Analytics
      GoRoute(
        path: '/college/reports',
        builder: (context, state) => const ReportsAdminAnalyticsPage(),
      ),

      // Route 5: Recruiter Coordination
      GoRoute(
        path: '/college/recruiters',
        builder: (context, state) => const CollegeGenericViewPage(
          title: 'Recruiter Coordination',
          currentRoute: '/college/recruiters',
          icon: LucideIcons.userCheck,
          description: 'Coordinate with corporate recruiters, manage partner company relationships, and schedule campus hiring rounds.',
        ),
      ),

      // Route 6: Batch Groups
      GoRoute(
        path: '/college/batches',
        builder: (context, state) => const CollegeGenericViewPage(
          title: 'Batch Groups',
          currentRoute: '/college/batches',
          icon: LucideIcons.users,
          description: 'Manage academic graduating batches, department sections, and student placement eligibility groups.',
        ),
      ),

      // Placements Alias
      GoRoute(
        path: '/college/placements',
        builder: (context, state) => const PlacementHubPage(),
      ),
    ],
  );
}
