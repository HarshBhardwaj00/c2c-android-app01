class StudentDashboardModel {
  final StudentProfileData profile;
  final StudentStatsData stats;
  final List<StudentBadgeData> badges;
  final List<StudentModuleData> modules;
  final List<ScoreHistoryData> performanceData;
  final DailyStreakData streak;
  final List<StudentUpcomingActivityData> upcomingActivities;

  const StudentDashboardModel({
    required this.profile,
    required this.stats,
    required this.badges,
    required this.modules,
    required this.performanceData,
    required this.streak,
    required this.upcomingActivities,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
    return StudentDashboardModel(
      profile: StudentProfileData.fromJson(
        json['profile'] as Map<String, dynamic>? ?? {},
      ),
      stats: StudentStatsData.fromJson(
        json['stats'] as Map<String, dynamic>? ?? {},
      ),
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => StudentBadgeData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          StudentBadgeData.defaultBadges(),
      modules: (json['modules'] as List<dynamic>?)
              ?.map((e) => StudentModuleData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      performanceData: (json['performanceData'] as List<dynamic>?)
              ?.map((e) => ScoreHistoryData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      streak: DailyStreakData.fromJson(
        json['streak'] as Map<String, dynamic>? ?? {},
      ),
      upcomingActivities: (json['upcomingActivities'] as List<dynamic>?)
              ?.map((e) => StudentUpcomingActivityData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          StudentUpcomingActivityData.defaultActivities(),
    );
  }

  factory StudentDashboardModel.initial() {
    return StudentDashboardModel(
      profile: StudentProfileData.initial(),
      stats: StudentStatsData.initial(),
      badges: StudentBadgeData.defaultBadges(),
      modules: const [],
      performanceData: const [],
      streak: DailyStreakData.initial(),
      upcomingActivities: StudentUpcomingActivityData.defaultActivities(),
    );
  }
}

class StudentProfileData {
  final String id;
  final String name;
  final String fullName;
  final String email;
  final String phone;
  final String branch;
  final int semester;
  final String college;
  final String status;
  final String location;
  final String bio;
  final String github;
  final String linkedIn;
  final String portfolio;
  final List<String> skills;
  final String resumeUrl;
  final String photo;

  const StudentProfileData({
    required this.id,
    required this.name,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.branch,
    required this.semester,
    required this.college,
    required this.status,
    this.location = '',
    this.bio = '',
    this.github = '',
    this.linkedIn = '',
    this.portfolio = '',
    this.skills = const [],
    this.resumeUrl = '',
    this.photo = '',
  });

  factory StudentProfileData.fromJson(Map<String, dynamic> json) {
    return StudentProfileData(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      branch: json['branch']?.toString() ?? '',
      semester: (json['semester'] as num?)?.toInt() ?? 0,
      college: json['college']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Placement track active',
      location: json['location']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      github: json['github']?.toString() ?? '',
      linkedIn: json['linkedIn']?.toString() ?? json['linkedin']?.toString() ?? '',
      portfolio: json['portfolio']?.toString() ?? '',
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      resumeUrl: json['resumeUrl']?.toString() ?? json['resume']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'branch': branch,
      'semester': semester,
      'college': college,
      'status': status,
      'location': location,
      'bio': bio,
      'github': github,
      'linkedIn': linkedIn,
      'portfolio': portfolio,
      'skills': skills,
      'resumeUrl': resumeUrl,
      'photo': photo,
    };
  }

  factory StudentProfileData.initial() {
    return const StudentProfileData(
      id: '',
      name: '',
      fullName: '',
      email: '',
      phone: '',
      branch: '',
      semester: 0,
      college: '',
      status: 'Placement track active',
      location: '',
      bio: '',
      github: '',
      linkedIn: '',
      portfolio: '',
      skills: [],
      resumeUrl: '',
      photo: '',
    );
  }

  String get formattedSubTitle {
    final branchText = branch.isNotEmpty ? branch : 'Branch not added';
    final semText = semester > 0 ? 'Semester $semester' : 'Semester not added';
    return '$branchText · $semText';
  }
}

class StudentStatsData {
  final int registeredCourses;
  final int completed;
  final int pending;
  final int certificates;
  final int appliedProjects;
  final int unreadNotifications;
  final int learningScore;

  const StudentStatsData({
    required this.registeredCourses,
    required this.completed,
    required this.pending,
    required this.certificates,
    required this.appliedProjects,
    required this.unreadNotifications,
    required this.learningScore,
  });

  factory StudentStatsData.fromJson(Map<String, dynamic> json) {
    return StudentStatsData(
      registeredCourses: (json['registeredCourses'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      certificates: (json['certificates'] as num?)?.toInt() ?? 0,
      appliedProjects: (json['appliedProjects'] as num?)?.toInt() ?? 0,
      unreadNotifications: (json['unreadNotifications'] as num?)?.toInt() ?? 0,
      learningScore: (json['learningScore'] as num?)?.toInt() ?? 75,
    );
  }

  factory StudentStatsData.initial() {
    return const StudentStatsData(
      registeredCourses: 0,
      completed: 0,
      pending: 0,
      certificates: 0,
      appliedProjects: 0,
      unreadNotifications: 0,
      learningScore: 0,
    );
  }
}

class StudentBadgeData {
  final String title;
  final String icon;
  final String category;
  final bool earned;
  final String colorHex;

  const StudentBadgeData({
    required this.title,
    required this.icon,
    required this.category,
    required this.earned,
    required this.colorHex,
  });

  factory StudentBadgeData.fromJson(Map<String, dynamic> json) {
    return StudentBadgeData(
      title: json['title']?.toString() ?? 'Achievement',
      icon: json['icon']?.toString() ?? '⚛️',
      category: json['category']?.toString() ?? 'Technical',
      earned: json['earned'] as bool? ?? false,
      colorHex: json['colorHex']?.toString() ?? '0xFF6366F1',
    );
  }

  static List<StudentBadgeData> defaultBadges() {
    return const [
      StudentBadgeData(
        title: 'React Expert',
        icon: '⚛️',
        category: 'Frontend',
        earned: true,
        colorHex: '0xFF3B82F6',
      ),
      StudentBadgeData(
        title: 'SQL Master',
        icon: '🗄️',
        category: 'Database',
        earned: true,
        colorHex: '0xFF10B981',
      ),
      StudentBadgeData(
        title: 'DSA Champion',
        icon: '⚔️',
        category: 'Problem Solving',
        earned: true,
        colorHex: '0xFF8B5CF6',
      ),
      StudentBadgeData(
        title: 'Full Stack Pro',
        icon: '💻',
        category: 'Web Dev',
        earned: false,
        colorHex: '0xFFF59E0B',
      ),
      StudentBadgeData(
        title: 'System Architect',
        icon: '🏗️',
        category: 'Architecture',
        earned: false,
        colorHex: '0xFFEC4899',
      ),
      StudentBadgeData(
        title: 'AI Engineer',
        icon: '🤖',
        category: 'AI & ML',
        earned: false,
        colorHex: '0xFF6366F1',
      ),
    ];
  }
}

class StudentModuleData {
  final String id;
  final String title;
  final String description;
  final int progressPercentage;
  final String status;

  const StudentModuleData({
    required this.id,
    required this.title,
    required this.description,
    required this.progressPercentage,
    required this.status,
  });

  factory StudentModuleData.fromJson(Map<String, dynamic> json) {
    return StudentModuleData(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Learning Module',
      description: json['description']?.toString() ?? '',
      progressPercentage: (json['progressPercentage'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'in-progress',
    );
  }
}

class ScoreHistoryData {
  final String month;
  final int score;

  const ScoreHistoryData({required this.month, required this.score});

  factory ScoreHistoryData.fromJson(Map<String, dynamic> json) {
    return ScoreHistoryData(
      month: json['month']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
    );
  }
}

class DailyStreakData {
  final int days;
  final String currentProject;
  final String todaysGoal;
  final int completedTasks;
  final int totalTasks;

  const DailyStreakData({
    required this.days,
    required this.currentProject,
    required this.todaysGoal,
    required this.completedTasks,
    required this.totalTasks,
  });

  factory DailyStreakData.fromJson(Map<String, dynamic> json) {
    return DailyStreakData(
      days: (json['days'] as num?)?.toInt() ?? 12,
      currentProject: json['currentProject']?.toString() ?? 'AI Resume Analyzer',
      todaysGoal: json['todaysGoal']?.toString() ?? 'Complete Module 4',
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 2,
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 3,
    );
  }

  factory DailyStreakData.initial() {
    return const DailyStreakData(
      days: 12,
      currentProject: 'AI Resume Analyzer',
      todaysGoal: 'Complete Module 4',
      completedTasks: 2,
      totalTasks: 3,
    );
  }
}

class StudentUpcomingActivityData {
  final String id;
  final String title;
  final String category; // 'Interview', 'Assessment', 'Placement Drive', 'Workshop'
  final String dateTimeText;
  final String durationText;
  final String locationOrLink;
  final String statusText;
  final String hostOrCompany;
  final String actionText;
  final bool isLiveNow;
  final bool isReminderSet;

  const StudentUpcomingActivityData({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTimeText,
    required this.durationText,
    required this.locationOrLink,
    required this.statusText,
    required this.hostOrCompany,
    required this.actionText,
    this.isLiveNow = false,
    this.isReminderSet = false,
  });

  factory StudentUpcomingActivityData.fromJson(Map<String, dynamic> json) {
    return StudentUpcomingActivityData(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Upcoming Corporate Event',
      category: json['category']?.toString() ?? 'General',
      dateTimeText: json['dateTimeText']?.toString() ?? json['time']?.toString() ?? 'Today',
      durationText: json['durationText']?.toString() ?? '45 mins',
      locationOrLink: json['locationOrLink']?.toString() ?? json['location']?.toString() ?? 'Online',
      statusText: json['statusText']?.toString() ?? json['status']?.toString() ?? 'Scheduled',
      hostOrCompany: json['hostOrCompany']?.toString() ?? json['company']?.toString() ?? 'Campus2Corporate',
      actionText: json['actionText']?.toString() ?? 'View Details',
      isLiveNow: json['isLiveNow'] as bool? ?? false,
      isReminderSet: json['isReminderSet'] as bool? ?? false,
    );
  }

  StudentUpcomingActivityData copyWith({
    String? id,
    String? title,
    String? category,
    String? dateTimeText,
    String? durationText,
    String? locationOrLink,
    String? statusText,
    String? hostOrCompany,
    String? actionText,
    bool? isLiveNow,
    bool? isReminderSet,
  }) {
    return StudentUpcomingActivityData(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dateTimeText: dateTimeText ?? this.dateTimeText,
      durationText: durationText ?? this.durationText,
      locationOrLink: locationOrLink ?? this.locationOrLink,
      statusText: statusText ?? this.statusText,
      hostOrCompany: hostOrCompany ?? this.hostOrCompany,
      actionText: actionText ?? this.actionText,
      isLiveNow: isLiveNow ?? this.isLiveNow,
      isReminderSet: isReminderSet ?? this.isReminderSet,
    );
  }

  static List<StudentUpcomingActivityData> defaultActivities() {
    return const [
      StudentUpcomingActivityData(
        id: 'act-1',
        title: 'Technical Interview L1 Round',
        category: 'Interview',
        dateTimeText: 'Today, 3:30 PM',
        durationText: '45 mins',
        locationOrLink: 'Google Meet',
        statusText: 'Starting Soon',
        hostOrCompany: 'Amazon Web Services',
        actionText: 'Join Meeting',
        isLiveNow: true,
        isReminderSet: true,
      ),
      StudentUpcomingActivityData(
        id: 'act-2',
        title: 'Full-Stack Coding Benchmark Test',
        category: 'Assessment',
        dateTimeText: 'Tomorrow, 10:00 AM',
        durationText: '90 mins',
        locationOrLink: 'C2C Proctored Portal',
        statusText: 'Scheduled',
        hostOrCompany: 'TCS CodeVita 2026',
        actionText: 'Start Prep',
        isLiveNow: false,
        isReminderSet: false,
      ),
      StudentUpcomingActivityData(
        id: 'act-3',
        title: 'Google STEP Internship Drive Presentation',
        category: 'Placement Drive',
        dateTimeText: '12 Aug, 2:00 PM',
        durationText: '60 mins',
        locationOrLink: 'Main Campus Auditorium & Live Stream',
        statusText: 'Registration Open',
        hostOrCompany: 'Google India Staffing',
        actionText: 'View JD & Apply',
        isLiveNow: false,
        isReminderSet: true,
      ),
      StudentUpcomingActivityData(
        id: 'act-4',
        title: 'System Design & Microservices Masterclass',
        category: 'Workshop',
        dateTimeText: '14 Aug, 4:00 PM',
        durationText: '120 mins',
        locationOrLink: 'Lab 4 & Zoom',
        statusText: 'Confirmed',
        hostOrCompany: 'Enterprise AI Mentors',
        actionText: 'Reserve Seat',
        isLiveNow: false,
        isReminderSet: false,
      ),
    ];
  }
}
