// Domain model for Screen 10: At-Risk Students (/college/students/at-risk)

class AtRiskStudentsOverviewModel {
  final int totalAtRiskCount;
  final int highRiskCount;
  final String highRiskGrowth;
  final int moderateRiskCount;
  final String moderateRiskGrowth;
  final int interventionRatePercentage;
  final List<AtRiskStudentItemModel> atRiskStudents;
  final AiInterventionPlanModel featuredInterventionPlan;
  final int activeMitigationStage; // 1 to 4

  const AtRiskStudentsOverviewModel({
    required this.totalAtRiskCount,
    required this.highRiskCount,
    required this.highRiskGrowth,
    required this.moderateRiskCount,
    required this.moderateRiskGrowth,
    required this.interventionRatePercentage,
    required this.atRiskStudents,
    required this.featuredInterventionPlan,
    required this.activeMitigationStage,
  });

  factory AtRiskStudentsOverviewModel.fromJson(Map<String, dynamic> json) {
    return AtRiskStudentsOverviewModel(
      totalAtRiskCount: (json['totalAtRiskCount'] as num?)?.toInt() ?? 42,
      highRiskCount: (json['highRiskCount'] as num?)?.toInt() ?? 12,
      highRiskGrowth: json['highRiskGrowth'] as String? ?? '+4',
      moderateRiskCount: (json['moderateRiskCount'] as num?)?.toInt() ?? 30,
      moderateRiskGrowth: json['moderateRiskGrowth'] as String? ?? '-2',
      interventionRatePercentage: (json['interventionRatePercentage'] as num?)?.toInt() ?? 68,
      atRiskStudents: json['atRiskStudents'] != null
          ? (json['atRiskStudents'] as List<dynamic>)
              .map((e) => AtRiskStudentItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : AtRiskStudentItemModel.defaultList,
      featuredInterventionPlan: json['featuredInterventionPlan'] != null
          ? AiInterventionPlanModel.fromJson(json['featuredInterventionPlan'] as Map<String, dynamic>)
          : AiInterventionPlanModel.defaultPlan,
      activeMitigationStage: (json['activeMitigationStage'] as num?)?.toInt() ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAtRiskCount': totalAtRiskCount,
      'highRiskCount': highRiskCount,
      'highRiskGrowth': highRiskGrowth,
      'moderateRiskCount': moderateRiskCount,
      'moderateRiskGrowth': moderateRiskGrowth,
      'interventionRatePercentage': interventionRatePercentage,
      'atRiskStudents': atRiskStudents.map((e) => e.toJson()).toList(),
      'featuredInterventionPlan': featuredInterventionPlan.toJson(),
      'activeMitigationStage': activeMitigationStage,
    };
  }

  static AtRiskStudentsOverviewModel get mockData => AtRiskStudentsOverviewModel(
        totalAtRiskCount: 42,
        highRiskCount: 12,
        highRiskGrowth: '+4',
        moderateRiskCount: 30,
        moderateRiskGrowth: '-2',
        interventionRatePercentage: 68,
        atRiskStudents: AtRiskStudentItemModel.defaultList,
        featuredInterventionPlan: AiInterventionPlanModel.defaultPlan,
        activeMitigationStage: 3,
      );
}

class AtRiskStudentItemModel {
  final String id;
  final String name;
  final String initials;
  final String departmentYearSubtext; // e.g. "CS • Year 4"
  final String riskLevel; // "HIGH RISK", "MODERATE"
  final String avatarBgType; // lavender, blue, amber

  const AtRiskStudentItemModel({
    required this.id,
    required this.name,
    required this.initials,
    required this.departmentYearSubtext,
    required this.riskLevel,
    required this.avatarBgType,
  });

  factory AtRiskStudentItemModel.fromJson(Map<String, dynamic> json) {
    return AtRiskStudentItemModel(
      id: json['id'] as String? ?? 's1',
      name: json['name'] as String? ?? 'Arjun Reddy',
      initials: json['initials'] as String? ?? 'AR',
      departmentYearSubtext: json['departmentYearSubtext'] as String? ?? 'CS • Year 4',
      riskLevel: json['riskLevel'] as String? ?? 'HIGH RISK',
      avatarBgType: json['avatarBgType'] as String? ?? 'lavender',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'initials': initials,
      'departmentYearSubtext': departmentYearSubtext,
      'riskLevel': riskLevel,
      'avatarBgType': avatarBgType,
    };
  }

  static List<AtRiskStudentItemModel> get defaultList => [
        const AtRiskStudentItemModel(
          id: 's1',
          name: 'Arjun Reddy',
          initials: 'AR',
          departmentYearSubtext: 'CS • Year 4',
          riskLevel: 'HIGH RISK',
          avatarBgType: 'lavender',
        ),
        const AtRiskStudentItemModel(
          id: 's2',
          name: 'Sneha Nair',
          initials: 'SN',
          departmentYearSubtext: 'IT • Year 4',
          riskLevel: 'HIGH RISK',
          avatarBgType: 'blue',
        ),
        const AtRiskStudentItemModel(
          id: 's3',
          name: 'Priyanka K.',
          initials: 'PK',
          departmentYearSubtext: 'ECE • Year 4',
          riskLevel: 'MODERATE',
          avatarBgType: 'amber',
        ),
      ];
}

class AiInterventionPlanModel {
  final String studentName;
  final String failurePredictionReason;

  const AiInterventionPlanModel({
    required this.studentName,
    required this.failurePredictionReason,
  });

  factory AiInterventionPlanModel.fromJson(Map<String, dynamic> json) {
    return AiInterventionPlanModel(
      studentName: json['studentName'] as String? ?? 'ARJUN',
      failurePredictionReason: json['failurePredictionReason'] as String? ??
          'Predicted failure in Technical Round. Lack of portfolio depth detected by pattern analysis.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'failurePredictionReason': failurePredictionReason,
    };
  }

  static const AiInterventionPlanModel defaultPlan = AiInterventionPlanModel(
    studentName: 'ARJUN',
    failurePredictionReason:
        'Predicted failure in Technical Round. Lack of portfolio depth detected by pattern analysis.',
  );
}
