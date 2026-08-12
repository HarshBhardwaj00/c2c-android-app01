import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../domain/models/departmental_analytics_model.dart';

class DepartmentalAnalyticsApiService {
  final DioClient _dioClient;

  DepartmentalAnalyticsApiService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Fetch full departmental analytics metrics payload
  Future<DepartmentalAnalyticsDataModel> fetchDepartmentalAnalytics({
    String selectedDept = 'CS',
    String batchYear = '2024',
  }) async {
    try {
      final response = await _dioClient.instance.get(
        '/college/analytics/department',
        queryParameters: {
          'dept': selectedDept,
          'batch': batchYear,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return DepartmentalAnalyticsDataModel.fromJson(response.data as Map<String, dynamic>);
      }
      return DepartmentalAnalyticsDataModel.mockData;
    } on DioException catch (_) {
      // Handles 401, 404, 500 & Connection timeout -> fallback to mockData
      return DepartmentalAnalyticsDataModel.mockData;
    } catch (_) {
      return DepartmentalAnalyticsDataModel.mockData;
    }
  }
}
