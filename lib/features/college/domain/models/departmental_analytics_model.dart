// Domain model for Screen 7: Departmental Analytics (/college/analytics/department)

class DepartmentalAnalyticsDataModel {
  final int totalStudents;
  final String studentsGrowthYoY;
  final double placementRate;
  final String topDepartment;
  final double avgScore;
  final List<String> departmentSpread;
  final Map<String, double> radarMetrics; // Academic, Skills, Placement, Ethics, Internship
  final List<BatchProgressTimelineItemModel> batchProgressTimeline;
  final List<DepartmentAcademicPerformanceItemModel> academicDepartments;

  const DepartmentalAnalyticsDataModel({
    required this.totalStudents,
    required this.studentsGrowthYoY,
    required this.placementRate,
    required this.topDepartment,
    required this.avgScore,
    required this.departmentSpread,
    required this.radarMetrics,
    required this.batchProgressTimeline,
    required this.academicDepartments,
  });

  factory DepartmentalAnalyticsDataModel.fromJson(Map<String, dynamic> json) {
    return DepartmentalAnalyticsDataModel(
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 3240,
      studentsGrowthYoY: json['studentsGrowthYoY'] as String? ?? '+12% vs LY',
      placementRate: (json['placementRate'] as num?)?.toDouble() ?? 78.4,
      topDepartment: json['topDepartment'] as String? ?? 'CS',
      avgScore: (json['avgScore'] as num?)?.toDouble() ?? 8.4,
      departmentSpread: (json['departmentSpread'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['CS', 'IT', 'MECH', 'ECE', 'OTHER'],
      radarMetrics: json['radarMetrics'] != null
          ? (json['radarMetrics'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            )
          : const {
              'ACADEMIC': 0.88,
              'SKILLS': 0.82,
              'PLACEMENT': 0.78,
              'ETHICS': 0.75,
              'INTERNSHIP': 0.72,
            },
      batchProgressTimeline: json['batchProgressTimeline'] != null
          ? (json['batchProgressTimeline'] as List<dynamic>)
              .map((e) => BatchProgressTimelineItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : BatchProgressTimelineItemModel.defaultList,
      academicDepartments: json['academicDepartments'] != null
          ? (json['academicDepartments'] as List<dynamic>)
              .map((e) => DepartmentAcademicPerformanceItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : DepartmentAcademicPerformanceItemModel.defaultList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'studentsGrowthYoY': studentsGrowthYoY,
      'placementRate': placementRate,
      'topDepartment': topDepartment,
      'avgScore': avgScore,
      'departmentSpread': departmentSpread,
      'radarMetrics': radarMetrics,
      'batchProgressTimeline': batchProgressTimeline.map((e) => e.toJson()).toList(),
      'academicDepartments': academicDepartments.map((e) => e.toJson()).toList(),
    };
  }

  static DepartmentalAnalyticsDataModel get mockData => DepartmentalAnalyticsDataModel(
        totalStudents: 3240,
        studentsGrowthYoY: '+12% vs LY',
        placementRate: 78.4,
        topDepartment: 'CS',
        avgScore: 8.4,
        departmentSpread: ['CS', 'IT', 'MECH', 'ECE', 'OTHER'],
        radarMetrics: const {
          'ACADEMIC': 0.88,
          'SKILLS': 0.82,
          'PLACEMENT': 0.78,
          'ETHICS': 0.75,
          'INTERNSHIP': 0.72,
        },
        batchProgressTimeline: BatchProgressTimelineItemModel.defaultList,
        academicDepartments: DepartmentAcademicPerformanceItemModel.defaultList,
      );
}

class BatchProgressTimelineItemModel {
  final String stageName;
  final String statusBadge; // COMPLETED, IN PROGRESS, UPCOMING
  final String description;
  final double progressValue; // 0.0 to 1.0
  final String iconType; // clipboard, code, rocket

  const BatchProgressTimelineItemModel({
    required this.stageName,
    required this.statusBadge,
    required this.description,
    required this.progressValue,
    required this.iconType,
  });

  factory BatchProgressTimelineItemModel.fromJson(Map<String, dynamic> json) {
    return BatchProgressTimelineItemModel(
      stageName: json['stageName'] as String? ?? 'Assessment Phase',
      statusBadge: json['statusBadge'] as String? ?? 'COMPLETED',
      description: json['description'] as String? ??
          '12,400 aptitude tests evaluated across 4 departments.',
      progressValue: (json['progressValue'] as num?)?.toDouble() ?? 1.0,
      iconType: json['iconType'] as String? ?? 'clipboard',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageName': stageName,
      'statusBadge': statusBadge,
      'description': description,
      'progressValue': progressValue,
      'iconType': iconType,
    };
  }

  static List<BatchProgressTimelineItemModel> get defaultList => [
        const BatchProgressTimelineItemModel(
          stageName: 'Assessment Phase',
          statusBadge: 'COMPLETED',
          description: '12,400 aptitude tests evaluated across 4 departments.',
          progressValue: 1.0,
          iconType: 'clipboard',
        ),
        const BatchProgressTimelineItemModel(
          stageName: 'Skill Bootcamps',
          statusBadge: 'IN PROGRESS',
          description: 'Intensive technical and communication training (Batch A-F).',
          progressValue: 0.65,
          iconType: 'code',
        ),
        const BatchProgressTimelineItemModel(
          stageName: 'Placement Drives',
          statusBadge: 'UPCOMING',
          description: 'Commencing Oct 15th with Tier-1 partners.',
          progressValue: 0.0,
          iconType: 'rocket',
        ),
      ];
}

class DepartmentAcademicPerformanceItemModel {
  final String departmentId;
  final String departmentName;
  final String subtextBatches;
  final int enrolledCount;
  final double avgCgpa;
  final String cgpaTrend; // e.g. "+0.4", "-0.2", "0.0"
  final double progressValue; // 0.0 to 1.0
  final String iconCategory; // code, network, gear, electronics

  const DepartmentAcademicPerformanceItemModel({
    required this.departmentId,
    required this.departmentName,
    required this.subtextBatches,
    required this.enrolledCount,
    required this.avgCgpa,
    required this.cgpaTrend,
    required this.progressValue,
    required this.iconCategory,
  });

  factory DepartmentAcademicPerformanceItemModel.fromJson(Map<String, dynamic> json) {
    return DepartmentAcademicPerformanceItemModel(
      departmentId: json['departmentId'] as String? ?? 'cs',
      departmentName: json['departmentName'] as String? ?? 'Computer Science',
      subtextBatches: json['subtextBatches'] as String? ?? '12 Batches',
      enrolledCount: (json['enrolledCount'] as num?)?.toInt() ?? 940,
      avgCgpa: (json['avgCgpa'] as num?)?.toDouble() ?? 8.32,
      cgpaTrend: json['cgpaTrend'] as String? ?? '+0.4',
      progressValue: (json['progressValue'] as num?)?.toDouble() ?? 0.85,
      iconCategory: json['iconCategory'] as String? ?? 'code',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departmentId': departmentId,
      'departmentName': departmentName,
      'subtextBatches': subtextBatches,
      'enrolledCount': enrolledCount,
      'avgCgpa': avgCgpa,
      'cgpaTrend': cgpaTrend,
      'progressValue': progressValue,
      'iconCategory': iconCategory,
    };
  }

  static List<DepartmentAcademicPerformanceItemModel> get defaultList => [
        const DepartmentAcademicPerformanceItemModel(
          departmentId: 'cs',
          departmentName: 'Computer Science',
          subtextBatches: '12 Batches',
          enrolledCount: 940,
          avgCgpa: 8.32,
          cgpaTrend: '+0.4',
          progressValue: 0.88,
          iconCategory: 'code',
        ),
        const DepartmentAcademicPerformanceItemModel(
          departmentId: 'it',
          departmentName: 'Information Tech',
          subtextBatches: '8 Batches',
          enrolledCount: 620,
          avgCgpa: 8.15,
          cgpaTrend: '+0.1',
          progressValue: 0.82,
          iconCategory: 'network',
        ),
        const DepartmentAcademicPerformanceItemModel(
          departmentId: 'mech',
          departmentName: 'Mechanical Eng.',
          subtextBatches: '10 Batches',
          enrolledCount: 580,
          avgCgpa: 7.65,
          cgpaTrend: '-0.2',
          progressValue: 0.68,
          iconCategory: 'gear',
        ),
      ];
}
