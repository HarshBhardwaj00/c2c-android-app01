/// Data models for Screen 5: Job Pipeline (/college/drives/:id/pipeline)
class JobPipelineOverviewModel {
  final String driveId;
  final int totalApplications;
  final String applicationsGrowth; // e.g. "+12%"
  final String conversionRate;     // e.g. "8.4%"
  final String avgConversionRate;  // e.g. "Avg: 6.5%"
  final int activeDrives;          // e.g. 42
  final int drivesClosingSoon;     // e.g. 5
  
  // Pipeline Stages Breakdown
  final int appliedCount;          // e.g. 1240
  final int shortlistedCount;      // e.g. 452
  final int interviewedCount;      // e.g. 184
  final int placedCount;           // e.g. 56

  // AI Matching Candidate
  final AiCandidateMatchModel topMatchCandidate;

  // Recent Job Performance List
  final List<JobPerformanceItemModel> recentJobPerformance;

  const JobPipelineOverviewModel({
    required this.driveId,
    required this.totalApplications,
    required this.applicationsGrowth,
    required this.conversionRate,
    required this.avgConversionRate,
    required this.activeDrives,
    required this.drivesClosingSoon,
    required this.appliedCount,
    required this.shortlistedCount,
    required this.interviewedCount,
    required this.placedCount,
    required this.topMatchCandidate,
    required this.recentJobPerformance,
  });

  factory JobPipelineOverviewModel.fromJson(Map<String, dynamic> json) {
    return JobPipelineOverviewModel(
      driveId: json['driveId'] as String? ?? 'd1',
      totalApplications: (json['totalApplications'] as num?)?.toInt() ?? 2842,
      applicationsGrowth: json['applicationsGrowth'] as String? ?? '+12% from last month',
      conversionRate: json['conversionRate'] as String? ?? '8.4%',
      avgConversionRate: json['avgConversionRate'] as String? ?? 'Avg: 6.5%',
      activeDrives: (json['activeDrives'] as num?)?.toInt() ?? 42,
      drivesClosingSoon: (json['drivesClosingSoon'] as num?)?.toInt() ?? 5,
      appliedCount: (json['appliedCount'] as num?)?.toInt() ?? 1240,
      shortlistedCount: (json['shortlistedCount'] as num?)?.toInt() ?? 452,
      interviewedCount: (json['interviewedCount'] as num?)?.toInt() ?? 184,
      placedCount: (json['placedCount'] as num?)?.toInt() ?? 56,
      topMatchCandidate: json['topMatchCandidate'] != null
          ? AiCandidateMatchModel.fromJson(json['topMatchCandidate'] as Map<String, dynamic>)
          : AiCandidateMatchModel.defaultMatch,
      recentJobPerformance: json['recentJobPerformance'] != null
          ? (json['recentJobPerformance'] as List<dynamic>)
              .map((e) => JobPerformanceItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : JobPerformanceItemModel.defaultList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driveId': driveId,
      'totalApplications': totalApplications,
      'applicationsGrowth': applicationsGrowth,
      'conversionRate': conversionRate,
      'avgConversionRate': avgConversionRate,
      'activeDrives': activeDrives,
      'drivesClosingSoon': drivesClosingSoon,
      'appliedCount': appliedCount,
      'shortlistedCount': shortlistedCount,
      'interviewedCount': interviewedCount,
      'placedCount': placedCount,
      'topMatchCandidate': topMatchCandidate.toJson(),
      'recentJobPerformance': recentJobPerformance.map((e) => e.toJson()).toList(),
    };
  }

  static JobPipelineOverviewModel get mockData => JobPipelineOverviewModel(
        driveId: 'd1',
        totalApplications: 2842,
        applicationsGrowth: '+12% from last month',
        conversionRate: '8.4%',
        avgConversionRate: 'Avg: 6.5%',
        activeDrives: 42,
        drivesClosingSoon: 5,
        appliedCount: 1240,
        shortlistedCount: 452,
        interviewedCount: 184,
        placedCount: 56,
        topMatchCandidate: AiCandidateMatchModel.defaultMatch,
        recentJobPerformance: JobPerformanceItemModel.defaultList,
      );
}

class AiCandidateMatchModel {
  final String candidateId;
  final String studentCode;
  final String name;
  final String roleTitle;
  final int matchPercentage;
  final List<String> skills;
  final String matchReasoning;
  final String avatarUrl;
  final bool isShortlisted;

