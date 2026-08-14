import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/student_api_service.dart';
import '../widgets/resume_section_widgets.dart';
import '../../../auth/presentation/widgets/bouncy_button.dart';

class EducationEntryData {
  String id;
  TextEditingController degreeController;
  TextEditingController institutionController;
  TextEditingController durationController;
  TextEditingController gpaController;

  EducationEntryData({
    required this.id,
    String degree = '',
    String institution = '',
    String duration = '',
    String gpa = '',
  })  : degreeController = TextEditingController(text: degree),
        institutionController = TextEditingController(text: institution),
        durationController = TextEditingController(text: duration),
        gpaController = TextEditingController(text: gpa);

  Map<String, dynamic> toJson() => {
        'id': id,
        'degree': degreeController.text,
        'institution': institutionController.text,
        'duration': durationController.text,
        'gpa': gpaController.text,
      };

  void dispose() {
    degreeController.dispose();
    institutionController.dispose();
    durationController.dispose();
    gpaController.dispose();
  }
}

class ExperienceEntryData {
  String id;
  TextEditingController roleController;
  TextEditingController organizationController;
  TextEditingController durationController;
  TextEditingController bulletsController;

  ExperienceEntryData({
    required this.id,
    String role = '',
    String organization = '',
    String duration = '',
    String bullets = '',
  })  : roleController = TextEditingController(text: role),
        organizationController = TextEditingController(text: organization),
        durationController = TextEditingController(text: duration),
        bulletsController = TextEditingController(text: bullets);

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': roleController.text,
        'organization': organizationController.text,
        'duration': durationController.text,
        'bullets': bulletsController.text,
      };

  void dispose() {
    roleController.dispose();
    organizationController.dispose();
    durationController.dispose();
    bulletsController.dispose();
  }
}

class CertificationEntryData {
  String id;
  TextEditingController nameController;
  TextEditingController issuerController;
  TextEditingController dateController;

  CertificationEntryData({
    required this.id,
    String name = '',
    String issuer = '',
    String date = '',
  })  : nameController = TextEditingController(text: name),
        issuerController = TextEditingController(text: issuer),
        dateController = TextEditingController(text: date);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': nameController.text,
        'issuer': issuerController.text,
        'date': dateController.text,
      };

  void dispose() {
    nameController.dispose();
    issuerController.dispose();
    dateController.dispose();
  }
}

class StudentAIResumePage extends StatefulWidget {
  const StudentAIResumePage({super.key});

  @override
  State<StudentAIResumePage> createState() => _StudentAIResumePageState();
}

class _StudentAIResumePageState extends State<StudentAIResumePage> {
  final StudentApiService _apiService = StudentApiService();

  // Primary Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _targetRoleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();

  // Assistant & Input Controllers
  final TextEditingController _assistantNoteController = TextEditingController();
  final TextEditingController _skillInputController = TextEditingController();

  // Data Collections
  List<String> _skills = [];
  final List<EducationEntryData> _education = [];
  final List<ExperienceEntryData> _experience = [];
  final List<CertificationEntryData> _certifications = [];

  // State Flags
  String _template = 'modern'; // 'modern' | 'minimal'
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isAiSummaryLoading = false;
  String? _enhancingExperienceId;
  bool _isAssistantLoading = false;
  bool _isAtsLoading = false;
  String? _errorMessage;
  String? _successNote;
  Map<String, dynamic>? _atsResult;

  Timer? _debounceSaveTimer;

  @override
  void initState() {
    super.initState();
    _loadResumeData();
  }

  @override
  void dispose() {
    _debounceSaveTimer?.cancel();
    _fullNameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _targetRoleController.dispose();
    _summaryController.dispose();
    _assistantNoteController.dispose();
    _skillInputController.dispose();

    for (var e in _education) {
      e.dispose();
    }
    for (var e in _experience) {
      e.dispose();
    }
    for (var c in _certifications) {
      c.dispose();
    }
    super.dispose();
  }

  // --- API CALLS ---

