class PlacementDriveModel {
  final String id;
  final String companyId;
  final String companyName;
  final String companyLogoUrl;
  final String roleTitle;
  final String ctcPackage;
  final String driveDate;
  final String locationType; // On-Campus, Off-Campus, Hybrid
  final String status; // Live, Upcoming, Completed
  final String tier; // Tier 1, Gold Partner, Mass Recruiter
  final int appliedCount;
  final int shortlistedCount;
  final int interviewingCount;
  final int offeredCount;
  final int eligibleCount;
  final List<String> requiredSkills;
  final String minCgpa;
  final String recruiterContact;
  final String recruiterEmail;
  final double rating;

  const PlacementDriveModel({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.companyLogoUrl,
    required this.roleTitle,
    required this.ctcPackage,
    required this.driveDate,
    required this.locationType,
    required this.status,
    required this.tier,
    required this.appliedCount,
    required this.shortlistedCount,
    required this.interviewingCount,
    required this.offeredCount,
    required this.eligibleCount,
    required this.requiredSkills,
    required this.minCgpa,
    required this.recruiterContact,
    required this.recruiterEmail,
    required this.rating,
  });

  factory PlacementDriveModel.fromJson(Map<String, dynamic> json) {
    return PlacementDriveModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? 'd1',
      companyId: json['companyId']?.toString() ?? 'c1',
      companyName: json['companyName']?.toString() ?? 'Wipro Tech',
      companyLogoUrl: json['companyLogoUrl']?.toString() ?? '',
      roleTitle: json['roleTitle']?.toString() ?? 'Full Stack Developer',
      ctcPackage: json['ctcPackage']?.toString() ?? '8.5 LPA',
      driveDate: json['driveDate']?.toString() ?? 'Mar 15, 2024',
      locationType: json['locationType']?.toString() ?? 'On-Campus',
      status: json['status']?.toString() ?? 'Live',
      tier: json['tier']?.toString() ?? 'Gold Partner',
      appliedCount: (json['appliedCount'] as num?)?.toInt() ?? 142,
      shortlistedCount: (json['shortlistedCount'] as num?)?.toInt() ?? 45,
      interviewingCount: (json['interviewingCount'] as num?)?.toInt() ?? 18,
      offeredCount: (json['offeredCount'] as num?)?.toInt() ?? 8,
      eligibleCount: (json['eligibleCount'] as num?)?.toInt() ?? 310,
      requiredSkills: (json['requiredSkills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Flutter', 'Node.js', 'SQL'],
      minCgpa: json['minCgpa']?.toString() ?? '7.0',
      recruiterContact: json['recruiterContact']?.toString() ?? 'Priya Nair (Lead HR)',
      recruiterEmail: json['recruiterEmail']?.toString() ?? 'priya.nair@wipro.com',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }

  static const List<PlacementDriveModel> mockDrives = [
    PlacementDriveModel(
      id: 'd1',
      companyId: 'c1',
      companyName: 'Wipro Tech',
      companyLogoUrl: 'https://logo.clearbit.com/wipro.com',
      roleTitle: 'Full Stack Developer',
      ctcPackage: '8.5 LPA',
      driveDate: 'Mar 15, 2024',
      locationType: 'On-Campus',
      status: 'Live',
      tier: 'Gold Partner',
      appliedCount: 142,
      shortlistedCount: 45,
      interviewingCount: 18,
      offeredCount: 8,
      eligibleCount: 310,
      requiredSkills: ['Flutter', 'Node.js', 'SQL', 'Git'],
      minCgpa: '7.5',
      recruiterContact: 'Rajesh Malhotra (University Recruiter)',
      recruiterEmail: 'campus@wipro.com',
      rating: 4.6,
    ),
    PlacementDriveModel(
      id: 'd2',
      companyId: 'c2',
      companyName: 'Aether Electronics',
      companyLogoUrl: 'https://logo.clearbit.com/aether.com',
      roleTitle: 'Product Analyst',
      ctcPackage: '12.0 LPA',
      driveDate: 'Mar 19, 2024',
      locationType: 'Hybrid',
      status: 'Live',
      tier: 'Tier 1 Recruiter',
      appliedCount: 98,
      shortlistedCount: 32,
      interviewingCount: 12,
      offeredCount: 5,
      eligibleCount: 220,
      requiredSkills: ['Python', 'SQL', 'Tableau', 'Product Metrics'],
      minCgpa: '8.0',
      recruiterContact: 'Sneha Kapoor (Lead Talent Partner)',
      recruiterEmail: 'sneha.kapoor@aether.com',
      rating: 4.9,
    ),
    PlacementDriveModel(
      id: 'd3',
      companyId: 'c3',
      companyName: 'Nexus Finance',
      companyLogoUrl: 'https://logo.clearbit.com/nexus.com',
      roleTitle: 'Risk Auditor',
      ctcPackage: '9.2 LPA',
      driveDate: 'Mar 25, 2024',
      locationType: 'On-Campus',
      status: 'Upcoming',
      tier: 'Gold Partner',
      appliedCount: 110,
      shortlistedCount: 0,
      interviewingCount: 0,
      offeredCount: 0,
      eligibleCount: 280,
      requiredSkills: ['Financial Modeling', 'Excel', 'Risk Analysis'],
      minCgpa: '7.0',
      recruiterContact: 'Vikram Mehta (Campus Lead)',
      recruiterEmail: 'careers@nexusfin.com',
      rating: 4.5,
    ),
    PlacementDriveModel(
      id: 'd4',
      companyId: 'c4',
      companyName: 'Google',
      companyLogoUrl: 'https://logo.clearbit.com/google.com',
      roleTitle: 'Software Engineer (STEP)',
      ctcPackage: '32.0 LPA',
      driveDate: 'Feb 20, 2024',
      locationType: 'On-Campus',
      status: 'Completed',
      tier: 'Tier 1 Global',
      appliedCount: 350,
      shortlistedCount: 45,
      interviewingCount: 12,
      offeredCount: 4,
      eligibleCount: 400,
      requiredSkills: ['C++', 'Data Structures', 'Algorithms', 'System Design'],
      minCgpa: '8.5',
      recruiterContact: 'Amanda Chen (University Staffing)',
      recruiterEmail: 'tech-campus@google.com',
      rating: 5.0,
    ),
  ];
}
