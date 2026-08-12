import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../domain/models/communication_hub_model.dart';

class CommunicationHubApiService {
  final DioClient _dioClient;

  CommunicationHubApiService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<CommunicationHubDataModel> fetchCommunicationData({
    String? tab,
    String? searchQuery,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (tab != null) queryParams['tab'] = tab;
      if (searchQuery != null) queryParams['search'] = searchQuery;

      final response = await _dioClient.instance.get(
        '/college/operations/communication',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return CommunicationHubDataModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return CommunicationHubDataModel.mockData;
    } on DioException catch (_) {
      return CommunicationHubDataModel.mockData;
    } catch (_) {
      return CommunicationHubDataModel.mockData;
    }
  }

  Future<bool> createBroadcast({
    required String title,
    required String content,
    required List<String> recipientIds,
  }) async {
    try {
      final response = await _dioClient.instance.post(
        '/college/operations/communication/broadcast',
        data: {
          'title': title,
          'content': content,
          'recipients': recipientIds,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