  Future<void> _loadResumeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final builderData = await _apiService.getResumeBuilder();
      final profile = await _apiService.getProfile();

      final resume = (builderData['resume'] is Map<String, dynamic>)
          ? builderData['resume'] as Map<String, dynamic>
          : <String, dynamic>{};

      final savedTemplate = builderData['template']?.toString() ?? 'modern';

      _fullNameController.text =
          resume['fullName'] ?? profile['fullName'] ?? profile['name'] ?? '';
      _titleController.text = resume['title'] ?? profile['role'] ?? 'Student';
      _emailController.text = resume['email'] ?? profile['email'] ?? '';
      _phoneController.text = resume['phone'] ?? profile['phone'] ?? '';
      _locationController.text = resume['location'] ?? profile['location'] ?? '';
      _linkedinController.text = resume['linkedin'] ?? profile['linkedIn'] ?? '';
      _githubController.text = resume['github'] ?? profile['github'] ?? '';
      _targetRoleController.text = resume['targetRole'] ?? '';
      _summaryController.text = resume['summary'] ?? profile['bio'] ?? '';
      _template = savedTemplate;

      // Parse Skills
      if (resume['skills'] is List) {
        _skills = (resume['skills'] as List).map((e) => e.toString()).toList();
      } else if (profile['skills'] is List) {
        _skills = (profile['skills'] as List).map((e) => e.toString()).toList();
      } else {
        _skills = [];
      }

      // Parse Education
      _education.clear();
      final eduList = resume['education'] ?? profile['education'];
      if (eduList is List && eduList.isNotEmpty) {
        for (var item in eduList) {
          if (item is Map<String, dynamic>) {
            _education.add(
              EducationEntryData(
                id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                degree: item['degree'] ?? '',
                institution: item['institution'] ?? item['college'] ?? '',
                duration: item['duration'] ?? '',
                gpa: item['gpa'] ?? '',
              ),
            );
          }
        }
      }
      if (_education.isEmpty) {
        _education.add(
          EducationEntryData(
            id: 'edu_1',
            degree: 'B.Tech in Computer Science',
            institution: profile['college'] ?? 'University Institute of Technology',
            duration: '2022 - 2026',
            gpa: '8.5 / 10',
          ),
        );
      }

      // Parse Experience
      _experience.clear();
      final expList = resume['experience'];
      if (expList is List && expList.isNotEmpty) {
        for (var item in expList) {
          if (item is Map<String, dynamic>) {
            final bulletsRaw = item['bullets'];
            final String bulletsStr = bulletsRaw is List
                ? bulletsRaw.join('\n')
                : (bulletsRaw?.toString() ?? '');
            _experience.add(
              ExperienceEntryData(
                id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                role: item['role'] ?? '',
                organization: item['organization'] ?? '',
                duration: item['duration'] ?? '',
                bullets: bulletsStr,
              ),
            );
          }
        }
      }
      if (_experience.isEmpty) {
        _experience.add(
          ExperienceEntryData(
            id: 'exp_1',
            role: 'Software Developer Intern',
            organization: 'Campus2Corporate Tech',
            duration: 'Summer 2025',
            bullets: 'Architected responsive UI components using modern state management.\nIntegrated Dio HTTP client with JWT auth headers.',
          ),
        );
      }

