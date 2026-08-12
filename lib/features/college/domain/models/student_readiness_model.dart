// Domain model for Screen 9: Student Readiness Analytics (/college/analytics/readiness)

class StudentReadinessDataModel {
  final int avgReadinessPercentage;
  final String readinessGrowthYoY;
  final int eligibleStudentsCount;
  final int totalStudentsCount;
  final int highRiskStudentsCount;
  final List<DepartmentHeatmapRowModel> departmentHeatmap;
  final Map<String, double> radarMetrics;
  final String technicalDepthScore;
  final String softSkillsScore;
  final String tier1Probability;
  final String tier1Growth;
  final String tier2Probability;
  final String skillGapMainInsight;
  final List<SkillGapAlertItemModel> skillGapAlerts;
  final List<RecommendedLearningModuleModel> recommendedModules;

  const StudentReadinessDataModel({
    required this.avgReadinessPercentage,
    required this.readinessGrowthYoY,
    required this.eligibleStudentsCount,
    required this.totalStudentsCount,
    required this.highRiskStudentsCount,
    required this.departmentHeatmap,
    required this.radarMetrics,
    required this.technicalDepthScore,
    required this.softSkillsScore,
    required this.tier1Probability,
    required this.tier1Growth,
    required this.tier2Probability,
    required this.skillGapMainInsight,
    required this.skillGapAlerts,
    required this.recommendedModules,
  });

