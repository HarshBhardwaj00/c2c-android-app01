// Domain model for Screen 11: Placement Intelligence (/college/analytics/intelligence)

class PlacementIntelligenceOverviewModel {
  final String batchTitle;
  final String expectedPlacementPercentage;
  final String growthPercentage;
  final String confidenceIntervalText;
  final List<double> monthlyTrajectoryBars;
  final List<CompanySelectionItemModel> companySelections;
  final List<DemandSupplyPointModel> demandVsSupplyData;
  final List<SkillAlignmentItemModel> skillAlignments;
  final String aiInsightQuote;
  final int activeDrivesCount;
  final int registeredStudentsCount;
  final PrepSessionModel upcomingPrepSession;

  const PlacementIntelligenceOverviewModel({
    required this.batchTitle,
    required this.expectedPlacementPercentage,
    required this.growthPercentage,
    required this.confidenceIntervalText,
    required this.monthlyTrajectoryBars,
    required this.companySelections,
    required this.demandVsSupplyData,
    required this.skillAlignments,
    required this.aiInsightQuote,
    required this.activeDrivesCount,
    required this.registeredStudentsCount,
    required this.upcomingPrepSession,
  });

  factory PlacementIntelligenceOverviewModel.fromJson(Map<String, dynamic> json) {
    return PlacementIntelligenceOverviewModel(
      batchTitle: json['batchTitle'] as String? ?? 'Batch of 2024-25',
      expectedPlacementPercentage: json['expectedPlacementPercentage'] as String? ?? '87.4%',
      growthPercentage: json['growthPercentage'] as String? ?? '+4.2%',
      confidenceIntervalText: json['confidenceIntervalText'] as String? ??
          'Confidence Interval: 85.2% - 89.6%',
      monthlyTrajectoryBars: json['monthlyTrajectoryBars'] != null
          ? (json['monthlyTrajectoryBars'] as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList()
          : const [0.35, 0.40, 0.45, 0.65, 0.75, 0.88],
      companySelections: json['companySelections'] != null
          ? (json['companySelections'] as List<dynamic>)
              .map((e) => CompanySelectionItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : CompanySelectionItemModel.defaultList,
      demandVsSupplyData: json['demandVsSupplyData'] != null
          ? (json['demandVsSupplyData'] as List<dynamic>)
              .map((e) => DemandSupplyPointModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : DemandSupplyPointModel.defaultList,
      skillAlignments: json['skillAlignments'] != null
          ? (json['skillAlignments'] as List<dynamic>)
              .map((e) => SkillAlignmentItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : SkillAlignmentItemModel.defaultList,
      aiInsightQuote: json['aiInsightQuote'] as String? ??
          'Insight: The current batch is exceptionally strong in technical depth but requires a 20% boost in business logic for management roles.',
      activeDrivesCount: (json['activeDrivesCount'] as num?)?.toInt() ?? 24,
      registeredStudentsCount: (json['registeredStudentsCount'] as num?)?.toInt() ?? 1240,
      upcomingPrepSession: json['upcomingPrepSession'] != null
          ? PrepSessionModel.fromJson(json['upcomingPrepSession'] as Map<String, dynamic>)
          : PrepSessionModel.defaultSession,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchTitle': batchTitle,
      'expectedPlacementPercentage': expectedPlacementPercentage,
      'growthPercentage': growthPercentage,
      'confidenceIntervalText': confidenceIntervalText,
      'monthlyTrajectoryBars': monthlyTrajectoryBars,
      'companySelections': companySelections.map((e) => e.toJson()).toList(),
      'demandVsSupplyData': demandVsSupplyData.map((e) => e.toJson()).toList(),
      'skillAlignments': skillAlignments.map((e) => e.toJson()).toList(),
      'aiInsightQuote': aiInsightQuote,
      'activeDrivesCount': activeDrivesCount,
      'registeredStudentsCount': registeredStudentsCount,
      'upcomingPrepSession': upcomingPrepSession.toJson(),
    };
  }

  static PlacementIntelligenceOverviewModel get mockData => PlacementIntelligenceOverviewModel(
        batchTitle: 'Batch of 2024-25',
        expectedPlacementPercentage: '87.4%',
        growthPercentage: '+4.2%',
        confidenceIntervalText: 'Confidence Interval: 85.2% - 89.6%',
        monthlyTrajectoryBars: const [0.35, 0.40, 0.45, 0.65, 0.75, 0.88],
        companySelections: CompanySelectionItemModel.defaultList,
        demandVsSupplyData: DemandSupplyPointModel.defaultList,
        skillAlignments: SkillAlignmentItemModel.defaultList,
        aiInsightQuote:
            'Insight: The current batch is exceptionally strong in technical depth but requires a 20% boost in business logic for management roles.',
        activeDrivesCount: 24,
        registeredStudentsCount: 1240,
        upcomingPrepSession: PrepSessionModel.defaultSession,
      );
}

class CompanySelectionItemModel {
  final String companyName;
  final String estimatedOffersSubtext; // e.g. "142 Est. Offers"

  const CompanySelectionItemModel({
    required this.companyName,
    required this.estimatedOffersSubtext,
  });

  factory CompanySelectionItemModel.fromJson(Map<String, dynamic> json) {
    return CompanySelectionItemModel(
      companyName: json['companyName'] as String? ?? 'Global Tech Solutions',
      estimatedOffersSubtext: json['estimatedOffersSubtext'] as String? ?? '142 Est. Offers',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'estimatedOffersSubtext': estimatedOffersSubtext,
    };
  }

  static List<CompanySelectionItemModel> get defaultList => [
        const CompanySelectionItemModel(
          companyName: 'Global Tech Solutions',
          estimatedOffersSubtext: '142 Est. Offers',
        ),
        const CompanySelectionItemModel(
          companyName: 'FinNexus Bank',
          estimatedOffersSubtext: '88 Est. Offers',
        ),
        const CompanySelectionItemModel(
          companyName: 'Automotive AI',
          estimatedOffersSubtext: '54 Est. Offers',
        ),
        const CompanySelectionItemModel(
          companyName: 'HealthLink Inc',
          estimatedOffersSubtext: '42 Est. Offers',
        ),
      ];
}

class DemandSupplyPointModel {
  final String monthLabel; // e.g. "DEC 23", "JAN 24"
  final double demandVal;
  final double supplyVal;

  const DemandSupplyPointModel({
    required this.monthLabel,
    required this.demandVal,
    required this.supplyVal,
  });

  factory DemandSupplyPointModel.fromJson(Map<String, dynamic> json) {
    return DemandSupplyPointModel(
      monthLabel: json['monthLabel'] as String? ?? 'JAN 24',
      demandVal: (json['demandVal'] as num?)?.toDouble() ?? 0.85,
      supplyVal: (json['supplyVal'] as num?)?.toDouble() ?? 0.65,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthLabel': monthLabel,
      'demandVal': demandVal,
      'supplyVal': supplyVal,
    };
  }

  static List<DemandSupplyPointModel> get defaultList => [
        const DemandSupplyPointModel(monthLabel: 'DEC 23', demandVal: 0.55, supplyVal: 0.45),
        const DemandSupplyPointModel(monthLabel: 'JAN 24', demandVal: 0.88, supplyVal: 0.62),
        const DemandSupplyPointModel(monthLabel: 'FEB 24', demandVal: 0.70, supplyVal: 0.68),
        const DemandSupplyPointModel(monthLabel: 'MAR 24', demandVal: 0.78, supplyVal: 0.72),
        const DemandSupplyPointModel(monthLabel: 'APR 24', demandVal: 0.90, supplyVal: 0.82),
      ];
}

class SkillAlignmentItemModel {
  final String skillName;
  final int alignmentPercentage;

  const SkillAlignmentItemModel({
    required this.skillName,
    required this.alignmentPercentage,
  });

  factory SkillAlignmentItemModel.fromJson(Map<String, dynamic> json) {
    return SkillAlignmentItemModel(
      skillName: json['skillName'] as String? ?? 'Advanced Algorithms',
      alignmentPercentage: (json['alignmentPercentage'] as num?)?.toInt() ?? 82,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skillName': skillName,
      'alignmentPercentage': alignmentPercentage,
    };
  }

  static List<SkillAlignmentItemModel> get defaultList => [
        const SkillAlignmentItemModel(skillName: 'Advanced Algorithms', alignmentPercentage: 82),
        const SkillAlignmentItemModel(skillName: 'Machine Learning Basics', alignmentPercentage: 74),
        const SkillAlignmentItemModel(skillName: 'Product Strategy', alignmentPercentage: 49),
      ];
}

class PrepSessionModel {
  final String id;
  final String sessionTitle;
  final String scheduleTimeSubtext; // e.g. "Tomorrow, 10:00 AM • Auditorium A"

  const PrepSessionModel({
    required this.id,
    required this.sessionTitle,
    required this.scheduleTimeSubtext,
  });

  factory PrepSessionModel.fromJson(Map<String, dynamic> json) {
    return PrepSessionModel(
      id: json['id'] as String? ?? 'prep1',
      sessionTitle: json['sessionTitle'] as String? ?? 'Google Prep 101',
      scheduleTimeSubtext: json['scheduleTimeSubtext'] as String? ?? 'Tomorrow, 10:00 AM • Auditorium A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionTitle': sessionTitle,
      'scheduleTimeSubtext': scheduleTimeSubtext,
    };
  }

  static const PrepSessionModel defaultSession = PrepSessionModel(
    id: 'prep1',
    sessionTitle: 'Google Prep 101',
    scheduleTimeSubtext: 'Tomorrow, 10:00 AM • Auditorium A',
  );
}