      // Parse Certifications
      _certifications.clear();
      final certList = resume['certifications'];
      if (certList is List && certList.isNotEmpty) {
        for (var item in certList) {
          if (item is Map<String, dynamic>) {
            _certifications.add(
              CertificationEntryData(
                id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: item['name'] ?? '',
                issuer: item['issuer'] ?? '',
                date: item['date'] ?? '',
              ),
            );
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load resume data. Please try again.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _triggerAutoSave() {
    _debounceSaveTimer?.cancel();
    _debounceSaveTimer = Timer(const Duration(milliseconds: 1000), () async {
      if (!mounted) return;
      setState(() => _isSaving = true);
      try {
        final payload = {
          'template': _template,
          'resume': {
            'fullName': _fullNameController.text,
            'title': _titleController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'location': _locationController.text,
            'linkedin': _linkedinController.text,
            'github': _githubController.text,
            'targetRole': _targetRoleController.text,
            'summary': _summaryController.text,
            'skills': _skills,
            'education': _education.map((e) => e.toJson()).toList(),
            'experience': _experience.map((e) => e.toJson()).toList(),
            'certifications': _certifications.map((c) => c.toJson()).toList(),
          }
        };
        await _apiService.saveResumeBuilder(payload);
      } catch (_) {
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    });
  }

  Future<void> _generateAISummary() async {
    setState(() {
      _isAiSummaryLoading = true;
      _errorMessage = null;
    });

    try {
      final payload = {
        'prompt': 'Write a concise ATS resume summary for ${_fullNameController.text}. Target Role: ${_targetRoleController.text.isNotEmpty ? _targetRoleController.text : "Software Engineering"}. Skills: ${_skills.join(", ")}',
        'resume': {
          'fullName': _fullNameController.text,
          'targetRole': _targetRoleController.text,
          'skills': _skills,
          'education': _education.map((e) => '${e.degreeController.text} at ${e.institutionController.text}').join('; '),
        }
      };

      final summary = await _apiService.generateResumeSummary(payload);
      if (summary.isNotEmpty) {
        setState(() {
          _summaryController.text = summary;
        });
        _triggerAutoSave();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not generate AI summary. ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAiSummaryLoading = false;
        });
      }
    }
  }

  Future<void> _enhanceExperienceBullets(ExperienceEntryData entry) async {
    setState(() {
      _enhancingExperienceId = entry.id;
      _errorMessage = null;
    });

    try {
      final payload = {
        'role': entry.roleController.text,
        'organization': entry.organizationController.text,
        'bullets': entry.bulletsController.text,
        'prompt': 'Enhance these resume bullets for role: ${entry.roleController.text}. Notes: ${entry.bulletsController.text}'
      };

      final bullets = await _apiService.enhanceResumeExperience(payload);
      if (bullets.isNotEmpty) {
        setState(() {
          entry.bulletsController.text = bullets.join('\n');
        });
        _triggerAutoSave();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not enhance bullet points. ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _enhancingExperienceId = null;
        });
      }
    }
  }

