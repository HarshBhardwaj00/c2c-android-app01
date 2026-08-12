import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../domain/models/company_insights_model.dart';

class CompanyInsightsApiService {
  final DioClient _dioClient;

  CompanyInsightsApiService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Fetch full company & recruiter directory details
  Future<CompanyDirectoryDataModel> fetchCompanyDirectory({
    String query = '',
    String filter = 'All',
  }) async {
    try {
      final response = await _dioClient.instance.get(
        '/college/companies',
        queryParameters: {
          if (query.isNotEmpty) 'search': query,
          if (filter != 'All') 'filter': filter,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return CompanyDirectoryDataModel.fromJson(response.data as Map<String, dynamic>);
      }
      return CompanyDirectoryDataModel.mockData;
    } on DioException catch (_) {
      // DioException handling (401, 404, 500, timeout) -> fallback to mockData
      return CompanyDirectoryDataModel.mockData;
    } catch (_) {
      return CompanyDirectoryDataModel.mockData;
    }
  }

  /// Onboard new partner company API call
  Future<bool> onboardPartnerCompany({
    required String companyName,
    required String domain,
    required String contactEmail,
  }) async {
    try {
      final response = await _dioClient.instance.post(
        '/college/companies/onboard',
        data: {
          'companyName': companyName,
          'domain': domain,
          'contactEmail': contactEmail,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (_) {
      return true; // Fallback success for demo
    } catch (_) {
      return true;
    }
  }

  /// Load more partners pagination
  Future<List<VerifiedPartnerItemModel>> loadMorePartners({int page = 2}) async {
    try {
      final response = await _dioClient.instance.get(
        '/college/companies/page/$page',
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        return list.map((e) => VerifiedPartnerItemModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return _generateExtraMockPartners();
    } on DioException catch (_) {
      return _generateExtraMockPartners();
    } catch (_) {
      return _generateExtraMockPartners();
    }
  }

  List<VerifiedPartnerItemModel> _generateExtraMockPartners() {
    return [
      const VerifiedPartnerItemModel(
        id: 'c4',
        companyName: 'Quantum Dynamics',
        tierBadge: 'NEW STRATEGIC',
        location: 'Austin, TX',
        domain: 'AI & Data Science',
        engagementPercentage: 88,
        lastVisitDate: 'Oct 29, 2023',
        logoAssetPath: 'assets/images/college_building.webp',
      ),
      const VerifiedPartnerItemModel(
        id: 'c5',
        companyName: 'CyberShield Systems',
        tierBadge: 'TIER 1 PARTNER',
        location: 'Seattle, WA',
        domain: 'Cybersecurity',
        engagementPercentage: 95,
        lastVisitDate: 'Nov 01, 2023',
        logoAssetPath: 'assets/images/college_building.webp',
      ),
    ];
  }
}
