class CollegeStudentModel {
  final String id;
  final String studentCode;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String department;
  final String year;
  final String batch;
  final double cgpa;
  final int attendance;
  final int activeBacklogs;
  final int readinessScore;
  final int atsScore;
  final String placementStatus;
  final String placedCompany;
  final List<String> skills;
  final String bio;
  final List<StudentDriveApplicationModel> appliedDrives;
  final bool isAtRisk;

  const CollegeStudentModel({
    required this.id,
    required this.studentCode,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.department,
    required this.year,
    required this.batch,
    required this.cgpa,
    required this.attendance,
    required this.activeBacklogs,
    required this.readinessScore,
    required this.atsScore,
    required this.placementStatus,
    required this.placedCompany,
    required this.skills,
    required this.bio,
    required this.appliedDrives,
    this.isAtRisk = false,
  });

  factory CollegeStudentModel.fromJson(Map<String, dynamic> json) {
    return CollegeStudentModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      studentCode: json['studentCode']?.toString() ?? 'C2C-${json['_id']?.toString().substring(0, 4) ?? '2024'}',
      name: json['name']?.toString() ?? 'Student Name',
      email: json['email']?.toString() ?? 'student@apex.edu',
      phone: json['phone']?.toString().isNotEmpty == true ? json['phone'].toString() : '+91 98765 43210',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      department: json['department']?.toString() ?? json['branch']?.toString() ?? 'Computer Science',
      year: json['year']?.toString() ?? (json['semester'] != null ? 'Semester ${json['semester']}' : '4th Year'),
      batch: json['batch']?.toString() ?? '2025',
      cgpa: (json['cgpa'] as num?)?.toDouble() ?? ((json['percentage'] as num?) != null ? ((json['percentage'] as num) / 10.0) : 8.5),
      attendance: (json['attendance'] as num?)?.toInt() ?? 92,
      activeBacklogs: (json['activeBacklogs'] as num?)?.toInt() ?? 0,
      readinessScore: (json['readinessScore'] as num?)?.toInt() ?? 88,
      atsScore: (json['atsScore'] as num?)?.toInt() ?? 92,
      placementStatus: json['placementStatus']?.toString() ?? (json['status'] == 'Active' ? 'Eligible' : 'In Process'),
      placedCompany: json['placedCompany']?.toString() ?? '',
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      bio: json['bio']?.toString() ?? 'Full-Stack Developer passionate about Flutter & AI systems.',
      appliedDrives: (json['appliedDrives'] as List<dynamic>?)
              ?.map((e) => StudentDriveApplicationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isAtRisk: json['isAtRisk'] as bool? ?? false,
    );
  }

