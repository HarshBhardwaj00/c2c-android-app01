import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/college_student_model.dart';

class StudentDirectoryApiService {
  final DioClient _dioClient;

  StudentDirectoryApiService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Fetch all students registered under the authenticated college
  Future<List<CollegeStudentModel>> fetchStudents({
    String query = '',
    String department = 'All',
  }) async {
    try {
      final response = await _dioClient.instance.get(
        ApiEndpoints.collegeStudents,
        queryParameters: {
          if (query.isNotEmpty) 'search': query,
          if (department != 'All') 'department': department,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> list = [];
        if (response.data is Map && response.data['data'] is List) {
          list = response.data['data'] as List<dynamic>;
        } else if (response.data is List) {
          list = response.data as List<dynamic>;
        }

        final mapped = list
            .whereType<Map<String, dynamic>>()
            .map((e) => CollegeStudentModel.fromJson(e))
            .toList();

        return _filterStudents(mapped, query, department);
      }
      return [];
    } on DioException catch (dioErr) {
      final errMsg = _extractErrorMessage(dioErr);
      throw Exception(errMsg);
    } catch (e) {
      throw Exception('Failed to fetch students: ${e.toString()}');
    }
  }

  /// Create a new student record in backend MongoDB database
  Future<CollegeStudentModel> createStudent(Map<String, dynamic> studentData) async {
    try {
      // Align payload with backend Mongoose schema requirements
      final payload = <String, dynamic>{
        'name': studentData['name']?.toString().trim(),
        'email': studentData['email']?.toString().trim().toLowerCase(),
        'phone': studentData['phone']?.toString().trim() ?? '',
        'branch': studentData['branch']?.toString() ?? studentData['department']?.toString() ?? 'Computer Science',
        'semester': (studentData['semester'] as num?)?.toInt() ?? 5,
        'percentage': (studentData['percentage'] as num?)?.toDouble() ?? 75.0,
        'status': studentData['status']?.toString() ?? 'Active',
      };

      if (studentData['bio'] != null && studentData['bio'].toString().isNotEmpty) {
        payload['bio'] = studentData['bio'].toString();
      }
      if (studentData['skills'] != null && studentData['skills'] is List) {
        payload['skills'] = studentData['skills'];
      }

      final response = await _dioClient.instance.post(
        ApiEndpoints.collegeStudents,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map && response.data['data'] != null
            ? response.data['data']
            : response.data;
        return CollegeStudentModel.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Failed to create student record: Unexpected response');
    } on DioException catch (dioErr) {
      final errMsg = _extractErrorMessage(dioErr);
      throw Exception(errMsg);
    } catch (e) {
      throw Exception('Error adding student: ${e.toString()}');
    }
  }

  /// Update an existing student record in backend
  Future<CollegeStudentModel> updateStudent(String id, Map<String, dynamic> studentData) async {
    try {
      final payload = <String, dynamic>{};
      if (studentData.containsKey('name')) payload['name'] = studentData['name']?.toString().trim();
      if (studentData.containsKey('email')) payload['email'] = studentData['email']?.toString().trim().toLowerCase();
      if (studentData.containsKey('phone')) payload['phone'] = studentData['phone']?.toString().trim();
      if (studentData.containsKey('branch') || studentData.containsKey('department')) {
        payload['branch'] = studentData['branch']?.toString() ?? studentData['department']?.toString();
      }
      if (studentData.containsKey('semester')) payload['semester'] = (studentData['semester'] as num?)?.toInt();
      if (studentData.containsKey('percentage')) payload['percentage'] = (studentData['percentage'] as num?)?.toDouble();
      if (studentData.containsKey('status')) payload['status'] = studentData['status']?.toString();
      if (studentData.containsKey('bio')) payload['bio'] = studentData['bio']?.toString();

      final response = await _dioClient.instance.put(
        '${ApiEndpoints.collegeStudents}/$id',
        data: payload,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map && response.data['data'] != null
            ? response.data['data']
            : response.data;
        return CollegeStudentModel.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Failed to update student record');
    } on DioException catch (dioErr) {
      final errMsg = _extractErrorMessage(dioErr);
      throw Exception(errMsg);
    } catch (e) {
      throw Exception('Error updating student: ${e.toString()}');
    }
  }

  /// Delete a student record from backend
  Future<bool> deleteStudent(String id) async {
    try {
      final response = await _dioClient.instance.delete(
        '${ApiEndpoints.collegeStudents}/$id',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (dioErr) {
      final errMsg = _extractErrorMessage(dioErr);
      throw Exception(errMsg);
    } catch (e) {
      throw Exception('Error deleting student: ${e.toString()}');
    }
  }

  /// Fetch single student details by ID
  Future<CollegeStudentModel> fetchStudentById(String id) async {
    try {
      final response = await _dioClient.instance.get('${ApiEndpoints.collegeStudents}/$id');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map && response.data['data'] != null
            ? response.data['data']
            : response.data;
        return CollegeStudentModel.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Student record not found');
    } on DioException catch (dioErr) {
      final errMsg = _extractErrorMessage(dioErr);
      throw Exception(errMsg);
    } catch (e) {
      throw Exception('Error fetching student details: ${e.toString()}');
    }
  }

  /// Fetch eligible students list (percentage >= 80)
  Future<List<CollegeStudentModel>> fetchEligibleStudents() async {
    try {
      final response = await _dioClient.instance.get('${ApiEndpoints.collegeStudents}/eligible');
      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> list = [];
        if (response.data is Map && response.data['data'] is List) {
          list = response.data['data'] as List<dynamic>;
        } else if (response.data is List) {
          list = response.data as List<dynamic>;
        }
        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => CollegeStudentModel.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (dioErr) {
      throw Exception(_extractErrorMessage(dioErr));
    } catch (e) {
      throw Exception('Error fetching eligible students: ${e.toString()}');
    }
  }

  List<CollegeStudentModel> _filterStudents(List<CollegeStudentModel> list, String query, String department) {
    return list.where((student) {
      final q = query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          student.name.toLowerCase().contains(q) ||
          student.studentCode.toLowerCase().contains(q) ||
          student.email.toLowerCase().contains(q) ||
          student.skills.any((s) => s.toLowerCase().contains(q));

      final matchesDept = department == 'All' ||
          department == 'All Departments' ||
          student.department.toLowerCase() == department.toLowerCase() ||
          (department == 'CSE' && (student.department.contains('CSE') || student.department.contains('Computer'))) ||
          (department == 'ECE' && (student.department.contains('ECE') || student.department.contains('Electronics'))) ||
          (department == 'Mechanical' && student.department.contains('Mech')) ||
          (department == 'IT' && student.department.contains('IT'));

      return matchesQuery && matchesDept;
    }).toList();
  }

  String _extractErrorMessage(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      return 'Unable to connect to backend server (${ApiEndpoints.baseUrl}). Please verify that backend is running.';
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

    switch (err.response?.statusCode) {
      case 400:
        return 'Invalid student data. Please check all required fields.';
      case 401:
        return 'Session expired. Please log in again.';
      case 404:
        return 'Student record not found in database.';
      case 500:
        return 'Server error processing student record.';
      default:
        return 'Network error (${err.response?.statusCode ?? 'Unknown'}). Please try again.';
    }
  }
}
