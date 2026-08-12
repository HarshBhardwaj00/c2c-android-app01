class InstitutionalConfigDataModel {
  final BrandingConfig branding;
  final List<Coordinator> coordinators;
  final List<Department> departments;
  final SecurityConfig security;
  final List<Integration> integrations;

  const InstitutionalConfigDataModel({
    required this.branding,
    required this.coordinators,
    required this.departments,
    required this.security,
    required this.integrations,
  });

  factory InstitutionalConfigDataModel.fromJson(Map<String, dynamic> json) {
    return InstitutionalConfigDataModel(
      branding: json['branding'] != null
          ? BrandingConfig.fromJson(json['branding'] as Map<String, dynamic>)
          : BrandingConfig.defaultData,
      coordinators: json['coordinators'] != null
          ? (json['coordinators'] as List<dynamic>)
              .map((e) => Coordinator.fromJson(e as Map<String, dynamic>))
              .toList()
          : Coordinator.defaultList,
      departments: json['departments'] != null
          ? (json['departments'] as List<dynamic>)
              .map((e) => Department.fromJson(e as Map<String, dynamic>))
              .toList()
          : Department.defaultList,
      security: json['security'] != null
          ? SecurityConfig.fromJson(json['security'] as Map<String, dynamic>)
          : SecurityConfig.defaultData,
      integrations: json['integrations'] != null
          ? (json['integrations'] as List<dynamic>)
              .map((e) => Integration.fromJson(e as Map<String, dynamic>))
              .toList()
          : Integration.defaultList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branding': branding.toJson(),
      'coordinators': coordinators.map((e) => e.toJson()).toList(),
      'departments': departments.map((e) => e.toJson()).toList(),
      'security': security.toJson(),
      'integrations': integrations.map((e) => e.toJson()).toList(),
    };
  }

  static InstitutionalConfigDataModel get mockData => InstitutionalConfigDataModel(
        branding: BrandingConfig.defaultData,
        coordinators: Coordinator.defaultList,
        departments: Department.defaultList,
        security: SecurityConfig.defaultData,
        integrations: Integration.defaultList,
      );
}

class BrandingConfig {
  final String displayName;
  final String brandColor;
  final bool isUpdated;

  const BrandingConfig({
    required this.displayName,
    required this.brandColor,
    required this.isUpdated,
  });

  factory BrandingConfig.fromJson(Map<String, dynamic> json) {
    return BrandingConfig(
      displayName: json['displayName'] as String? ?? '',
      brandColor: json['brandColor'] as String? ?? '#6366F1',
      isUpdated: json['isUpdated'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'brandColor': brandColor,
        'isUpdated': isUpdated,
      };

  static BrandingConfig get defaultData => const BrandingConfig(
        displayName: 'Bhawar Rao Institute of Technology',
        brandColor: '#4A00D0',
        isUpdated: true,
      );
}

class Coordinator {
  final String id;
  final String name;
  final String role;

  const Coordinator({
    required this.id,
    required this.name,
    required this.role,
  });

  factory Coordinator.fromJson(Map<String, dynamic> json) {
    return Coordinator(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
      };

  static List<Coordinator> get defaultList => const [
        Coordinator(id: 'c1', name: 'Mark Roberts', role: 'Engineering Lead'),
        Coordinator(id: 'c2', name: 'Aaranya Sharma', role: 'Placement Incharge'),
      ];
}

class Department {
  final String id;
  final String name;
  final int studentCount;

  const Department({
    required this.id,
    required this.name,
    required this.studentCount,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'studentCount': studentCount,
      };

  static List<Department> get defaultList => const [
        Department(id: 'd1', name: 'Computer Science', studentCount: 420),
        Department(id: 'd2', name: 'Electronics & Comm.', studentCount: 311),
      ];
}

class SecurityConfig {
  final bool twoFactorEnabled;
  final bool externalApiEnabled;
  final String lastLoginUser;

  const SecurityConfig({
    required this.twoFactorEnabled,
    required this.externalApiEnabled,
    required this.lastLoginUser,
  });

  factory SecurityConfig.fromJson(Map<String, dynamic> json) {
    return SecurityConfig(
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      externalApiEnabled: json['externalApiEnabled'] as bool? ?? false,
      lastLoginUser: json['lastLoginUser'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'twoFactorEnabled': twoFactorEnabled,
        'externalApiEnabled': externalApiEnabled,
        'lastLoginUser': lastLoginUser,
      };

  static SecurityConfig get defaultData => const SecurityConfig(
        twoFactorEnabled: true,
        externalApiEnabled: true,
        lastLoginUser: 'Justin Phillips',
      );
}

class Integration {
  final String id;
  final String name;
  final bool isConnected;

  const Integration({
    required this.id,
    required this.name,
    required this.isConnected,
  });

  factory Integration.fromJson(Map<String, dynamic> json) {
    return Integration(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isConnected: json['isConnected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isConnected': isConnected,
      };

  static List<Integration> get defaultList => const [
        Integration(id: 'i1', name: 'Google Workspace', isConnected: true),
        Integration(id: 'i2', name: 'LinkedIn Talent Hub', isConnected: true),
      ];
}