  static const List<CollegeStudentModel> mockStudents = [
    CollegeStudentModel(
      id: 's1',
      studentCode: 'C2C-2024-8821',
      name: 'Riya Sharma',
      email: 'riya.sharma@apex.edu',
      phone: '+91 98765 43210',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      department: 'Computer Science',
      year: '4th Year',
      batch: '2025',
      cgpa: 8.8,
      attendance: 94,
      activeBacklogs: 0,
      readinessScore: 92,
      atsScore: 94,
      placementStatus: 'Placed',
      placedCompany: 'TCS (8.5 LPA)',
      skills: ['Flutter', 'Python', 'React', 'Data Structures', 'AWS'],
      bio: 'Full-Stack Mobile Engineer with hands-on experience in cross-platform apps and cloud backend architectures.',
      isAtRisk: false,
      appliedDrives: [
        StudentDriveApplicationModel(companyName: 'TCS', role: 'Full Stack Developer', status: 'Offered', date: '12 Mar 2024'),
        StudentDriveApplicationModel(companyName: 'Infosys', role: 'System Engineer', status: 'Shortlisted', date: '08 Mar 2024'),
        StudentDriveApplicationModel(companyName: 'Amazon', role: 'SDE-1', status: 'Interviewing', date: '01 Mar 2024'),
      ],
    ),
    CollegeStudentModel(
      id: 's2',
      studentCode: 'C2C-2024-8822',
      name: 'Aarav Patel',
      email: 'aarav.patel@apex.edu',
      phone: '+91 98765 43211',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      department: 'Computer Science',
      year: '4th Year',
      batch: '2025',
      cgpa: 9.2,
      attendance: 98,
      activeBacklogs: 0,
      readinessScore: 96,
      atsScore: 97,
      placementStatus: 'Placed',
      placedCompany: 'Google (32.0 LPA)',
      skills: ['C++', 'System Design', 'Algorithms', 'Go'],
      bio: 'Competitive programmer (Candidate Master on Codeforces) and backend cloud enthusiast.',
      isAtRisk: false,
      appliedDrives: [
        StudentDriveApplicationModel(companyName: 'Google', role: 'STEP / SWE', status: 'Offered', date: '15 Feb 2024'),
        StudentDriveApplicationModel(companyName: 'Microsoft', role: 'Software Engineer', status: 'Offered', date: '10 Feb 2024'),
      ],
    ),
    CollegeStudentModel(
      id: 's3',
      studentCode: 'C2C-2024-8823',
      name: 'Ananya Verma',
      email: 'ananya.verma@apex.edu',
      phone: '+91 98765 43212',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      department: 'ECE',
      year: '4th Year',
      batch: '2025',
      cgpa: 7.9,
      attendance: 88,
      activeBacklogs: 0,
      readinessScore: 78,
      atsScore: 82,
      placementStatus: 'Shortlisted',
      placedCompany: '',
      skills: ['Embedded Systems', 'IoT', 'C', 'Python'],
      bio: 'Hardware-software co-design enthusiast with focus on IoT sensors and embedded microcontrollers.',
      isAtRisk: false,
      appliedDrives: [
        StudentDriveApplicationModel(companyName: 'Aether Electronics', role: 'Embedded Developer', status: 'Shortlisted', date: '19 Mar 2024'),
      ],
    ),
    CollegeStudentModel(
      id: 's4',
      studentCode: 'C2C-2024-8824',
      name: 'Rohan Gupta',
      email: 'rohan.gupta@apex.edu',
      phone: '+91 98765 43213',
      avatarUrl: 'https://i.pravatar.cc/150?img=8',
      department: 'Mechanical',
      year: '4th Year',
      batch: '2025',
      cgpa: 6.4,
      attendance: 71,
      activeBacklogs: 2,
      readinessScore: 48,
      atsScore: 58,
      placementStatus: 'At-Risk',
      placedCompany: '',
      skills: ['AutoCAD', 'SolidWorks', 'Basic Java'],
      bio: 'Mechanical engineering student currently working on CAD simulations and automotive aerodynamics.',
      isAtRisk: true,
      appliedDrives: [
        StudentDriveApplicationModel(companyName: 'Tata Motors', role: 'GET Engineer', status: 'Applied', date: '20 Mar 2024'),
      ],
    ),
    CollegeStudentModel(
      id: 's5',
      studentCode: 'C2C-2024-8825',
      name: 'Sneha Kulkarni',
      email: 'sneha.k@apex.edu',
      phone: '+91 98765 43214',
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
      department: 'IT',
      year: '4th Year',
      batch: '2025',
      cgpa: 8.4,
      attendance: 91,
      activeBacklogs: 0,
      readinessScore: 89,
      atsScore: 90,
      placementStatus: 'Eligible',
      placedCompany: '',
      skills: ['React', 'Node.js', 'MongoDB', 'SQL'],
      bio: 'Full-stack web developer building scalable MERN web applications.',
      isAtRisk: false,
      appliedDrives: [
        StudentDriveApplicationModel(companyName: 'Wipro Tech', role: 'Full Stack Dev', status: 'Interviewing', date: '15 Mar 2024'),
      ],
    ),
  ];
}

class StudentDriveApplicationModel {
  final String companyName;
  final String role;
  final String status;
  final String date;

  const StudentDriveApplicationModel({
    required this.companyName,
    required this.role,
    required this.status,
    required this.date,
  });

  factory StudentDriveApplicationModel.fromJson(Map<String, dynamic> json) {
    return StudentDriveApplicationModel(
      companyName: json['companyName']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Applied',
      date: json['date']?.toString() ?? '',
    );
  }
}
