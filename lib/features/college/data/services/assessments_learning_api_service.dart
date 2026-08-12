import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../domain/models/assessments_learning_model.dart';

class AssessmentsLearningApiService {
  final DioClient _dioClient;

  AssessmentsLearningApiService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<AssessmentsLearningDataModel> fetchAssessmentsData({
    String? category,
    String? searchQuery,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (searchQuery != null) queryParams['search'] = searchQuery;

      final response = await _dioClient.instance.get(
        '/college/analytics/assessments',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return AssessmentsLearningDataModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return AssessmentsLearningDataModel.mockData;
    } on DioException catch (_) {
      return AssessmentsLearningDataModel.mockData;
    } catch (_) {
      return AssessmentsLearningDataModel.mockData;
    }
  }
}
