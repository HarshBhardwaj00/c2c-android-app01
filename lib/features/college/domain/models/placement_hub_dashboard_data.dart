import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Calendar Event Model for Campus Drive Calendar
class CalendarEventModel {
  final String id;
  final String month;
  final String date;
  final String title;
  final String subtitle;
  final Color accentColor;
  final String driveId;

  const CalendarEventModel({
    required this.id,
    required this.month,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.driveId,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id']?.toString() ?? 'cal_1',
      month: json['month']?.toString() ?? 'OCT',
      date: json['date']?.toString() ?? '05',
      title: json['title']?.toString() ?? 'Technical Drive',
      subtitle: json['subtitle']?.toString() ?? '10:00 AM - 12:00 PM',
      accentColor: _parseColor(json['accentColor']),
      driveId: json['driveId']?.toString() ?? 'd1',
    );
  }

  static Color _parseColor(dynamic colorValue) {
    if (colorValue is String && colorValue.startsWith('#')) {
      return Color(int.parse(colorValue.replaceFirst('#', '0xFF')));
    }
    return AppColors.primary;
  }
}

/// Offer Pipeline Card Model
class PipelineOfferModel {
  final String id;
  final String driveId;
  final String roleTitle;
  final String companyName;
  final String badgeText;
  final Color badgeColor;
  final double progress; // 0.0 to 1.0

  const PipelineOfferModel({
    required this.id,
    required this.driveId,
    required this.roleTitle,
    required this.companyName,
    required this.badgeText,
    required this.badgeColor,
    required this.progress,
  });

  factory PipelineOfferModel.fromJson(Map<String, dynamic> json) {
    return PipelineOfferModel(
      id: json['id']?.toString() ?? 'p_1',
      driveId: json['driveId']?.toString() ?? 'd1',
      roleTitle: json['roleTitle']?.toString() ?? 'Software Engineering (L3)',
      companyName: json['companyName']?.toString() ?? 'GOOGLE',
      badgeText: json['badgeText']?.toString() ?? '42 PENDING',
      badgeColor: json['badgeColor'] == 'green' ? AppColors.success : AppColors.primary,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.72,
    );
  }
}

/// Recruiter Allocation Model
class RecruiterAllocationModel {
  final String id;
  final String companyId;
  final String initials;
  final String name;
  final String title;
  final int activeCount;

  const RecruiterAllocationModel({
    required this.id,
    required this.companyId,
    required this.initials,
    required this.name,
    required this.title,
    required this.activeCount,
  });

  factory RecruiterAllocationModel.fromJson(Map<String, dynamic> json) {
    return RecruiterAllocationModel(
      id: json['id']?.toString() ?? 'r_1',
      companyId: json['companyId']?.toString() ?? 'c1',
      initials: json['initials']?.toString() ?? 'JD',
      name: json['name']?.toString() ?? 'Jane Doe',
      title: json['title']?.toString() ?? 'Senior Coordinator',
      activeCount: (json['activeCount'] as num?)?.toInt() ?? 3,
    );
  }
}

/// Today's Lineup Interview Item Model
class LineupInterviewModel {
  final String id;
  final String time;
  final String candidateName;
  final String roleCompany;
  final String interviewer;
  final String statusText; // IN PROGRESS, UPCOMING, COMPLETED
  final Color statusColor;
  final Color statusBg;
  final bool isLast;

  const LineupInterviewModel({
    required this.id,
    required this.time,
    required this.candidateName,
    required this.roleCompany,
    required this.interviewer,
    required this.statusText,
    required this.statusColor,
    required this.statusBg,
    this.isLast = false,
  });

  factory LineupInterviewModel.fromJson(Map<String, dynamic> json) {
    final status = json['statusText']?.toString().toUpperCase() ?? 'UPCOMING';
    Color textCol = AppColors.textSecondary;
    Color bgCol = AppColors.inputFill;

    if (status == 'IN PROGRESS') {
      textCol = AppColors.success;
      bgCol = AppColors.successLight;
    } else if (status == 'LIVE') {
      textCol = AppColors.error;
      bgCol = AppColors.errorLight;
    }

    return LineupInterviewModel(
      id: json['id']?.toString() ?? 'l_1',
      time: json['time']?.toString() ?? '10:00 AM',
      candidateName: json['candidateName']?.toString() ?? 'Rahul Sharma',
      roleCompany: json['roleCompany']?.toString() ?? 'SDE-1 @ Google',
      interviewer: json['interviewer']?.toString() ?? 'Interviewer: David Chen',
      statusText: status,
      statusColor: textCol,
      statusBg: bgCol,
      isLast: json['isLast'] == true,
    );
  }
}

