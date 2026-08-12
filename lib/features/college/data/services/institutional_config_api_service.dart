import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../domain/models/institutional_config_model.dart';

class InstitutionalConfigApiService {
  final DioClient _dioClient;

  InstitutionalConfigApiService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<InstitutionalConfigDataModel> fetchConfigData() async {
    try {
      final response = await _dioClient.instance.get(
        '/college/operations/config',
      );

      if (response.statusCode == 200 && response.data != null) {
        return InstitutionalConfigDataModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return InstitutionalConfigDataModel.mockData;
    } on DioException catch (_) {
      return InstitutionalConfigDataModel.mockData;
    } catch (_) {
      return InstitutionalConfigDataModel.mockData;
    }
  }

  Future<bool> updateBranding({
    required String displayName,
    required String brandColor,
  }) async {
    try {
      final response = await _dioClient.instance.put(
        '/college/operations/config/branding',
        data: {
          'displayName': displayName,
          'brandColor': brandColor,
        },
      );
      return response.statusCode == 200;
    } on DioException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateSecurity({
    required bool twoFactorEnabled,
    required bool externalApiEnabled,
  }) async {
    try {
      final response = await _dioClient.instance.put(
        '/college/operations/config/security',
        data: {
          'twoFactorEnabled': twoFactorEnabled,
          'externalApiEnabled': externalApiEnabled,
        },
      );
      return response.statusCode == 200;
    } on DioException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
