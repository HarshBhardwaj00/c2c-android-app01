class CollegeDashboardModel {
  final int totalStudents;
  final String studentGrowth;
  final int activeCandidates;
  final String candidateGrowth;
  final double placementPercentage;
  final int companiesVisiting;
  final int placedCount;
  final int targetCount;
  final String targetReachedPercentage;
  final List<CampusDriveModel> upcomingDrives;
  final List<RecentActivityModel> recentActivities;

  const CollegeDashboardModel({
    required this.totalStudents,
    required this.studentGrowth,
    required this.activeCandidates,
    required this.candidateGrowth,
    required this.placementPercentage,
    required this.companiesVisiting,
    required this.placedCount,
    required this.targetCount,
    required this.targetReachedPercentage,
    required this.upcomingDrives,
    required this.recentActivities,
  });

  factory CollegeDashboardModel.fromJson(Map<String, dynamic> json) {
    return CollegeDashboardModel(
      totalStudents: json['totalStudents'] ?? 2480,
      studentGrowth: json['studentGrowth'] ?? '+12.4%',
      activeCandidates: json['activeCandidates'] ?? 1822,
      candidateGrowth: json['candidateGrowth'] ?? '+5.8%',
      placementPercentage: (json['placementPercentage'] as num?)?.toDouble() ?? 84.2,
      companiesVisiting: json['companiesVisiting'] ?? 142,
      placedCount: json['placedCount'] ?? 1934,
      targetCount: json['targetCount'] ?? 2480,
      targetReachedPercentage: json['targetReachedPercentage'] ?? '78.0%',
      upcomingDrives: (json['upcomingDrives'] as List<dynamic>?)
              ?.map((e) => CampusDriveModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          CampusDriveModel.defaultDrives,
      recentActivities: (json['recentActivities'] as List<dynamic>?)
              ?.map((e) => RecentActivityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          RecentActivityModel.defaultActivities,
    );
  }

  static const CollegeDashboardModel mockData = CollegeDashboardModel(
    totalStudents: 2480,
    studentGrowth: '+12.4%',
    activeCandidates: 1822,
    candidateGrowth: '+5.8%',
    placementPercentage: 84.2,
    companiesVisiting: 142,
    placedCount: 1934,
    targetCount: 2480,
    targetReachedPercentage: '78.0%',
    upcomingDrives: CampusDriveModel.defaultDrives,
    recentActivities: RecentActivityModel.defaultActivities,
  );
}

class CampusDriveModel {
  final String id;
  final String companyName;
  final String logoUrl;
  final String date;
  final String role;
  final String ctc;

  const CampusDriveModel({
    required this.id,
    required this.companyName,
    required this.logoUrl,
    required this.date,
    required this.role,
    required this.ctc,
  });

  factory CampusDriveModel.fromJson(Map<String, dynamic> json) {
    return CampusDriveModel(
      id: json['id']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      ctc: json['ctc']?.toString() ?? '',
    );
  }

  static const List<CampusDriveModel> defaultDrives = [
    CampusDriveModel(
      id: 'd1',
      companyName: 'Wipro Tech',
      logoUrl: 'https://logo.clearbit.com/wipro.com',
      date: 'Mar 15, 2024',
      role: 'Full Stack Developer',
      ctc: '8.5 LPA',
    ),
    CampusDriveModel(
      id: 'd2',
      companyName: 'Aether Electronics',
      logoUrl: 'https://logo.clearbit.com/aether.com',
      date: 'Mar 19, 2024',
      role: 'Product Analyst',
      ctc: '12.0 LPA',
    ),
    CampusDriveModel(
      id: 'd3',
      companyName: 'Nexus Finance',
      logoUrl: 'https://logo.clearbit.com/nexus.com',
      date: 'Mar 25, 2024',
      role: 'Risk Auditor',
      ctc: '9.2 LPA',
    ),
  ];
}

class RecentActivityModel {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final String type;

  const RecentActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      type: json['type']?.toString() ?? 'info',
    );
  }

  static const List<RecentActivityModel> defaultActivities = [
    RecentActivityModel(
      id: 'a1',
      title: 'Shortlisting Complete',
      description: '45 students shortlisted for Google STEP Interview Round.',
      timestamp: '2 hours ago',
      type: 'success',
    ),
    RecentActivityModel(
      id: 'a2',
      title: 'Assessment Published',
      description: 'Data Structures Mock Assessment released for CS 4th year.',
      timestamp: '5 hours ago',
      type: 'info',
    ),
    RecentActivityModel(
      id: 'a3',
      title: 'Drive Updated',
      description: 'Microsoft updated JD for Security Engineer role.',
      timestamp: 'Yesterday',
      type: 'update',
    ),
    RecentActivityModel(
      id: 'a4',
      title: 'New Offer Received',
      description: 'Aether Electronics released 3 offer letters for Product Analyst role.',
      timestamp: 'Yesterday',
      type: 'offer',
    ),
  ];
}
