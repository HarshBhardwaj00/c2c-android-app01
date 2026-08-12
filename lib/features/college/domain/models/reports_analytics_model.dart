class ReportsAnalyticsDataModel {
  final AiExecutiveSummary aiSummary;
  final PlacementGrowthData placementGrowth;
  final List<RecruiterEngagementItem> recruiterEngagement;
  final List<DepartmentPackageItem> departmentPackages;
  final List<ScheduledReport> scheduledReports;

  const ReportsAnalyticsDataModel({
    required this.aiSummary,
    required this.placementGrowth,
    required this.recruiterEngagement,
    required this.departmentPackages,
    required this.scheduledReports,
  });

  factory ReportsAnalyticsDataModel.fromJson(Map<String, dynamic> json) {
    return ReportsAnalyticsDataModel(
      aiSummary: json['aiSummary'] != null
          ? AiExecutiveSummary.fromJson(json['aiSummary'] as Map<String, dynamic>)
          : AiExecutiveSummary.defaultData,
      placementGrowth: json['placementGrowth'] != null
          ? PlacementGrowthData.fromJson(json['placementGrowth'] as Map<String, dynamic>)
          : PlacementGrowthData.defaultData,
      recruiterEngagement: json['recruiterEngagement'] != null
          ? (json['recruiterEngagement'] as List<dynamic>)
              .map((e) => RecruiterEngagementItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : RecruiterEngagementItem.defaultList,
      departmentPackages: json['departmentPackages'] != null
          ? (json['departmentPackages'] as List<dynamic>)
              .map((e) => DepartmentPackageItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : DepartmentPackageItem.defaultList,
      scheduledReports: json['scheduledReports'] != null
          ? (json['scheduledReports'] as List<dynamic>)
              .map((e) => ScheduledReport.fromJson(e as Map<String, dynamic>))
              .toList()
          : ScheduledReport.defaultList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aiSummary': aiSummary.toJson(),
      'placementGrowth': placementGrowth.toJson(),
      'recruiterEngagement': recruiterEngagement.map((e) => e.toJson()).toList(),
      'departmentPackages': departmentPackages.map((e) => e.toJson()).toList(),
      'scheduledReports': scheduledReports.map((e) => e.toJson()).toList(),
    };
  }

  static ReportsAnalyticsDataModel get mockData => ReportsAnalyticsDataModel(
        aiSummary: AiExecutiveSummary.defaultData,
        placementGrowth: PlacementGrowthData.defaultData,
        recruiterEngagement: RecruiterEngagementItem.defaultList,
        departmentPackages: DepartmentPackageItem.defaultList,
        scheduledReports: ScheduledReport.defaultList,
      );
}

class AiExecutiveSummary {
  final String title;
  final String summary;
  final String actionLabel;

  const AiExecutiveSummary({
    required this.title,
    required this.summary,
    required this.actionLabel,
  });

  factory AiExecutiveSummary.fromJson(Map<String, dynamic> json) {
    return AiExecutiveSummary(
      title: json['title'] as String? ?? 'AI Executive Summary',
      summary: json['summary'] as String? ?? '',
      actionLabel: json['actionLabel'] as String? ?? 'Make it Action',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'summary': summary,
        'actionLabel': actionLabel,
      };

  static AiExecutiveSummary get defaultData => const AiExecutiveSummary(
        title: 'AI Executive Summary',
        summary:
            'Overall placement velocity has increased by 14.2%, CS skills engagement, while Product Management showed a 23% gap. Let\'s Make it Action. Bridge the BBA gap in Civil Engineering.',
        actionLabel: 'Make it Action',
      );
}

class PlacementGrowthData {
  final int totalPlaced;
  final String totalLabel;
  final String avgCtc;
  final String companiesLabel;
  final String companiesValue;
  final List<String> years;
  final List<MonthlyBarData> monthlyData;

  const PlacementGrowthData({
    required this.totalPlaced,
    required this.totalLabel,
    required this.avgCtc,
    required this.companiesLabel,
    required this.companiesValue,
    required this.years,
    required this.monthlyData,
  });

  factory PlacementGrowthData.fromJson(Map<String, dynamic> json) {
    return PlacementGrowthData(
      totalPlaced: (json['totalPlaced'] as num?)?.toInt() ?? 0,
      totalLabel: json['totalLabel'] as String? ?? '',
      avgCtc: json['avgCtc'] as String? ?? '',
      companiesLabel: json['companiesLabel'] as String? ?? '',
      companiesValue: json['companiesValue'] as String? ?? '',
      years: json['years'] != null
          ? (json['years'] as List<dynamic>).map((e) => e.toString()).toList()
          : [],
      monthlyData: json['monthlyData'] != null
          ? (json['monthlyData'] as List<dynamic>)
              .map((e) => MonthlyBarData.fromJson(e as Map<String, dynamic>))
              .toList()
          : MonthlyBarData.defaultList,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalPlaced': totalPlaced,
        'totalLabel': totalLabel,
        'avgCtc': avgCtc,
        'companiesLabel': companiesLabel,
        'companiesValue': companiesValue,
        'years': years,
        'monthlyData': monthlyData.map((e) => e.toJson()).toList(),
      };

  static PlacementGrowthData get defaultData => PlacementGrowthData(
        totalPlaced: 1428,
        totalLabel: 'Total Placed',
        avgCtc: '8.5 LPA',
        companiesLabel: 'Companies',
        companiesValue: 'FAANG+ Cluster',
        years: const ['2023', '2024'],
        monthlyData: MonthlyBarData.defaultList,
      );
}

class MonthlyBarData {
  final String month;
  final double value;
  final bool isActive;

  const MonthlyBarData({
    required this.month,
    required this.value,
    required this.isActive,
  });

  factory MonthlyBarData.fromJson(Map<String, dynamic> json) {
    return MonthlyBarData(
      month: json['month'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'value': value,
        'isActive': isActive,
      };

  static List<MonthlyBarData> get defaultList => const [
        MonthlyBarData(month: 'Jan', value: 65, isActive: false),
        MonthlyBarData(month: 'Feb', value: 45, isActive: false),
        MonthlyBarData(month: 'Mar', value: 80, isActive: false),
        MonthlyBarData(month: 'Apr', value: 55, isActive: false),
        MonthlyBarData(month: 'May', value: 90, isActive: false),
        MonthlyBarData(month: 'Jun', value: 70, isActive: false),
        MonthlyBarData(month: 'Jul', value: 85, isActive: false),
        MonthlyBarData(month: 'Aug', value: 95, isActive: true),
      ];
}

class RecruiterEngagementItem {
  final String label;
  final double percentage;

  const RecruiterEngagementItem({
    required this.label,
    required this.percentage,
  });

  factory RecruiterEngagementItem.fromJson(Map<String, dynamic> json) {
    return RecruiterEngagementItem(
      label: json['label'] as String? ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'percentage': percentage,
      };

  static List<RecruiterEngagementItem> get defaultList => const [
        RecruiterEngagementItem(label: 'Return Tier Companies', percentage: 88),
        RecruiterEngagementItem(label: 'High-Growth Startups', percentage: 76),
        RecruiterEngagementItem(label: 'Global Consulting Firms', percentage: 61),
      ];
}

class DepartmentPackageItem {
  final String department;
  final String package;
  final String? trend;
  final String iconType;

  const DepartmentPackageItem({
    required this.department,
    required this.package,
    this.trend,
    required this.iconType,
  });

  factory DepartmentPackageItem.fromJson(Map<String, dynamic> json) {
    return DepartmentPackageItem(
      department: json['department'] as String? ?? '',
      package: json['package'] as String? ?? '',
      trend: json['trend'] as String?,
      iconType: json['iconType'] as String? ?? 'code',
    );
  }

  Map<String, dynamic> toJson() => {
        'department': department,
        'package': package,
        'trend': trend,
        'iconType': iconType,
      };

  static List<DepartmentPackageItem> get defaultList => const [
        DepartmentPackageItem(department: 'Computer Science', package: '18.5 LPA', trend: '+12%', iconType: 'code'),
        DepartmentPackageItem(department: 'Electronics & Comm.', package: '14.2 LPA', trend: '+8%', iconType: 'cpu'),
        DepartmentPackageItem(department: 'Mechanical Engineering', package: '12.8 LPA', trend: null, iconType: 'settings'),
      ];
}

class ScheduledReport {
  final String id;
  final String fileName;
  final String date;

  const ScheduledReport({
    required this.id,
    required this.fileName,
    required this.date,
  });

  factory ScheduledReport.fromJson(Map<String, dynamic> json) {
    return ScheduledReport(
      id: json['id'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'date': date,
      };

  static List<ScheduledReport> get defaultList => const [
        ScheduledReport(id: 'r1', fileName: 'Monthly_AUG_23.pdf', date: 'Aug 2023'),
      ];
}
