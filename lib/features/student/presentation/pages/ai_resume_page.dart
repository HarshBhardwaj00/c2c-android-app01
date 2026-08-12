import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/student_api_service.dart';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resume Live Preview (${_template.toUpperCase()})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildFormattedResumePreview(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  _copyToClipboard();
                  Navigator.pop(context);
                },
                icon: const Icon(LucideIcons.copy, size: 18),
                label: const Text('Copy Resume as Plain Text'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
            onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
          ),
          title: const Text(
            'AI Resume Builder',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            if (_isSaving)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 12),
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
              icon: const Icon(LucideIcons.eye),
              tooltip: 'Preview Resume',
              onPressed: _showPreviewSheet,
            ),
            IconButton(
              icon: const Icon(LucideIcons.refreshCw),
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
                      _buildSectionCard(
                        title: 'Experience & Projects',
                        icon: LucideIcons.briefcase,
                        iconColor: Colors.blue.shade700,
                        trailing: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _experience.add(
                                ExperienceEntryData(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                ),
                              );
                            });
                            _triggerAutoSave();
                          },
                          icon: const Icon(LucideIcons.plus, size: 14),
                          label: const Text('Add Entry'),
                        ),
                        child: _buildExperienceList(),
                      ),
                      const SizedBox(height: 16),

                      // Education Section
                      _buildSectionCard(
                        title: 'Education',
                        icon: LucideIcons.graduationCap,
                        iconColor: Colors.green.shade700,
                        trailing: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _education.add(
                                EducationEntryData(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                ),
                              );
                            });
                            _triggerAutoSave();
                          },
                          icon: const Icon(LucideIcons.plus, size: 14),
                          label: const Text('Add Education'),
                        ),
                        child: _buildEducationList(),
                      ),
                      const SizedBox(height: 16),

                      // Certifications Section
                      _buildSectionCard(
                        title: 'Certifications',
                        icon: LucideIcons.award,
                        iconColor: Colors.purple.shade700,
                        trailing: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _certifications.add(
                                CertificationEntryData(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                ),
                              );
                            });
                            _triggerAutoSave();
                          },
                          icon: const Icon(LucideIcons.plus, size: 14),
                          label: const Text('Add Cert'),
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
          Row(
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
              const Spacer(),
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
              Text('Quick AI Note Extractor', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accentViolet)),
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
              ElevatedButton.icon(
                onPressed: _isAssistantLoading ? null : _classifyAssistantNote,
                icon: _isAssistantLoading
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(LucideIcons.sparkles, size: 14),
                label: const Text('Add with AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentViolet,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.target, size: 18, color: AppColors.success),
                  SizedBox(width: 8),
                  AutoSizeText(
                    'ATS Score Optimizer',
                    maxLines: 1,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _isAtsLoading ? null : _analyzeAtsScore,
                icon: _isAtsLoading
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(LucideIcons.cpu, size: 14),
                label: const Text('Analyze Score'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _experience.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final item = _experience[index];
        final isEnhancing = _enhancingExperienceId == item.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Experience #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                  onPressed: () {
                    setState(() {
                      _experience.removeAt(index);
                    });
                    _triggerAutoSave();
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildTextField('Role / Position', item.roleController, LucideIcons.userCheck)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Organization / Company', item.organizationController, LucideIcons.building)),
              ],
            ),
            const SizedBox(height: 8),
            _buildTextField('Duration (e.g. Summer 2025)', item.durationController, LucideIcons.calendar),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bullet Points (One per line)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                TextButton.icon(
                  onPressed: isEnhancing ? null : () => _enhanceExperienceBullets(item),
                  icon: isEnhancing
                      ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(LucideIcons.sparkles, size: 12),
                  label: const Text('Enhance with AI', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            TextField(
              controller: item.bulletsController,
              maxLines: 3,
              onChanged: (_) => _triggerAutoSave(),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: '• Engineered microservices...\n• Reduced query latency by 40%...',
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEducationList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _education.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final item = _education[index];
        return Column(
          children: [
            Row(
              children: [
                Text('Education #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                  onPressed: () {
                    setState(() {
                      _education.removeAt(index);
                    });
                    _triggerAutoSave();
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildTextField('Degree / Program', item.degreeController, LucideIcons.graduationCap)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Institution', item.institutionController, LucideIcons.building)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildTextField('Duration (e.g. 2022 - 2026)', item.durationController, LucideIcons.calendar)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('CGPA / Marks', item.gpaController, LucideIcons.award)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCertificationsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _certifications.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final item = _certifications[index];
        return Column(
          children: [
            Row(
              children: [
                Text('Cert #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                  onPressed: () {
                    setState(() {
                      _certifications.removeAt(index);
                    });
                    _triggerAutoSave();
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildTextField('Certificate Name', item.nameController, LucideIcons.award)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Issuing Authority', item.issuerController, LucideIcons.building)),
              ],
            ),
            const SizedBox(height: 8),
            _buildTextField('Issue Date', item.dateController, LucideIcons.calendar),
          ],
        );
      },
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _fullNameController.text.isEmpty ? 'Your Full Name' : _fullNameController.text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _template == 'modern' ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          Text(
            _titleController.text.isEmpty ? 'Professional Headline' : _titleController.text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            '${_emailController.text} | ${_phoneController.text} | ${_locationController.text}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const Divider(height: 20),
          if (_summaryController.text.isNotEmpty) ...[
            const Text('PROFESSIONAL SUMMARY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Text(_summaryController.text, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
          ],
          if (_skills.isNotEmpty) ...[
            const Text('SKILLS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Text(_skills.join(' • '), style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
          ],
          if (_experience.isNotEmpty) ...[
            const Text('EXPERIENCE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            ..._experience.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${e.roleController.text} — ${e.organizationController.text} (${e.durationController.text})',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    if (e.bulletsController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 2),
                        child: Text(e.bulletsController.text, style: const TextStyle(fontSize: 11)),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (_education.isNotEmpty) ...[
            const Text('EDUCATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            ..._education.map(
              (e) => Text(
                '${e.degreeController.text} — ${e.institutionController.text} (${e.durationController.text})',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
