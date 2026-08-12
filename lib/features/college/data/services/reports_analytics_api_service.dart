import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../domain/models/reports_analytics_model.dart';

class ReportsAnalyticsApiService {
  final DioClient _dioClient;

  ReportsAnalyticsApiService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<ReportsAnalyticsDataModel> fetchReportsData({
    String? year,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;

      final response = await _dioClient.instance.get(
        '/college/reports',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return ReportsAnalyticsDataModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return ReportsAnalyticsDataModel.mockData;
    } on DioException catch (_) {
      return ReportsAnalyticsDataModel.mockData;
    } catch (_) {
      return ReportsAnalyticsDataModel.mockData;
    }
  }

  Future<String?> exportReport({
    required String reportType,
    required String format,
  }) async {
    try {
      final response = await _dioClient.instance.post(
        '/college/reports/export',
        data: {
          'type': reportType,
          'format': format,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as Map<String, dynamic>)['downloadUrl'] as String?;
      }
      return null;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }
}
