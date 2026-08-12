class AssessmentsLearningDataModel {
  final double avgPassRate;
  final double avgAssessmentScore;
  final String passRateTrend;
  final String scoreTrend;
  final String aiInsightTitle;
  final String aiInsightDescription;
  final String aiInsightBadge;
  final List<AssessmentCategoryTab> categories;
  final List<AssessmentLibraryItem> libraryItems;
  final List<ReadinessGrowthDataPoint> readinessGrowth;
  final List<LiveActivityItem> liveActivities;

  const AssessmentsLearningDataModel({
    required this.avgPassRate,
    required this.avgAssessmentScore,
    required this.passRateTrend,
    required this.scoreTrend,
    required this.aiInsightTitle,
    required this.aiInsightDescription,
    required this.aiInsightBadge,
    required this.categories,
    required this.libraryItems,
    required this.readinessGrowth,
    required this.liveActivities,
  });

  factory AssessmentsLearningDataModel.fromJson(Map<String, dynamic> json) {
    return AssessmentsLearningDataModel(
      avgPassRate: (json['avgPassRate'] as num?)?.toDouble() ?? 84.2,
      avgAssessmentScore: (json['avgAssessmentScore'] as num?)?.toDouble() ?? 68.5,
      passRateTrend: json['passRateTrend'] as String? ?? '+2.1% vs last quarter',
      scoreTrend: json['scoreTrend'] as String? ?? '-1.3% vs last quarter',
      aiInsightTitle: json['aiInsightTitle'] as String? ?? 'Platinum',
      aiInsightDescription: json['aiInsightDescription'] as String? ??
          'Top 10% of assessment providers globally. Great quality benchmarks!',
      aiInsightBadge: json['aiInsightBadge'] as String? ?? 'Certified Assessment Partner',
      categories: json['categories'] != null
          ? (json['categories'] as List<dynamic>)
              .map((e) => AssessmentCategoryTab.fromJson(e as Map<String, dynamic>))
              .toList()
          : AssessmentCategoryTab.defaultList,
      libraryItems: json['libraryItems'] != null
          ? (json['libraryItems'] as List<dynamic>)
              .map((e) => AssessmentLibraryItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : AssessmentLibraryItem.defaultList,
      readinessGrowth: json['readinessGrowth'] != null
          ? (json['readinessGrowth'] as List<dynamic>)
              .map((e) => ReadinessGrowthDataPoint.fromJson(e as Map<String, dynamic>))
              .toList()
          : ReadinessGrowthDataPoint.defaultList,
      liveActivities: json['liveActivities'] != null
          ? (json['liveActivities'] as List<dynamic>)
              .map((e) => LiveActivityItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : LiveActivityItem.defaultList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avgPassRate': avgPassRate,
      'avgAssessmentScore': avgAssessmentScore,
      'passRateTrend': passRateTrend,
      'scoreTrend': scoreTrend,
      'aiInsightTitle': aiInsightTitle,
      'aiInsightDescription': aiInsightDescription,
      'aiInsightBadge': aiInsightBadge,
      'categories': categories.map((e) => e.toJson()).toList(),
      'libraryItems': libraryItems.map((e) => e.toJson()).toList(),
      'readinessGrowth': readinessGrowth.map((e) => e.toJson()).toList(),
      'liveActivities': liveActivities.map((e) => e.toJson()).toList(),
    };
  }

  static AssessmentsLearningDataModel get mockData => AssessmentsLearningDataModel(
        avgPassRate: 84.2,
        avgAssessmentScore: 68.5,
        passRateTrend: '+2.1% vs last quarter',
        scoreTrend: '-1.3% vs last quarter',
        aiInsightTitle: 'Platinum',
        aiInsightDescription:
            'Top 10% of assessment providers globally. Great quality benchmarks!',
        aiInsightBadge: 'Certified Assessment Partner',
        categories: AssessmentCategoryTab.defaultList,
        libraryItems: AssessmentLibraryItem.defaultList,
        readinessGrowth: ReadinessGrowthDataPoint.defaultList,
        liveActivities: LiveActivityItem.defaultList,
      );
}

class AssessmentCategoryTab {
  final String id;
  final String label;
  final String iconType;

  const AssessmentCategoryTab({
    required this.id,
    required this.label,
    required this.iconType,
  });

  factory AssessmentCategoryTab.fromJson(Map<String, dynamic> json) {
    return AssessmentCategoryTab(
      id: json['id'] as String? ?? 'courses',
      label: json['label'] as String? ?? 'Courses',
      iconType: json['iconType'] as String? ?? 'book',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'iconType': iconType,
      };

  static List<AssessmentCategoryTab> get defaultList => const [
        AssessmentCategoryTab(id: 'courses', label: 'Courses', iconType: 'book'),
        AssessmentCategoryTab(id: 'labs', label: 'Labs', iconType: 'flask'),
        AssessmentCategoryTab(id: 'coding', label: 'Coding', iconType: 'code'),
      ];
}

class AssessmentLibraryItem {
  final String id;
  final String title;
  final String subtitle;
  final double score;
  final String badge;
  final String badgeColor;

  const AssessmentLibraryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.score,
    required this.badge,
    required this.badgeColor,
  });

  factory AssessmentLibraryItem.fromJson(Map<String, dynamic> json) {
    return AssessmentLibraryItem(
      id: json['id'] as String? ?? 'a1',
      title: json['title'] as String? ?? 'Assessment',
      subtitle: json['subtitle'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      badge: json['badge'] as String? ?? '',
      badgeColor: json['badgeColor'] as String? ?? 'primary',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'score': score,
        'badge': badge,
        'badgeColor': badgeColor,
      };

  static List<AssessmentLibraryItem> get defaultList => const [
        AssessmentLibraryItem(
          id: 'a1',
          title: 'Logical Reasoning',
          subtitle: '12,900',
          score: 12900,
          badge: '',
          badgeColor: 'primary',
        ),
        AssessmentLibraryItem(
          id: 'a2',
          title: 'Communication Skills',
          subtitle: '8,500',
          score: 8500,
          badge: '',
          badgeColor: 'primary',
        ),
      ];
}

class ReadinessGrowthDataPoint {
  final String label;
  final double value;

  const ReadinessGrowthDataPoint({
    required this.label,
    required this.value,
  });

  factory ReadinessGrowthDataPoint.fromJson(Map<String, dynamic> json) {
    return ReadinessGrowthDataPoint(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
      };

  static List<ReadinessGrowthDataPoint> get defaultList => const [
        ReadinessGrowthDataPoint(label: 'Jan', value: 55),
        ReadinessGrowthDataPoint(label: 'Feb', value: 62),
        ReadinessGrowthDataPoint(label: 'Mar', value: 58),
        ReadinessGrowthDataPoint(label: 'Apr', value: 71),
        ReadinessGrowthDataPoint(label: 'May', value: 68),
        ReadinessGrowthDataPoint(label: 'Jun', value: 75),
        ReadinessGrowthDataPoint(label: 'Jul', value: 80),
      ];
}

class LiveActivityItem {
  final String id;
  final String title;
  final String iconType;

  const LiveActivityItem({
    required this.id,
    required this.title,
    required this.iconType,
  });

  factory LiveActivityItem.fromJson(Map<String, dynamic> json) {
    return LiveActivityItem(
      id: json['id'] as String? ?? 'l1',
      title: json['title'] as String? ?? '',
      iconType: json['iconType'] as String? ?? 'check',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'iconType': iconType,
      };

  static List<LiveActivityItem> get defaultList => const [
        LiveActivityItem(id: 'l1', title: 'Batch D/E: A+ Exam Finished', iconType: 'check'),
        LiveActivityItem(id: 'l2', title: 'AI Student profile: Pattern Lab', iconType: 'sparkles'),
        LiveActivityItem(id: 'l3', title: 'SkillLink: Mock Interview Session', iconType: 'user'),
      ];
}
