import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/college_dashboard_model.dart';

class CollegeApiService {
  final DioClient _dioClient;

  CollegeApiService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Fetches executive overview dashboard data, profile, drives, and applications from backend.
  Future<CollegeDashboardModel> fetchDashboardData() async {
    Map<String, dynamic> dashboardJson = {};
    Map<String, dynamic> profileJson = {};
    List<CampusDriveModel> projectsList = [];
    int totalApplicationsCount = 0;

    // 1. Fetch College Profile (/college/profile)
    try {
      final profRes = await _dioClient.instance.get('/college/profile');
      if (profRes.statusCode == 200 && profRes.data != null) {
        final body = profRes.data is Map<String, dynamic> ? profRes.data as Map<String, dynamic> : <String, dynamic>{};
        profileJson = body['data'] is Map<String, dynamic> ? body['data'] as Map<String, dynamic> : body;
      }
    } catch (_) {}

    // 2. Fetch College Dashboard Metrics (/college/dashboard)
    try {
      final dashRes = await _dioClient.instance.get(ApiEndpoints.collegeDashboard);
      if (dashRes.statusCode == 200 && dashRes.data != null) {
        final body = dashRes.data is Map<String, dynamic> ? dashRes.data as Map<String, dynamic> : <String, dynamic>{};
        dashboardJson = body['data'] is Map<String, dynamic> ? body['data'] as Map<String, dynamic> : body;
      }
    } catch (_) {}

    // 3. Fetch Placement Projects / Drives (/college/projects)
    try {
      final projRes = await _dioClient.instance.get('/college/projects');
      if (projRes.statusCode == 200 && projRes.data != null) {
        final body = projRes.data is Map<String, dynamic> ? projRes.data as Map<String, dynamic> : <String, dynamic>{};
        final list = body['data'] is List ? body['data'] as List : <dynamic>[];
        projectsList = list.whereType<Map<String, dynamic>>().map((e) => CampusDriveModel.fromJson(e)).toList();
      }
    } catch (_) {}

    // 4. Fetch Applications (/college/applications)
    try {
      final appRes = await _dioClient.instance.get('/college/applications');
      if (appRes.statusCode == 200 && appRes.data != null) {
        final body = appRes.data is Map<String, dynamic> ? appRes.data as Map<String, dynamic> : <String, dynamic>{};
        final list = body['data'] is List ? body['data'] as List : <dynamic>[];
        totalApplicationsCount = list.length;
      }
    } catch (_) {}

    if (dashboardJson.isNotEmpty || profileJson.isNotEmpty) {
      if (projectsList.isNotEmpty) {
        dashboardJson['upcomingDrives'] = projectsList;
        dashboardJson['totalProjects'] = projectsList.length;
      }
      if (totalApplicationsCount > 0) {
        dashboardJson['totalApplications'] = totalApplicationsCount;
        dashboardJson['upcomingInterviews'] = totalApplicationsCount;
      }
      return CollegeDashboardModel.fromJson(dashboardJson, profile: profileJson);
    }

    return CollegeDashboardModel.mockData;
  }

  /// Creates a new campus placement drive / project in backend (POST /college/projects)
  Future<bool> createPlacementDrive(Map<String, dynamic> payload) async {
    try {
      final response = await _dioClient.instance.post(
        '/college/projects',
        data: {
          'title': '${payload['companyName']} - ${payload['jobRole']}',
          'description': 'Campus Placement Drive for ${payload['companyName']} for role ${payload['jobRole']}. CTC: ${payload['packageLPA']} LPA.',
          'skillsRequired': payload['eligibleBranches'] ?? ['CSE', 'ECE', 'IT', 'Mechanical'],
          'domain': 'Engineering / Tech',
          'difficulty': 'Intermediate',
          'duration': 'Full Time',
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (dioErr) {
      throw Exception(_extractErrorMessage(dioErr));
    } catch (e) {
      throw Exception('Failed to schedule placement drive: ${e.toString()}');
    }
  }

  /// Registers / invites a student in backend (POST /college/students)
  Future<bool> inviteStudents({required String emails, String? batch}) async {
    try {
      final emailList = emails.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      for (final email in emailList) {
        await _dioClient.instance.post(
          ApiEndpoints.collegeStudents,
          data: {
            'email': email.toLowerCase(),
            'name': email.split('@').first.replaceAll('.', ' ').toUpperCase(),
            'branch': batch ?? 'Computer Science',
            'semester': 5,
            'percentage': 75.0,
            'status': 'Active',
          },
        );
      }
      return true;
    } on DioException catch (dioErr) {
      throw Exception(_extractErrorMessage(dioErr));
    } catch (e) {
      throw Exception('Failed to invite candidates: ${e.toString()}');
    }
  }

  /// Broadcast announcement simulation
  Future<bool> sendBroadcast({required String subject, required String message}) async {
    return true;
  }

  String _extractErrorMessage(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      return 'Unable to connect to backend server. Please verify backend connection.';
    }

    if (err.response?.data != null && err.response?.data is Map) {
      final map = err.response?.data as Map;
      if (map.containsKey('message') && map['message'] != null) {
        return map['message'].toString();
      }
      if (map.containsKey('error') && map['error'] != null) {
        return map['error'].toString();
      }
    }

    return 'Network request failed (${err.response?.statusCode ?? 'Unknown'}).';
  }
}
