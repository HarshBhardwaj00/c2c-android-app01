class CollegeDashboardModel {
  final String collegeName;
  final String university;
  final String email;
  final int totalStudents;
  final String studentGrowth;
  final int activeCandidates;
  final String candidateGrowth;
  final double placementPercentage;
  final int totalProjects;
  final int totalApplications;
  final int upcomingInterviews;
  final int broadcastsSent;
  final int placedCount;
  final int targetCount;
  final String targetReachedPercentage;
  final List<CampusDriveModel> upcomingDrives;
  final List<RecentActivityModel> recentActivities;
  final List<ScheduleEventModel> scheduleEvents;

  const CollegeDashboardModel({
    this.collegeName = 'MIT Academy of Engineering',
    this.university = 'State Technical University',
    this.email = 'admin@college.edu',
    required this.totalStudents,
    required this.studentGrowth,
    required this.activeCandidates,
    required this.candidateGrowth,
    required this.placementPercentage,
    this.totalProjects = 12,
    this.totalApplications = 45,
    this.upcomingInterviews = 45,
    this.broadcastsSent = 28,
    required this.placedCount,
    required this.targetCount,
    required this.targetReachedPercentage,
    required this.upcomingDrives,
    required this.recentActivities,
    required this.scheduleEvents,
  });

  factory CollegeDashboardModel.fromJson(Map<String, dynamic> json, {Map<String, dynamic>? profile}) {
    final collegeObj = profile ?? {};
    final total = (json['totalStudents'] as num?)?.toInt() ?? 2480;
    final active = (json['activeStudents'] as num?)?.toInt() ?? (json['activeCandidates'] as num?)?.toInt() ?? 1822;
    final projects = (json['totalProjects'] as num?)?.toInt() ?? 12;
    final applications = (json['totalApplications'] as num?)?.toInt() ?? 45;

    return CollegeDashboardModel(
      collegeName: collegeObj['name']?.toString() ?? json['collegeName']?.toString() ?? 'MIT Academy of Engineering',
      university: collegeObj['university']?.toString() ?? json['university']?.toString() ?? 'State Technical University',
      email: collegeObj['email']?.toString() ?? json['email']?.toString() ?? 'admin@college.edu',
      totalStudents: total,
      studentGrowth: json['studentGrowth']?.toString() ?? '+12.4%',
      activeCandidates: active,
      candidateGrowth: json['candidateGrowth']?.toString() ?? '+5.8%',
      placementPercentage: (json['placementPercentage'] as num?)?.toDouble() ?? 82.4,
      totalProjects: projects,
      totalApplications: applications,
      upcomingInterviews: applications > 0 ? applications : 45,
      broadcastsSent: (json['broadcastsSent'] as num?)?.toInt() ?? 28,
      placedCount: (json['placedCount'] as num?)?.toInt() ?? (total > 0 ? (total * 0.824).round() : 1934),
      targetCount: (json['targetCount'] as num?)?.toInt() ?? (total > 0 ? total : 2480),
      targetReachedPercentage: json['targetReachedPercentage']?.toString() ?? '82.4%',
      upcomingDrives: (json['upcomingDrives'] as List<dynamic>?)
              ?.map((e) => CampusDriveModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          CampusDriveModel.defaultDrives,
      recentActivities: (json['recentActivities'] as List<dynamic>?)
              ?.map((e) => RecentActivityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          RecentActivityModel.defaultActivities,
      scheduleEvents: (json['scheduleEvents'] as List<dynamic>?)
              ?.map((e) => ScheduleEventModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          ScheduleEventModel.defaultEvents,
    );
  }

  static const CollegeDashboardModel mockData = CollegeDashboardModel(
    collegeName: 'MIT Academy of Engineering',
    university: 'State Technical University',
    email: 'admin@college.edu',
    totalStudents: 4128,
    studentGrowth: '+4%^',
    activeCandidates: 3842,
    candidateGrowth: '+5.8%',
    placementPercentage: 82.4,
    totalProjects: 12,
    totalApplications: 45,
    upcomingInterviews: 45,
    broadcastsSent: 28,
    placedCount: 3400,
    targetCount: 4128,
    targetReachedPercentage: '82.4%',
    upcomingDrives: CampusDriveModel.defaultDrives,
    recentActivities: RecentActivityModel.defaultActivities,
    scheduleEvents: ScheduleEventModel.defaultEvents,
  );
}

class CampusDriveModel {
  final String id;
  final String companyName;
  final String logoUrl;
  final String date;
  final String role;
  final String ctc;
  final List<String> eligibleBranches;

  const CampusDriveModel({
    required this.id,
    required this.companyName,
    required this.logoUrl,
    required this.date,
    required this.role,
    required this.ctc,
    this.eligibleBranches = const ['CSE', 'ECE', 'IT'],
  });

  factory CampusDriveModel.fromJson(Map<String, dynamic> json) {
    return CampusDriveModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? json['company']?.toString() ?? json['title']?.toString() ?? 'Tech Partner',
      logoUrl: json['logoUrl']?.toString() ?? '',
      date: json['date']?.toString() ?? json['driveDate']?.toString() ?? 'Upcoming',
      role: json['role']?.toString() ?? json['jobRole']?.toString() ?? 'Software Engineer',
      ctc: json['ctc']?.toString() ?? (json['packageLPA'] != null ? '${json['packageLPA']} LPA' : '8.5 LPA'),
      eligibleBranches: (json['eligibleBranches'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const ['CSE', 'ECE', 'IT'],
    );
  }

  static const List<CampusDriveModel> defaultDrives = [
    CampusDriveModel(
      id: 'd1',
      companyName: 'Wipro Tech',
      logoUrl: 'https://logo.clearbit.com/wipro.com',
      date: 'Mar 15, 2026',
      role: 'Full Stack Developer',
      ctc: '8.5 LPA',
    ),
    CampusDriveModel(
      id: 'd2',
      companyName: 'Aether Electronics',
      logoUrl: 'https://logo.clearbit.com/aether.com',
      date: 'Mar 19, 2026',
      role: 'Product Analyst',
      ctc: '12.0 LPA',
    ),
    CampusDriveModel(
      id: 'd3',
      companyName: 'Nexus Finance',
      logoUrl: 'https://logo.clearbit.com/nexus.com',
      date: 'Mar 25, 2026',
      role: 'Risk Auditor',
      ctc: '9.2 LPA',
    ),
  ];
}

class RecentActivityModel {
  final String id;
  final String name;
  final String detail;
  final String action;
  final String badgeText;
  final String badgeType; // 'applied', 'score', 'updated', 'shortlisted'
  final String avatarColor;

  const RecentActivityModel({
    required this.id,
    required this.name,
    required this.detail,
    required this.action,
    required this.badgeText,
    this.badgeType = 'applied',
    this.avatarColor = 'blue',
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['studentName']?.toString() ?? 'Candidate',
      detail: json['detail']?.toString() ?? json['department']?.toString() ?? '(CS 2025)',
      action: json['action']?.toString() ?? json['description']?.toString() ?? 'applied for role',
      badgeText: json['badgeText']?.toString() ?? json['status']?.toString() ?? 'APPLIED',
      badgeType: json['badgeType']?.toString() ?? 'applied',
      avatarColor: json['avatarColor']?.toString() ?? 'blue',
    );
  }

  static const List<RecentActivityModel> defaultActivities = [
    RecentActivityModel(
      id: 'act-1',
      name: 'Rahul Verma',
      detail: '(CS 2025)',
      action: 'applied for Microsoft SDE Intern',
      badgeText: 'APPLIED',
      badgeType: 'applied',
      avatarColor: 'blue',
    ),
    RecentActivityModel(
      id: 'act-2',
      name: 'Priya Singh',
      detail: '(EC 2025)',
      action: 'completed Python Assessment',
      badgeText: '88/100',
      badgeType: 'score',
      avatarColor: 'purple',
    ),
    RecentActivityModel(
      id: 'act-3',
      name: 'Arun Kumar',
      detail: '(ME 2025)',
      action: 'updated his Resume Profile',
      badgeText: 'UPDATED',
      badgeType: 'updated',
      avatarColor: 'amber',
    ),
    RecentActivityModel(
      id: 'act-4',
      name: 'Ananya Deshpande',
      detail: '(IT 2025)',
      action: 'was shortlisted for Deloitte USI',
      badgeText: 'SHORTLISTED',
      badgeType: 'shortlisted',
      avatarColor: 'emerald',
    ),
  ];
}

class ScheduleEventModel {
  final String id;
  final String month;
  final String day;
  final String title;
  final String subtitle;
  final String tag;

  const ScheduleEventModel({
    required this.id,
    required this.month,
    required this.day,
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  factory ScheduleEventModel.fromJson(Map<String, dynamic> json) {
    return ScheduleEventModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      month: json['month']?.toString() ?? 'OCT',
      day: json['day']?.toString() ?? '15',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      tag: json['tag']?.toString() ?? 'Event',
    );
  }

  static const List<ScheduleEventModel> defaultEvents = [
    ScheduleEventModel(
      id: 'sch-1',
      month: 'OCT',
      day: '12',
      title: 'NVIDIA Orientation',
      subtitle: 'Pre-Placement Talk & Technical Overview',
      tag: 'Orientation',
    ),
    ScheduleEventModel(
      id: 'sch-2',
      month: 'OCT',
      day: '14',
      title: 'Amazon Online Assessment',
      subtitle: 'Coding & Aptitude Test (Main Lab)',
      tag: 'Assessment',
    ),
    ScheduleEventModel(
      id: 'sch-3',
      month: 'OCT',
      day: '18',
      title: 'Deloitte Final Interviews',
      subtitle: 'HR & Tech Rounds (Auditorium)',
      tag: 'Interviews',
    ),
    ScheduleEventModel(
      id: 'sch-4',
      month: 'OCT',
      day: '21',
      title: 'HDFC Group Discussion',
      subtitle: 'Managerial Trainee Batch Selection',
      tag: 'Group Discussion',
    ),
  ];
}
