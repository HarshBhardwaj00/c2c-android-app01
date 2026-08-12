import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../domain/models/department_comparison_model.dart';

class DepartmentComparisonApiService {
  final DioClient _dioClient;

  DepartmentComparisonApiService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Fetch full department comparison benchmarking payload
  Future<DepartmentComparisonDataModel> fetchDepartmentComparison({
    String primaryDept = 'CS',
    String secondaryDept = 'MECH',
  }) async {
    try {
      final response = await _dioClient.instance.get(
        '/college/analytics/compare',
        queryParameters: {
          'primary': primaryDept,
          'secondary': secondaryDept,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return DepartmentComparisonDataModel.fromJson(response.data as Map<String, dynamic>);
      }
      return DepartmentComparisonDataModel.mockData;
    } on DioException catch (_) {
      // Handles 401, 404, 500 & Connection timeouts gracefully
      return DepartmentComparisonDataModel.mockData;
    } catch (_) {
      return DepartmentComparisonDataModel.mockData;
    }
  }
}