  Future<void> _classifyAssistantNote() async {
    final note = _assistantNoteController.text.trim();
    if (note.isEmpty) return;

    setState(() {
      _isAssistantLoading = true;
      _errorMessage = null;
      _successNote = null;
    });

    try {
      final res = await _apiService.classifyResumeNote(note);
      final type = res['type']?.toString().toLowerCase().trim() ?? '';

      if (type == 'experience' || (res['experience'] is Map && (res['experience'] as Map).isNotEmpty)) {
        final exp = res['experience'] is Map ? res['experience'] as Map : {};
        final rawBullets = exp['bullets'];
        final bulletsList = rawBullets is List
            ? rawBullets.join('\n')
            : (rawBullets?.toString().isNotEmpty == true ? rawBullets.toString() : '• $note');
        setState(() {
          _experience.add(
            ExperienceEntryData(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              role: exp['role']?.toString().isNotEmpty == true ? exp['role'].toString() : 'Project Developer',
              organization: exp['organization']?.toString().isNotEmpty == true ? exp['organization'].toString() : 'Technical Project',
              duration: exp['duration']?.toString().isNotEmpty == true ? exp['duration'].toString() : 'Recent',
              bullets: bulletsList,
            ),
          );
        });
      } else if (type == 'certification' || (res['certification'] is Map && (res['certification'] as Map).isNotEmpty)) {
        final cert = res['certification'] is Map ? res['certification'] as Map : {};
        setState(() {
          _certifications.add(
            CertificationEntryData(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: cert['name']?.toString().isNotEmpty == true ? cert['name'].toString() : note,
              issuer: cert['issuer']?.toString().isNotEmpty == true ? cert['issuer'].toString() : 'Certified Issuer',
              date: cert['date']?.toString().isNotEmpty == true ? cert['date'].toString() : '2025',
            ),
          );
        });
      } else if (type == 'skill' || (res['skills'] is List && (res['skills'] as List).isNotEmpty)) {
        final newSkills = res['skills'] is List
            ? (res['skills'] as List).map((e) => e.toString()).toList()
            : [note];
        setState(() {
          for (var s in newSkills) {
            if (!_skills.contains(s)) _skills.add(s);
          }
        });
      }

      setState(() {
        _successNote = res['confirmation']?.toString() ?? 'Successfully classified and added to your resume!';
        _assistantNoteController.clear();
      });
      _triggerAutoSave();
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not parse note. Please try adding manually.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAssistantLoading = false;
        });
      }
    }
  }

  Future<void> _analyzeAtsScore() async {
    setState(() {
      _isAtsLoading = true;
      _errorMessage = null;
    });

    final resumeText = '''
${_fullNameController.text}
${_titleController.text}
${_emailController.text} | ${_phoneController.text} | ${_locationController.text}
SUMMARY: ${_summaryController.text}
SKILLS: ${_skills.join(", ")}
EDUCATION: ${_education.map((e) => "${e.degreeController.text} at ${e.institutionController.text}").join("; ")}
EXPERIENCE: ${_experience.map((e) => "${e.roleController.text} at ${e.organizationController.text}: ${e.bulletsController.text}").join("; ")}
''';

    try {
      final res = await _apiService.getAtsScore(resumeText);
      setState(() {
        _atsResult = res;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not analyze ATS Score. ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAtsLoading = false;
        });
      }
    }
  }

  int _calculateCompleteness() {
    int score = 0;
    if (_fullNameController.text.trim().isNotEmpty) score += 10;
    if (_emailController.text.trim().isNotEmpty && _phoneController.text.trim().isNotEmpty) score += 10;
    if (_summaryController.text.trim().length > 20) score += 20;
    if (_skills.length >= 3) score += 20;
    if (_education.any((e) => e.degreeController.text.trim().isNotEmpty)) score += 15;
    if (_experience.any((e) => e.bulletsController.text.trim().isNotEmpty)) score += 15;
    if (_certifications.isNotEmpty) score += 10;
    return score > 100 ? 100 : score;
  }

  void _addSkill() {
    final text = _skillInputController.text.trim();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() {
        _skills.add(text);
        _skillInputController.clear();
      });
      _triggerAutoSave();
    }
  }

  void _removeSkill(String s) {
    setState(() {
      _skills.remove(s);
    });
    _triggerAutoSave();
  }

  void _copyToClipboard() {
    final text = '''
${_fullNameController.text}
${_titleController.text}
${_emailController.text} | ${_phoneController.text} | ${_locationController.text}
${_linkedinController.text} | ${_githubController.text}

SUMMARY
${_summaryController.text}

SKILLS
${_skills.join(", ")}

EDUCATION
${_education.map((e) => "${e.degreeController.text} — ${e.institutionController.text} (${e.durationController.text}) ${e.gpaController.text.isNotEmpty ? 'GPA: ${e.gpaController.text}' : ''}").join("\n")}

EXPERIENCE / PROJECTS
${_experience.map((e) => "${e.roleController.text} — ${e.organizationController.text} (${e.durationController.text})\n${e.bulletsController.text}").join("\n\n")}

CERTIFICATIONS
${_certifications.map((c) => "${c.nameController.text} — ${c.issuerController.text} (${c.dateController.text})").join("\n")}
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resume copied to clipboard as text!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showPreviewSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final bottomSystemPadding = MediaQuery.of(modalContext).padding.bottom == 0
            ? 16.0
            : MediaQuery.of(modalContext).padding.bottom;

        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          maxChildSize: 0.96,
          minChildSize: 0.5,
          builder: (sheetContext, scrollController) => Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              top: 16,
              left: 18,
              right: 18,
              bottom: bottomSystemPadding,
            ),
            child: Column(
              children: [
                // Top Drag Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Header Row with Zero-Overflow Protection (Fixed 45px overflow)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(LucideIcons.fileText, size: 16, color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AutoSizeText(
                              'Resume Live Preview (${_template.toUpperCase()})',
                              maxLines: 1,
                              minFontSize: 11,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: AppColors.textSecondary, size: 20),
                      onPressed: () => Navigator.pop(modalContext),
                      tooltip: 'Close Preview',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),

                // Scrollable Formatted Resume Body
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      RepaintBoundary(
                        child: _buildFormattedResumePreview(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Action Button with Navigation Safety (Fixed bottom overlap)
                BouncyButton(
                  onPressed: () {
                    _copyToClipboard();
                    Navigator.pop(modalContext);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.copy, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Copy Resume as Plain Text',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET BUILDERS ---

  @override
  Widget build(BuildContext context) {
    final completeness = _calculateCompleteness();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                context.go('/student/dashboard');
              }
            },
          ),
          title: const AutoSizeText(
            'AI Resume Builder',
            maxLines: 1,
            minFontSize: 13,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          actions: [
            if (_isSaving)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(LucideIcons.eye, size: 20),
              tooltip: 'Preview Resume',
              onPressed: _showPreviewSheet,
            ),
            IconButton(
              icon: const Icon(LucideIcons.refreshCw, size: 20),
              tooltip: 'Reload',
              onPressed: _loadResumeData,
            ),
          ],
        ),
        body: SafeArea(
          bottom: true,
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 16),
                      Text('Loading AI Resume Workspace...', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom == 0 ? 16.0 : MediaQuery.of(context).padding.bottom,
                    top: 16.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) _buildErrorBanner(_errorMessage!),
                      if (_successNote != null) _buildSuccessBanner(_successNote!),

                      // Hero Header & Completeness Card
                      _buildHeroCard(completeness),
                      const SizedBox(height: 16),

                      // AI Freeform Note Assistant
                      _buildAiAssistantCard(),
                      const SizedBox(height: 16),

                      // ATS Optimizer Score Card
                      _buildAtsCard(),
                      const SizedBox(height: 16),

                      // Personal Contact Info Section
                      _buildSectionCard(
                        title: 'Personal & Contact Info',
                        icon: LucideIcons.user,
                        iconColor: AppColors.primary,
                        child: _buildPersonalInfoForm(),
                      ),
                      const SizedBox(height: 16),

                      // AI Professional Summary Section
                      _buildSectionCard(
                        title: 'Professional Summary',
                        icon: LucideIcons.sparkles,
                        iconColor: AppColors.accentViolet,
                        trailing: ElevatedButton.icon(
                          onPressed: _isAiSummaryLoading ? null : _generateAISummary,
                          icon: _isAiSummaryLoading
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(LucideIcons.wand2, size: 14),
                          label: const Text('Generate with AI', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentViolet,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        child: TextField(
                          controller: _summaryController,
                          maxLines: 4,
                          onChanged: (_) => _triggerAutoSave(),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Enter a crisp 2-3 sentence overview or tap "Generate with AI"...',
                            filled: true,
                            fillColor: AppColors.inputFill,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Skills Section
                      _buildSectionCard(
                        title: 'Technical & Domain Skills',
                        icon: LucideIcons.wrench,
                        iconColor: Colors.amber.shade700,
                        child: _buildSkillsForm(),
                      ),
                      const SizedBox(height: 16),

                      // Experience & Projects Section
                      ResumeSectionCard(
                        title: 'Experience & Projects',
                        icon: LucideIcons.briefcase,
                        iconColor: AppColors.primary,
                        entryCount: _experience.length,
                        trailing: ResumeAddButton(
                          label: 'Add Entry',
                          onTap: () {
                            setState(() {
                              _experience.add(
                                ExperienceEntryData(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                ),
                              );
                            });
                            _triggerAutoSave();
                          },
                        ),
                        child: _buildExperienceList(),
                      ),
                      const SizedBox(height: 16),

                      // Education Section
                      ResumeSectionCard(
                        title: 'Education',
                        icon: LucideIcons.graduationCap,
                        iconColor: AppColors.success,
                        entryCount: _education.length,
                        trailing: ResumeAddButton(
                          label: 'Add Education',
                          onTap: () {
                            setState(() {
                              _education.add(
                                EducationEntryData(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                ),
                              );
                            });
                            _triggerAutoSave();
                          },
                        ),
                        child: _buildEducationList(),
                      ),
                      const SizedBox(height: 16),

                      // Certifications Section
                      ResumeSectionCard(
                        title: 'Certifications',
                        icon: LucideIcons.award,
                        iconColor: AppColors.accentViolet,
                        entryCount: _certifications.length,
                        trailing: ResumeAddButton(
                          label: 'Add Cert',
                          onTap: () {
                            setState(() {
                              _certifications.add(
                                CertificationEntryData(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                ),
                              );
                            });
                            _triggerAutoSave();
                          },
                        ),
                        child: _buildCertificationsList(),
                      ),
                      const SizedBox(height: 24),

                      // Bottom Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _copyToClipboard,
                              icon: const Icon(LucideIcons.copy, size: 16),
                              label: const Text('Copy Plain Text'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showPreviewSheet,
                              icon: const Icon(LucideIcons.fileText, size: 16),
                              label: const Text('Preview Resume'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // --- CARDS & FORMS SUB-WIDGETS ---

  Widget _buildHeroCard(int completeness) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.sparkles, size: 12, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text('AI-Powered Workspace', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
              // Template Selector
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'modern', label: Text('Modern', style: TextStyle(fontSize: 11))),
                  ButtonSegment(value: 'minimal', label: Text('ATS Minimal', style: TextStyle(fontSize: 11))),
                ],
                selected: {_template},
                onSelectionChanged: (val) {
                  setState(() => _template = val.first);
                  _triggerAutoSave();
                },
                style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const AutoSizeText(
            'Craft Recruiter-Ready Resumes',
            maxLines: 1,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your profile details are synced automatically. Use AI to polish wording and run ATS checks.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          // Completeness Progress
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completeness / 100.0,
                    minHeight: 8,
                    backgroundColor: AppColors.inputFill,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completeness > 80 ? AppColors.success : (completeness > 50 ? AppColors.warning : AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$completeness% Complete',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiAssistantCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.aiBadgeBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.bot, size: 18, color: AppColors.accentViolet),
              SizedBox(width: 8),
              Expanded(
                child: AutoSizeText(
                  'Quick AI Note Extractor',
                  maxLines: 1,
                  minFontSize: 11,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accentViolet),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Type any raw note (e.g. "Completed AWS Cloud Cert in July 2024"). AI will classify and format it automatically!',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _assistantNoteController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'e.g. Led a team of 4 to build a React dashboard...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ElevatedButton.icon(
                    onPressed: _isAssistantLoading ? null : _classifyAssistantNote,
                    icon: _isAssistantLoading
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(LucideIcons.sparkles, size: 14),
                    label: const Text('Add with AI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentViolet,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAtsCard() {
    final score = _atsResult?['score'] ?? _atsResult?['atsScore'];
    final feedback = _atsResult?['description'] ??
        _atsResult?['tip'] ??
        _atsResult?['feedback'] ??
        _atsResult?['summary'] ??
        _atsResult?['message'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.target, size: 18, color: AppColors.success),
              const SizedBox(width: 8),
              const Expanded(
                child: AutoSizeText(
                  'ATS Score Optimizer',
                  maxLines: 1,
                  minFontSize: 11,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ElevatedButton.icon(
                    onPressed: _isAtsLoading ? null : _analyzeAtsScore,
                    icon: _isAtsLoading
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(LucideIcons.cpu, size: 14),
                    label: const Text('Analyze Score'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (score != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    child: Text(
                      '$score',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ATS Compatibility Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(
                          feedback?.toString() ?? 'Great alignment with tech keywords and standard layout rules.',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AutoSizeText(
                  title,
                  maxLines: 1,
                  minFontSize: 11,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: trailing,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 340;
        if (isNarrow) {
          return Column(
            children: [
              _buildTextField('Full Name', _fullNameController, LucideIcons.user),
              const SizedBox(height: 8),
              _buildTextField('Title / Headline', _titleController, LucideIcons.briefcase),
              const SizedBox(height: 8),
              _buildTextField('Email', _emailController, LucideIcons.mail),
              const SizedBox(height: 8),
              _buildTextField('Phone', _phoneController, LucideIcons.phone),
              const SizedBox(height: 8),
              _buildTextField('Location', _locationController, LucideIcons.mapPin),
              const SizedBox(height: 8),
              _buildTextField('Target Role', _targetRoleController, LucideIcons.target),
              const SizedBox(height: 8),
              _buildTextField('LinkedIn Profile', _linkedinController, LucideIcons.linkedin),
              const SizedBox(height: 8),
              _buildTextField('GitHub Profile', _githubController, LucideIcons.github),
            ],
          );
        }
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField('Full Name', _fullNameController, LucideIcons.user)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Title / Headline', _titleController, LucideIcons.briefcase)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('Email', _emailController, LucideIcons.mail)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Phone', _phoneController, LucideIcons.phone)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('Location', _locationController, LucideIcons.mapPin)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Target Role', _targetRoleController, LucideIcons.target)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('LinkedIn Profile', _linkedinController, LucideIcons.linkedin)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('GitHub Profile', _githubController, LucideIcons.github)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkillsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillInputController,
                onSubmitted: (_) => _addSkill(),
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Add a skill (e.g. Flutter, Node.js, Python)',
                  filled: true,
                  fillColor: AppColors.inputFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addSkill,
              icon: const Icon(LucideIcons.plus, size: 16),
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills
              .map(
                (skill) => Chip(
                  label: Text(skill, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  deleteIcon: const Icon(LucideIcons.x, size: 14),
                  onDeleted: () => _removeSkill(skill),
                  backgroundColor: AppColors.primaryLight,
                  labelStyle: const TextStyle(color: AppColors.primary),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildExperienceList() {
    if (_experience.isEmpty) {
      return const ResumeEmptySection(
        icon: LucideIcons.briefcase,
        color: AppColors.primary,
        message: 'No experience added yet. Tap "Add Entry" to start building your work history.',
      );
    }
    return Column(
      children: [
        for (var i = 0; i < _experience.length; i++) ...[
          ExperienceEntryCard(
            index: i,
            isEnhancing: _enhancingExperienceId == _experience[i].id,
            roleController: _experience[i].roleController,
            organizationController: _experience[i].organizationController,
            durationController: _experience[i].durationController,
            bulletsController: _experience[i].bulletsController,
            onFieldChanged: (_) => _triggerAutoSave(),
            onEnhance: () => _enhanceExperienceBullets(_experience[i]),
            onDelete: () {
              setState(() {
                _experience.removeAt(i);
              });
              _triggerAutoSave();
            },
          ),
          if (i != _experience.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildEducationList() {
    if (_education.isEmpty) {
      return const ResumeEmptySection(
        icon: LucideIcons.graduationCap,
        color: AppColors.success,
        message: 'No education added yet. Tap "Add Education" to include your degrees.',
      );
    }
    return Column(
      children: [
        for (var i = 0; i < _education.length; i++) ...[
          EducationEntryCard(
            index: i,
            degreeController: _education[i].degreeController,
            institutionController: _education[i].institutionController,
            durationController: _education[i].durationController,
            gpaController: _education[i].gpaController,
            onFieldChanged: (_) => _triggerAutoSave(),
            onDelete: () {
              setState(() {
                _education.removeAt(i);
              });
              _triggerAutoSave();
            },
          ),
          if (i != _education.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildCertificationsList() {
    if (_certifications.isEmpty) {
      return const ResumeEmptySection(
        icon: LucideIcons.award,
        color: AppColors.accentViolet,
        message: 'No certifications added yet. Tap "Add Cert" to showcase your credentials.',
      );
    }
    return Column(
      children: [
        for (var i = 0; i < _certifications.length; i++) ...[
          CertificationEntryCard(
            index: i,
            nameController: _certifications[i].nameController,
            issuerController: _certifications[i].issuerController,
            dateController: _certifications[i].dateController,
            onFieldChanged: (_) => _triggerAutoSave(),
            onDelete: () {
              setState(() {
                _certifications.removeAt(i);
              });
              _triggerAutoSave();
            },
          ),
          if (i != _certifications.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      onChanged: (_) => _triggerAutoSave(),
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 14, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildErrorBanner(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(LucideIcons.alertTriangle, size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: const TextStyle(fontSize: 12, color: AppColors.error))),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(LucideIcons.checkCircle, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: const TextStyle(fontSize: 12, color: AppColors.success))),
        ],
      ),
    );
  }

  Widget _buildFormattedResumePreview() {
    final fullName = _fullNameController.text.trim().isEmpty ? 'Your Full Name' : _fullNameController.text.trim();
    final headline = _titleController.text.trim().isEmpty ? 'Professional Headline' : _titleController.text.trim();

    final contactItems = [
      _emailController.text.trim(),
      _phoneController.text.trim(),
      _locationController.text.trim(),
      _linkedinController.text.trim(),
      _githubController.text.trim(),
    ].where((s) => s.isNotEmpty).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name
          AutoSizeText(
            fullName,
            maxLines: 1,
            minFontSize: 16,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _template == 'modern' ? AppColors.primary : AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),

          // Professional Headline
          AutoSizeText(
            headline,
            maxLines: 1,
            minFontSize: 12,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Contact Details (Filtered, Zero-Overflow Wrap)
          if (contactItems.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: contactItems.map((item) {
                return Text(
                  item,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Professional Summary
          if (_summaryController.text.trim().isNotEmpty) ...[
            const Text(
              'PROFESSIONAL SUMMARY',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _summaryController.text.trim(),
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Skills
          if (_skills.isNotEmpty) ...[
            const Text(
              'SKILLS',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          // Experience
          if (_experience.isNotEmpty) ...[
            const Text(
              'EXPERIENCE',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            ..._experience.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            '${e.roleController.text.trim().isNotEmpty ? e.roleController.text.trim() : "Role"} — ${e.organizationController.text.trim().isNotEmpty ? e.organizationController.text.trim() : "Organization"}',
                            maxLines: 2,
                            minFontSize: 11,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (e.durationController.text.trim().isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '(${e.durationController.text.trim()})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (e.bulletsController.text.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 4),
                        child: Text(
                          e.bulletsController.text.trim(),
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Education
          if (_education.isNotEmpty) ...[
            const Text(
              'EDUCATION',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            ..._education.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        '${e.degreeController.text.trim().isNotEmpty ? e.degreeController.text.trim() : "Degree"} — ${e.institutionController.text.trim().isNotEmpty ? e.institutionController.text.trim() : "Institution"}',
                        maxLines: 2,
                        minFontSize: 11,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (e.durationController.text.trim().isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(${e.durationController.text.trim()})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Certifications
          if (_certifications.isNotEmpty) ...[
            const Text(
              'CERTIFICATIONS',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            ..._certifications.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        '${c.nameController.text.trim().isNotEmpty ? c.nameController.text.trim() : "Certificate"} — ${c.issuerController.text.trim().isNotEmpty ? c.issuerController.text.trim() : "Issuer"}',
                        maxLines: 2,
                        minFontSize: 11,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (c.dateController.text.trim().isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(${c.dateController.text.trim()})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