  factory StudentReadinessDataModel.fromJson(Map<String, dynamic> json) {
    return StudentReadinessDataModel(
      avgReadinessPercentage: (json['avgReadinessPercentage'] as num?)?.toInt() ?? 84,
      readinessGrowthYoY: json['readinessGrowthYoY'] as String? ?? '+4%',
      eligibleStudentsCount: (json['eligibleStudentsCount'] as num?)?.toInt() ?? 1240,
      totalStudentsCount: (json['totalStudentsCount'] as num?)?.toInt() ?? 1500,
      highRiskStudentsCount: (json['highRiskStudentsCount'] as num?)?.toInt() ?? 142,
      departmentHeatmap: json['departmentHeatmap'] != null
          ? (json['departmentHeatmap'] as List<dynamic>)
              .map((e) => DepartmentHeatmapRowModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : DepartmentHeatmapRowModel.defaultList,
      radarMetrics: json['radarMetrics'] != null
          ? (json['radarMetrics'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, (v as num).toDouble()),
            )
          : const {
              'Technical': 0.88,
              'Soft Skills': 0.92,
              'Aptitude': 0.80,
              'Domain': 0.85,
              'Projects': 0.78,
            },
      technicalDepthScore: json['technicalDepthScore'] as String? ?? '88/100',
      softSkillsScore: json['softSkillsScore'] as String? ?? '92/100',
      tier1Probability: json['tier1Probability'] as String? ?? '18%',
      tier1Growth: json['tier1Growth'] as String? ?? '+2.4% YoY',
      tier2Probability: json['tier2Probability'] as String? ?? '64%',
      skillGapMainInsight: json['skillGapMainInsight'] as String? ??
          'Our models identified a systemic gap in "Advanced System Design" missing in 43% of portfolios.',
      skillGapAlerts: json['skillGapAlerts'] != null
          ? (json['skillGapAlerts'] as List<dynamic>)
              .map((e) => SkillGapAlertItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : SkillGapAlertItemModel.defaultList,
      recommendedModules: json['recommendedModules'] != null
          ? (json['recommendedModules'] as List<dynamic>)
              .map((e) => RecommendedLearningModuleModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : RecommendedLearningModuleModel.defaultList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avgReadinessPercentage': avgReadinessPercentage,
      'readinessGrowthYoY': readinessGrowthYoY,
      'eligibleStudentsCount': eligibleStudentsCount,
      'totalStudentsCount': totalStudentsCount,
      'highRiskStudentsCount': highRiskStudentsCount,
      'departmentHeatmap': departmentHeatmap.map((e) => e.toJson()).toList(),
      'radarMetrics': radarMetrics,
      'technicalDepthScore': technicalDepthScore,
      'softSkillsScore': softSkillsScore,
      'tier1Probability': tier1Probability,
      'tier1Growth': tier1Growth,
      'tier2Probability': tier2Probability,
      'skillGapMainInsight': skillGapMainInsight,
      'skillGapAlerts': skillGapAlerts.map((e) => e.toJson()).toList(),
      'recommendedModules': recommendedModules.map((e) => e.toJson()).toList(),
    };
  }

  static StudentReadinessDataModel get mockData => StudentReadinessDataModel(
        avgReadinessPercentage: 84,
        readinessGrowthYoY: '+4%',
        eligibleStudentsCount: 1240,
        totalStudentsCount: 1500,
        highRiskStudentsCount: 142,
        departmentHeatmap: DepartmentHeatmapRowModel.defaultList,
        radarMetrics: const {
          'Technical': 0.88,
          'Soft Skills': 0.92,
          'Aptitude': 0.80,
          'Domain': 0.85,
          'Projects': 0.78,
        },
        technicalDepthScore: '88/100',
        softSkillsScore: '92/100',
        tier1Probability: '18%',
        tier1Growth: '+2.4% YoY',
        tier2Probability: '64%',
        skillGapMainInsight:
            'Our models identified a systemic gap in "Advanced System Design" missing in 43% of portfolios.',
        skillGapAlerts: SkillGapAlertItemModel.defaultList,
        recommendedModules: RecommendedLearningModuleModel.defaultList,
      );
}

class DepartmentHeatmapRowModel {
  final String departmentCode; // e.g. "CS Avg", "IT", "ECE"
  final int dsaScore;
  final int cloudScore;
  final int systemScore;
  final int quantScore;
  final int projScore;

  const DepartmentHeatmapRowModel({
    required this.departmentCode,
    required this.dsaScore,
    required this.cloudScore,
    required this.systemScore,
    required this.quantScore,
    required this.projScore,
  });

  factory DepartmentHeatmapRowModel.fromJson(Map<String, dynamic> json) {
    return DepartmentHeatmapRowModel(
      departmentCode: json['departmentCode'] as String? ?? 'CS Avg',
      dsaScore: (json['dsaScore'] as num?)?.toInt() ?? 94,
      cloudScore: (json['cloudScore'] as num?)?.toInt() ?? 88,
      systemScore: (json['systemScore'] as num?)?.toInt() ?? 72,
      quantScore: (json['quantScore'] as num?)?.toInt() ?? 91,
      projScore: (json['projScore'] as num?)?.toInt() ?? 96,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departmentCode': departmentCode,
      'dsaScore': dsaScore,
      'cloudScore': cloudScore,
      'systemScore': systemScore,
      'quantScore': quantScore,
      'projScore': projScore,
    };
  }

  static List<DepartmentHeatmapRowModel> get defaultList => [
        const DepartmentHeatmapRowModel(
          departmentCode: 'CS Avg',
          dsaScore: 94,
          cloudScore: 88,
          systemScore: 72,
          quantScore: 91,
          projScore: 96,
        ),
        const DepartmentHeatmapRowModel(
          departmentCode: 'IT',
          dsaScore: 89,
          cloudScore: 93,
          systemScore: 78,
          quantScore: 87,
          projScore: 85,
        ),
        const DepartmentHeatmapRowModel(
          departmentCode: 'ECE',
          dsaScore: 68,
          cloudScore: 54,
          systemScore: 87,
          quantScore: 76,
          projScore: 71,
        ),
      ];
}

class SkillGapAlertItemModel {
  final String severity; // "CRITICAL", "WARNING"
  final String message;

  const SkillGapAlertItemModel({
    required this.severity,
    required this.message,
  });

  factory SkillGapAlertItemModel.fromJson(Map<String, dynamic> json) {
    return SkillGapAlertItemModel(
      severity: json['severity'] as String? ?? 'CRITICAL',
      message: json['message'] as String? ??
          'Critical: Node.js security patterns missing in 45% portfolios.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'severity': severity,
      'message': message,
    };
  }

  static List<SkillGapAlertItemModel> get defaultList => [
        const SkillGapAlertItemModel(
          severity: 'CRITICAL',
          message: 'Critical: Node.js security patterns missing in 45% portfolios.',
        ),
        const SkillGapAlertItemModel(
          severity: 'WARNING',
          message: 'Warning: 12% drop in mock interview scores this month.',
        ),
      ];
}

class RecommendedLearningModuleModel {
  final String id;
  final String categoryTag; // e.g. "CS", "SOFT"
  final String badgeText; // e.g. "Auto-Assigned", "Exclusive Module"
  final String title;
  final String description;
  final List<String> avatarAssets;

  const RecommendedLearningModuleModel({
    required this.id,
    required this.categoryTag,
    required this.badgeText,
    required this.title,
    required this.description,
    required this.avatarAssets,
  });

  factory RecommendedLearningModuleModel.fromJson(Map<String, dynamic> json) {
    return RecommendedLearningModuleModel(
      id: json['id'] as String? ?? 'm1',
      categoryTag: json['categoryTag'] as String? ?? 'CS',
      badgeText: json['badgeText'] as String? ?? 'Auto-Assigned',
      title: json['title'] as String? ?? 'Architecting Scale: DSA Masterclass',
      description: json['description'] as String? ??
          'Focus on Distributed Systems and Optimizing Search Algorithms.',
      avatarAssets: (json['avatarAssets'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['assets/images/hero_student.webp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryTag': categoryTag,
      'badgeText': badgeText,
      'title': title,
      'description': description,
      'avatarAssets': avatarAssets,
    };
  }

  static List<RecommendedLearningModuleModel> get defaultList => [
        const RecommendedLearningModuleModel(
          id: 'm1',
          categoryTag: 'CS',
          badgeText: 'Auto-Assigned',
          title: 'Architecting Scale: DSA Masterclass',
          description: 'Focus on Distributed Systems and Optimizing Search Algorithms.',
          avatarAssets: ['assets/images/hero_student.webp'],
        ),
        const RecommendedLearningModuleModel(
          id: 'm2',
          categoryTag: 'SOFT',
          badgeText: 'Exclusive Module',
          title: 'Executive Communication',
          description: 'Mastering the "Dream Offer" interview and salary negotiation.',
          avatarAssets: ['assets/images/hero_student.webp'],
        ),
      ];
}