/// Aggregate Dashboard Payload Model
class PlacementHubDashboardData {
  final List<CalendarEventModel> calendarEvents;
  final List<PipelineOfferModel> offerPipelines;
  final List<RecruiterAllocationModel> recruiters;
  final List<LineupInterviewModel> todaysLineup;
  final int activeCyclesCount;
  final int totalCandidatesCount;

  const PlacementHubDashboardData({
    required this.calendarEvents,
    required this.offerPipelines,
    required this.recruiters,
    required this.todaysLineup,
    required this.activeCyclesCount,
    required this.totalCandidatesCount,
  });

  static const PlacementHubDashboardData mockData = PlacementHubDashboardData(
    activeCyclesCount: 12,
    totalCandidatesCount: 450,
    calendarEvents: [
      CalendarEventModel(
        id: 'cal_1',
        month: 'OCT',
        date: '05',
        title: 'Google Technical Training',
        subtitle: '10:00 AM - 12:00 PM',
        accentColor: AppColors.primary,
        driveId: 'd1',
      ),
      CalendarEventModel(
        id: 'cal_2',
        month: 'OCT',
        date: '07',
        title: 'Meta Campus Drive',
        subtitle: 'Main Auditorium',
        accentColor: AppColors.success,
        driveId: 'd2',
      ),
    ],
    offerPipelines: [
      PipelineOfferModel(
        id: 'p1',
        driveId: 'd1',
        roleTitle: 'Software Engineering (L3)',
        companyName: 'GOOGLE',
        badgeText: '42 PENDING',
        badgeColor: AppColors.primary,
        progress: 0.72,
      ),
      PipelineOfferModel(
        id: 'p2',
        driveId: 'd2',
        roleTitle: 'Data Science Specialist',
        companyName: 'NETFLIX',
        badgeText: '18 OFFERED',
        badgeColor: AppColors.success,
        progress: 0.88,
      ),
      PipelineOfferModel(
        id: 'p3',
        driveId: 'd3',
        roleTitle: 'Full Stack Architect',
        companyName: 'MICROSOFT',
        badgeText: '25 INTERVIEWING',
        badgeColor: AppColors.accentViolet,
        progress: 0.65,
      ),
    ],
    recruiters: [
      RecruiterAllocationModel(
        id: 'r1',
        companyId: 'c1',
        initials: 'JD',
        name: 'Jane Doe',
        title: 'Senior Coordinator',
        activeCount: 3,
      ),
      RecruiterAllocationModel(
        id: 'r2',
        companyId: 'c2',
        initials: 'AS',
        name: 'Arjun Singh',
        title: 'Lead Officer',
        activeCount: 1,
      ),
      RecruiterAllocationModel(
        id: 'r3',
        companyId: 'c3',
        initials: 'PK',
        name: 'Priya Kapoor',
        title: 'Talent Acquisition Manager',
        activeCount: 4,
      ),
    ],
    todaysLineup: [
      LineupInterviewModel(
        id: 'l1',
        time: '10:00 AM',
        candidateName: 'Rahul Sharma',
        roleCompany: 'SDE-1 @ Google',
        interviewer: 'Interviewer: David Chen',
        statusText: 'IN PROGRESS',
        statusColor: AppColors.success,
        statusBg: AppColors.successLight,
        isLast: false,
      ),
      LineupInterviewModel(
        id: 'l2',
        time: '11:30 AM',
        candidateName: 'Ananya Iyer',
        roleCompany: 'Analyst @ GS',
        interviewer: 'Interviewer: Sarah Jenkins',
        statusText: 'UPCOMING',
        statusColor: AppColors.textSecondary,
        statusBg: AppColors.inputFill,
        isLast: true,
      ),
    ],
  );
}
