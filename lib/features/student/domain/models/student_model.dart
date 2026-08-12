class StudentModel {
  final String id;
  final String studentCode;
  final String name;
  final String avatarUrl;
  final String department;
  final String year;
  final String batch;
  final int readinessScore;
  final List<String> skills;
  final String matchReason;
  final bool isAiHighlight;

  const StudentModel({
    required this.id,
    required this.studentCode,
    required this.name,
    required this.avatarUrl,
    required this.department,
    required this.year,
    required this.batch,
    required this.readinessScore,
    required this.skills,
    this.matchReason = '',
    this.isAiHighlight = false,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['_id']?.toString() ?? '',
      studentCode: json['studentCode']?.toString() ?? 'C2C-2024-8821',
      name: json['name']?.toString() ?? 'Student Name',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      department: json['department']?.toString() ?? 'Comp. Science',
      year: json['year']?.toString() ?? 'Final Year',
      batch: json['batch']?.toString() ?? 'Batch A',
      readinessScore: (json['readinessScore'] as num?)?.toInt() ?? 85,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      matchReason: json['matchReason']?.toString() ?? '',
      isAiHighlight: json['isAiHighlight'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'studentCode': studentCode,
      'name': name,
      'avatarUrl': avatarUrl,
      'department': department,
      'year': year,
      'batch': batch,
      'readinessScore': readinessScore,
      'skills': skills,
      'matchReason': matchReason,
      'isAiHighlight': isAiHighlight,
    };
  }
}
