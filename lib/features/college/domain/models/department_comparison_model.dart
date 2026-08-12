// Domain model for Screen 8: Department Comparison (/college/analytics/compare)

class DepartmentComparisonDataModel {
  final String aiInsightBanner;
  final String primaryDeptName;
  final String secondaryDeptName;
  final Map<String, double> primaryMetrics;
  final Map<String, double> secondaryMetrics;
  final MostImprovedDepartmentModel mostImprovedDept;
  final List<DepartmentRankingItemModel> departmentRankings;

  const DepartmentComparisonDataModel({
    required this.aiInsightBanner,
    required this.primaryDeptName,
    required this.secondaryDeptName,
    required this.primaryMetrics,
    required this.secondaryMetrics,
    required this.mostImprovedDept,
    required this.departmentRankings,
  });

  factory DepartmentComparisonDataModel.fromJson(Map<String, dynamic> json) {
    return DepartmentComparisonDataModel(
      aiInsightBanner: json['aiInsightBanner'] as String? ??
          'AI Insights: 2 departments showing rapid growth',
      primaryDeptName: json['primaryDeptName'] as String? ?? 'COMP SCIENCE',
      secondaryDeptName: json['secondaryDeptName'] as String? ?? 'MECHANICAL',
      primaryMetrics: json['primaryMetrics'] != null
          ? (json['primaryMetrics'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, (v as num).toDouble()),
            )
          : const {
              'PLACEMENT RATE': 0.88,
              'AVG SALARY': 0.85,
              'READINESS SCORE': 0.82,
              'INTERNSHIPS': 0.78,
              'SKILL GAP': 0.25,
            },
      secondaryMetrics: json['secondaryMetrics'] != null
          ? (json['secondaryMetrics'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, (v as num).toDouble()),
            )
          : const {
              'PLACEMENT RATE': 0.65,
              'AVG SALARY': 0.60,
              'READINESS SCORE': 0.68,
              'INTERNSHIPS': 0.58,
              'SKILL GAP': 0.45,
            },
      mostImprovedDept: json['mostImprovedDept'] != null
          ? MostImprovedDepartmentModel.fromJson(
              json['mostImprovedDept'] as Map<String, dynamic>)
          : MostImprovedDepartmentModel.defaultData,
      departmentRankings: json['departmentRankings'] != null
          ? (json['departmentRankings'] as List<dynamic>)
              .map((e) => DepartmentRankingItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : DepartmentRankingItemModel.defaultList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aiInsightBanner': aiInsightBanner,
      'primaryDeptName': primaryDeptName,
      'secondaryDeptName': secondaryDeptName,
      'primaryMetrics': primaryMetrics,
      'secondaryMetrics': secondaryMetrics,
      'mostImprovedDept': mostImprovedDept.toJson(),
      'departmentRankings': departmentRankings.map((e) => e.toJson()).toList(),
    };
  }

  static DepartmentComparisonDataModel get mockData => DepartmentComparisonDataModel(
        aiInsightBanner: 'AI Insights: 2 departments showing rapid growth',
        primaryDeptName: 'COMP SCIENCE',
        secondaryDeptName: 'MECHANICAL',
        primaryMetrics: const {
          'PLACEMENT RATE': 0.88,
          'AVG SALARY': 0.85,
          'READINESS SCORE': 0.82,
          'INTERNSHIPS': 0.78,
          'SKILL GAP': 0.25,
        },
        secondaryMetrics: const {
          'PLACEMENT RATE': 0.65,
          'AVG SALARY': 0.60,
          'READINESS SCORE': 0.68,
          'INTERNSHIPS': 0.58,
          'SKILL GAP': 0.45,
        },
        mostImprovedDept: MostImprovedDepartmentModel.defaultData,
        departmentRankings: DepartmentRankingItemModel.defaultList,
      );
}

class MostImprovedDepartmentModel {
  final String departmentName;
  final String growthRate; // e.g. "+22.4%"
  final String readinessScore; // e.g. "84.5%"
  final String aiReasoningQuote;

  const MostImprovedDepartmentModel({
    required this.departmentName,
    required this.growthRate,
    required this.readinessScore,
    required this.aiReasoningQuote,
  });

  factory MostImprovedDepartmentModel.fromJson(Map<String, dynamic> json) {
    return MostImprovedDepartmentModel(
      departmentName: json['departmentName'] as String? ?? 'Electrical Engineering',
      growthRate: json['growthRate'] as String? ?? '+22.4%',
      readinessScore: json['readinessScore'] as String? ?? '84.5%',
      aiReasoningQuote: json['aiReasoningQuote'] as String? ??
          'Significant increase in coding performance (+35%) and internship conversions. Improved engagement in Python and Systems Design modules observed in the last quarter.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departmentName': departmentName,
      'growthRate': growthRate,
      'readinessScore': readinessScore,
      'aiReasoningQuote': aiReasoningQuote,
    };
  }

  static const MostImprovedDepartmentModel defaultData = MostImprovedDepartmentModel(
    departmentName: 'Electrical Engineering',
    growthRate: '+22.4%',
    readinessScore: '84.5%',
    aiReasoningQuote:
        'Significant increase in coding performance (+35%) and internship conversions. Improved engagement in Python and Systems Design modules observed in the last quarter.',
  );
}

class DepartmentRankingItemModel {
  final int rank;
  final String departmentName;
  final String studentCountSubtext; // e.g. "420 Students"
  final String avgSalary; // e.g. "$85,200"
  final int engagementPercentage; // e.g. 92
  final String iconCategory; // laptop, cpu, zap

  const DepartmentRankingItemModel({
    required this.rank,
    required this.departmentName,
    required this.studentCountSubtext,
    required this.avgSalary,
    required this.engagementPercentage,
    required this.iconCategory,
  });

  factory DepartmentRankingItemModel.fromJson(Map<String, dynamic> json) {
    return DepartmentRankingItemModel(
      rank: (json['rank'] as num?)?.toInt() ?? 1,
      departmentName: json['departmentName'] as String? ?? 'Computer Science',
      studentCountSubtext: json['studentCountSubtext'] as String? ?? '420 Students',
      avgSalary: json['avgSalary'] as String? ?? '\$85,200',
      engagementPercentage: (json['engagementPercentage'] as num?)?.toInt() ?? 92,
      iconCategory: json['iconCategory'] as String? ?? 'laptop',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'departmentName': departmentName,
      'studentCountSubtext': studentCountSubtext,
      'avgSalary': avgSalary,
      'engagementPercentage': engagementPercentage,
      'iconCategory': iconCategory,
    };
  }

  static List<DepartmentRankingItemModel> get defaultList => [
        const DepartmentRankingItemModel(
          rank: 1,
          departmentName: 'Computer Science',
          studentCountSubtext: '420 Students',
          avgSalary: '\$85,200',
          engagementPercentage: 92,
          iconCategory: 'laptop',
        ),
        const DepartmentRankingItemModel(
          rank: 2,
          departmentName: 'Electronics & Comm.',
          studentCountSubtext: '310 Students',
          avgSalary: '\$72,000',
          engagementPercentage: 78,
          iconCategory: 'cpu',
        ),
        const DepartmentRankingItemModel(
          rank: 3,
          departmentName: 'Electrical Eng.',
          studentCountSubtext: '250 Students',
          avgSalary: '\$68,500',
          engagementPercentage: 74,
          iconCategory: 'zap',
        ),
      ];
}