  const AiCandidateMatchModel({
    required this.candidateId,
    required this.studentCode,
    required this.name,
    required this.roleTitle,
    required this.matchPercentage,
    required this.skills,
    required this.matchReasoning,
    required this.avatarUrl,
    this.isShortlisted = false,
  });

  factory AiCandidateMatchModel.fromJson(Map<String, dynamic> json) {
    return AiCandidateMatchModel(
      candidateId: json['candidateId'] as String? ?? 's1',
      studentCode: json['studentCode'] as String? ?? 'STU-2024-001',
      name: json['name'] as String? ?? 'Arjun Sharma',
      roleTitle: json['roleTitle'] as String? ?? 'Senior Backend Developer',
      matchPercentage: (json['matchPercentage'] as num?)?.toInt() ?? 98,
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['Python', 'AWS', 'Microservices'],
      matchReasoning: json['matchReasoning'] as String? ??
          'Strong match for distributed systems & cloud architecture requirements.',
      avatarUrl: json['avatarUrl'] as String? ?? 'assets/images/hero_student.webp',
      isShortlisted: json['isShortlisted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'candidateId': candidateId,
      'studentCode': studentCode,
      'name': name,
      'roleTitle': roleTitle,
      'matchPercentage': matchPercentage,
      'skills': skills,
      'matchReasoning': matchReasoning,
      'avatarUrl': avatarUrl,
      'isShortlisted': isShortlisted,
    };
  }

  AiCandidateMatchModel copyWith({bool? isShortlisted}) {
    return AiCandidateMatchModel(
      candidateId: candidateId,
      studentCode: studentCode,
      name: name,
      roleTitle: roleTitle,
      matchPercentage: matchPercentage,
      skills: skills,
      matchReasoning: matchReasoning,
      avatarUrl: avatarUrl,
      isShortlisted: isShortlisted ?? this.isShortlisted,
    );
  }

  static const AiCandidateMatchModel defaultMatch = AiCandidateMatchModel(
    candidateId: 's1',
    studentCode: 'STU-2024-001',
    name: 'Arjun Sharma',
    roleTitle: 'Senior Backend Developer',
    matchPercentage: 98,
    skills: ['Python', 'AWS', 'Microservices'],
    matchReasoning:
        '"Strong match for distributed systems & cloud architecture requirements."',
    avatarUrl: 'assets/images/hero_student.webp',
    isShortlisted: false,
  );
}

class JobPerformanceItemModel {
  final String driveId;
  final String companyId;
  final String roleTitle;
  final String jdCode;
  final String status; // "ACTIVE", "EXPIRING", "CLOSED"
  final String categoryIcon; // "code", "design", "cloud", "data"
  final int viewsCount;
  final int applicationsCount;

  const JobPerformanceItemModel({
    required this.driveId,
    required this.companyId,
    required this.roleTitle,
    required this.jdCode,
    required this.status,
    required this.categoryIcon,
    required this.viewsCount,
    required this.applicationsCount,
  });

  factory JobPerformanceItemModel.fromJson(Map<String, dynamic> json) {
    return JobPerformanceItemModel(
      driveId: json['driveId'] as String? ?? 'd1',
      companyId: json['companyId'] as String? ?? 'c1',
      roleTitle: json['roleTitle'] as String? ?? 'Senior Backend Developer',
      jdCode: json['jdCode'] as String? ?? 'JD-49201',
      status: json['status'] as String? ?? 'ACTIVE',
      categoryIcon: json['categoryIcon'] as String? ?? 'code',
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 2410,
      applicationsCount: (json['applicationsCount'] as num?)?.toInt() ?? 412,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driveId': driveId,
      'companyId': companyId,
      'roleTitle': roleTitle,
      'jdCode': jdCode,
      'status': status,
      'categoryIcon': categoryIcon,
      'viewsCount': viewsCount,
      'applicationsCount': applicationsCount,
    };
  }

  static List<JobPerformanceItemModel> get defaultList => [
        const JobPerformanceItemModel(
          driveId: 'd1',
          companyId: 'c1',
          roleTitle: 'Senior Backend Developer',
          jdCode: 'JD-49201',
          status: 'ACTIVE',
          categoryIcon: 'code',
          viewsCount: 2410,
          applicationsCount: 412,
        ),
        const JobPerformanceItemModel(
          driveId: 'd2',
          companyId: 'c2',
          roleTitle: 'Product Design Intern',
          jdCode: 'JD-49198',
          status: 'EXPIRING',
          categoryIcon: 'design',
          viewsCount: 1890,
          applicationsCount: 305,
        ),
      ];
}
