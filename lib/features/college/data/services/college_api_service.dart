import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../domain/models/college_dashboard_model.dart';

class CollegeApiService {
  final DioClient _dioClient;

  CollegeApiService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  Future<CollegeDashboardModel> fetchDashboardData() async {
    try {
      final response = await _dioClient.instance.get('/college/dashboard');
      if (response.statusCode == 200 && response.data != null) {
        return CollegeDashboardModel.fromJson(response.data as Map<String, dynamic>);
      }
      return CollegeDashboardModel.mockData;
    } on DioException catch (_) {
      // Graceful fallback to rich mock data if server isn't running or endpoint fails
      return CollegeDashboardModel.mockData;
    } catch (_) {
      return CollegeDashboardModel.mockData;
    }
  }
}
