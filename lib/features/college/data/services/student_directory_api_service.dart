import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../domain/models/college_student_model.dart';

class StudentDirectoryApiService {
  final DioClient _dioClient;

  StudentDirectoryApiService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Fetch all students with optional search query and department filter
  Future<List<CollegeStudentModel>> fetchStudents({
    String query = '',
    String department = 'All',
  }) async {
    try {
      final response = await _dioClient.instance.get(
        '/college/students',
        queryParameters: {
          if (query.isNotEmpty) 'search': query,
          if (department != 'All') 'department': department,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        return list.map((e) => CollegeStudentModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return _filterMockStudents(query, department);
    } on DioException catch (_) {
      return _filterMockStudents(query, department);
    } catch (_) {
      return _filterMockStudents(query, department);
    }
  }

  /// Fetch single student details by ID
  Future<CollegeStudentModel> fetchStudentById(String id) async {
    try {
      final response = await _dioClient.instance.get('/college/students/$id');
      if (response.statusCode == 200 && response.data != null) {
        return CollegeStudentModel.fromJson(response.data as Map<String, dynamic>);
      }
      return CollegeStudentModel.mockStudents.firstWhere(
        (s) => s.id == id,
        orElse: () => CollegeStudentModel.mockStudents.first,
      );
    } on DioException catch (_) {
      return CollegeStudentModel.mockStudents.firstWhere(
        (s) => s.id == id,
        orElse: () => CollegeStudentModel.mockStudents.first,
      );
    } catch (_) {
      return CollegeStudentModel.mockStudents.firstWhere(
        (s) => s.id == id,
        orElse: () => CollegeStudentModel.mockStudents.first,
      );
    }
  }

  List<CollegeStudentModel> _filterMockStudents(String query, String department) {
    return CollegeStudentModel.mockStudents.where((student) {
      final matchesQuery = query.isEmpty ||
          student.name.toLowerCase().contains(query.toLowerCase()) ||
          student.studentCode.toLowerCase().contains(query.toLowerCase()) ||
          student.skills.any((s) => s.toLowerCase().contains(query.toLowerCase()));

      final matchesDept = department == 'All' ||
          student.department.toLowerCase() == department.toLowerCase() ||
          (department == 'CSE' && student.department == 'Computer Science') ||
          (department == 'ME' && student.department == 'Mechanical');

      return matchesQuery && matchesDept;
    }).toList();
  }
}
