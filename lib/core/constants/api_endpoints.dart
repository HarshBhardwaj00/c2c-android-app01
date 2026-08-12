import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoints {
  static const String _overrideUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// Dynamically computes the backend base URL depending on the platform:
  /// - Web / Chrome: http://localhost:5000/api
  /// - Android Emulator: http://10.0.2.2:5000/api (10.0.2.2 points to host machine loopback)
  /// - iOS / Desktop: http://127.0.0.1:5000/api
  static String get baseUrl {
    if (_overrideUrl.isNotEmpty) return _overrideUrl;
    if (kIsWeb) return 'http://localhost:5000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
    } catch (_) {
      // Fallback if Platform check fails
    }
    return 'http://127.0.0.1:5000/api';
  }

  // Auth Endpoints (Student / General)
  static const String login = '/auth/login';
  static const String login2faVerify = '/auth/2fa/verify';
  static const String loginReactivate = '/auth/reactivate';
  static const String register = '/auth/register';
  static const String me = '/auth/me';

  // Admin Auth Endpoints
  static const String adminLogin = '/admin/login';
  static const String adminRegister = '/admin/register';

  // College Auth Endpoints
  static const String collegeLogin = '/college/login';
  static const String collegeRegister = '/college/register';

  // Student
  static const String studentProfile = '/student/profile';
  static const String aiResume = '/student/ai-resume';
  static const String assessments = '/student/assessments';

  // College TPO
  static const String collegeDashboard = '/college/dashboard';
  static const String collegeStudents = '/college/students';

  // College Analytics - Assessments
  static const String collegeAssessments = '/college/analytics/assessments';
  static const String collegeAssessmentDetail = '/college/analytics/assessments/detail';

  // College Operations - Communication
  static const String collegeCommunication = '/college/operations/communication';
  static const String collegeBroadcast = '/college/operations/communication/broadcast';

  // College Operations - Configuration
  static const String collegeConfig = '/college/operations/config';
  static const String collegeConfigBranding = '/college/operations/config/branding';
  static const String collegeConfigSecurity = '/college/operations/config/security';

  // College Reports & Analytics
  static const String collegeReports = '/college/reports';
  static const String collegeReportsExport = '/college/reports/export';

  // Admin
  static const String adminUsers = '/admin/users';
  static const String adminAnalytics = '/admin/analytics';
}
