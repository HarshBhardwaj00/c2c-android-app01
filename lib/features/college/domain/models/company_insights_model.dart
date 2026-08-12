// Domain model for Screen 6: Company & Recruiter Insights (/college/companies/:id)
// Updated according to Figma "Company Directory & Recruiter Ecosystem" design.

class CompanyDirectoryDataModel {
  final int totalPartnerCompanies;
  final String partnerGrowthYoY; // e.g. "+12% YoY"
  final double satisfactionRating; // e.g. 4.8
  final int totalRatingStars; // e.g. 5
  final int pendingDriveRequestsCount; // e.g. 4
  final List<VerifiedPartnerItemModel> partners;
  final PendingDriveRequestModel featuredPendingRequest;

  const CompanyDirectoryDataModel({
    required this.totalPartnerCompanies,
    required this.partnerGrowthYoY,
    required this.satisfactionRating,
    required this.totalRatingStars,
    required this.pendingDriveRequestsCount,
    required this.partners,
    required this.featuredPendingRequest,
  });

  factory CompanyDirectoryDataModel.fromJson(Map<String, dynamic> json) {
    return CompanyDirectoryDataModel(
      totalPartnerCompanies: (json['totalPartnerCompanies'] as num?)?.toInt() ?? 342,
      partnerGrowthYoY: json['partnerGrowthYoY'] as String? ?? '+12% YoY',
      satisfactionRating: (json['satisfactionRating'] as num?)?.toDouble() ?? 4.8,
      totalRatingStars: (json['totalRatingStars'] as num?)?.toInt() ?? 5,
      pendingDriveRequestsCount: (json['pendingDriveRequestsCount'] as num?)?.toInt() ?? 4,
      partners: json['partners'] != null
          ? (json['partners'] as List<dynamic>)
              .map((e) => VerifiedPartnerItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : VerifiedPartnerItemModel.defaultList,
      featuredPendingRequest: json['featuredPendingRequest'] != null
          ? PendingDriveRequestModel.fromJson(json['featuredPendingRequest'] as Map<String, dynamic>)
          : PendingDriveRequestModel.defaultRequest,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPartnerCompanies': totalPartnerCompanies,
      'partnerGrowthYoY': partnerGrowthYoY,
      'satisfactionRating': satisfactionRating,
      'totalRatingStars': totalRatingStars,
      'pendingDriveRequestsCount': pendingDriveRequestsCount,
      'partners': partners.map((e) => e.toJson()).toList(),
      'featuredPendingRequest': featuredPendingRequest.toJson(),
    };
  }

  static CompanyDirectoryDataModel get mockData => CompanyDirectoryDataModel(
        totalPartnerCompanies: 342,
        partnerGrowthYoY: '+12% YoY',
        satisfactionRating: 4.8,
        totalRatingStars: 5,
        pendingDriveRequestsCount: 4,
        partners: VerifiedPartnerItemModel.defaultList,
        featuredPendingRequest: PendingDriveRequestModel.defaultRequest,
      );
}

class VerifiedPartnerItemModel {
  final String id;
  final String companyName;
  final String tierBadge; // e.g. "TIER 1 PARTNER", "FORTUNE 500", "NEW STRATEGIC"
  final String location;  // e.g. "San Jose, CA"
  final String domain;    // e.g. "Software & Cloud"
  final int engagementPercentage; // e.g. 92
  final String lastVisitDate; // e.g. "Oct 12, 2023"
  final String logoAssetPath;

  const VerifiedPartnerItemModel({
    required this.id,
    required this.companyName,
    required this.tierBadge,
    required this.location,
    required this.domain,
    required this.engagementPercentage,
    required this.lastVisitDate,
    required this.logoAssetPath,
  });

  factory VerifiedPartnerItemModel.fromJson(Map<String, dynamic> json) {
    return VerifiedPartnerItemModel(
      id: json['id'] as String? ?? 'c1',
      companyName: json['companyName'] as String? ?? 'TechNova Solutions',
      tierBadge: json['tierBadge'] as String? ?? 'TIER 1 PARTNER',
      location: json['location'] as String? ?? 'San Jose, CA',
      domain: json['domain'] as String? ?? 'Software & Cloud',
      engagementPercentage: (json['engagementPercentage'] as num?)?.toInt() ?? 92,
      lastVisitDate: json['lastVisitDate'] as String? ?? 'Oct 12, 2023',
      logoAssetPath: json['logoAssetPath'] as String? ?? 'assets/images/college_building.webp',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'tierBadge': tierBadge,
      'location': location,
      'domain': domain,
      'engagementPercentage': engagementPercentage,
      'lastVisitDate': lastVisitDate,
      'logoAssetPath': logoAssetPath,
    };
  }

  static List<VerifiedPartnerItemModel> get defaultList => [
        const VerifiedPartnerItemModel(
          id: 'c1',
          companyName: 'TechNova Solutions',
          tierBadge: 'TIER 1 PARTNER',
          location: 'San Jose, CA',
          domain: 'Software & Cloud',
          engagementPercentage: 92,
          lastVisitDate: 'Oct 12, 2023',
          logoAssetPath: 'assets/images/college_building.webp',
        ),
        const VerifiedPartnerItemModel(
          id: 'c2',
          companyName: 'Apex Global Finance',
          tierBadge: 'FORTUNE 500',
          location: 'New York, NY',
          domain: 'Fintech',
          engagementPercentage: 78,
          lastVisitDate: 'Sep 28, 2023',
          logoAssetPath: 'assets/images/college_building.webp',
        ),
        const VerifiedPartnerItemModel(
          id: 'c3',
          companyName: 'BioStream Systems',
          tierBadge: 'NEW STRATEGIC',
          location: 'Boston, MA',
          domain: 'Biomedical',
          engagementPercentage: 45,
          lastVisitDate: 'Nov 05, 2023',
          logoAssetPath: 'assets/images/college_building.webp',
        ),
      ];
}

class PendingDriveRequestModel {
  final String id;
  final String companyName;
  final String driveType; // e.g. "Internship Drive • Summer 2024"
  final String priorityBadge; // e.g. "High Priority"
  final int totalPendingRequestsCount;

  const PendingDriveRequestModel({
    required this.id,
    required this.companyName,
    required this.driveType,
    required this.priorityBadge,
    required this.totalPendingRequestsCount,
  });

  factory PendingDriveRequestModel.fromJson(Map<String, dynamic> json) {
    return PendingDriveRequestModel(
      id: json['id'] as String? ?? 'p1',
      companyName: json['companyName'] as String? ?? 'Stellar Robotics',
      driveType: json['driveType'] as String? ?? 'Internship Drive • Summer 2024',
      priorityBadge: json['priorityBadge'] as String? ?? 'High Priority',
      totalPendingRequestsCount: (json['totalPendingRequestsCount'] as num?)?.toInt() ?? 12,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'driveType': driveType,
      'priorityBadge': priorityBadge,
      'totalPendingRequestsCount': totalPendingRequestsCount,
    };
  }

  static const PendingDriveRequestModel defaultRequest = PendingDriveRequestModel(
    id: 'p1',
    companyName: 'Stellar Robotics',
    driveType: 'Internship Drive • Summer 2024',
    priorityBadge: 'High Priority',
    totalPendingRequestsCount: 12,
  );
}
