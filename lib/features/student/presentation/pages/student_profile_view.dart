import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../bloc/student_bloc.dart';
import '../../data/student_api_service.dart';
import '../../domain/models/student_dashboard_model.dart';

/// Complete, 100% Figma-Fidelity Student Profile Screen with full interactive editing for:
/// - Personal Details with strict input validation
/// - Avatar photo upload via FilePicker & multipart API
/// - Skills (Add/Remove tags)
/// - About Me (Bio)
/// - Social & Links (GitHub, LinkedIn, Portfolio)
/// - Real PDF Resume Upload (Multipart) & URL Opening Launcher
/// - Complete error handling (no false success) & zero mock fallbacks
class StudentProfileView extends StatefulWidget {
  final StudentProfileData? initialProfile;
  final StudentApiService? apiService;

  const StudentProfileView({
    super.key,
    this.initialProfile,
    this.apiService,
  });

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  late final StudentApiService _apiService;
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  bool _isUploadingResume = false;
  String _formError = '';

  // Backend-synced display data (no hardcoding)
  String _status = 'Active';
  List<Map<String, dynamic>> _education = [];
  int _earnedCerts = 0;

  // Controllers for editable profile fields
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _collegeController;
  late final TextEditingController _branchController;
  late final TextEditingController _semesterController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;
  late final TextEditingController _githubController;
  late final TextEditingController _linkedInController;
  late final TextEditingController _portfolioController;
  late final TextEditingController _newSkillController;

  List<String> _skills = [];
  String _resumeUrl = '';
  String _photoUrl = '';

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? StudentApiService();

    final p = widget.initialProfile;
    _fullNameController = TextEditingController(text: p?.fullName ?? p?.name ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _collegeController = TextEditingController(text: p?.college ?? '');
    _branchController = TextEditingController(text: p?.branch ?? '');
    _semesterController = TextEditingController(text: p?.semester != null && p!.semester > 0 ? '${p.semester}' : '');
    _locationController = TextEditingController(text: p?.location ?? '');
    _bioController = TextEditingController(text: p?.bio ?? '');
    _githubController = TextEditingController(text: p?.github ?? '');
    _linkedInController = TextEditingController(text: p?.linkedIn ?? '');
    _portfolioController = TextEditingController(text: p?.portfolio ?? '');
    _newSkillController = TextEditingController();
    _skills = List<String>.from(p?.skills ?? []);
    _resumeUrl = p?.resumeUrl ?? '';
    _photoUrl = p?.photo ?? '';

    _loadCachedProfileThenFetch();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _collegeController.dispose();
    _branchController.dispose();
    _semesterController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _githubController.dispose();
    _linkedInController.dispose();
    _portfolioController.dispose();
    _newSkillController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedProfileThenFetch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJsonStr = prefs.getString('cached_student_profile');
      if (cachedJsonStr != null && cachedJsonStr.isNotEmpty) {
        final Map<String, dynamic> p = jsonDecode(cachedJsonStr);
        if (mounted) {
          setState(() {
            if (p['fullName'] != null && p['fullName'].toString().isNotEmpty) {
              _fullNameController.text = p['fullName'].toString();
            }
            if (p['email'] != null) _emailController.text = p['email'].toString();
            if (p['phone'] != null) _phoneController.text = p['phone'].toString();
            if (p['college'] != null) _collegeController.text = p['college'].toString();
            if (p['branch'] != null) _branchController.text = p['branch'].toString();
            if (p['semester'] != null && p['semester'] != 0) {
              _semesterController.text = p['semester'].toString();
            }
            if (p['location'] != null) _locationController.text = p['location'].toString();
            if (p['bio'] != null) _bioController.text = p['bio'].toString();
            if (p['github'] != null) _githubController.text = p['github'].toString();
            if (p['linkedIn'] != null) _linkedInController.text = p['linkedIn'].toString();
            if (p['portfolio'] != null) _portfolioController.text = p['portfolio'].toString();
            if (p['skills'] is List) _skills = List<String>.from(p['skills']);
            if (p['resumeUrl'] != null) _resumeUrl = p['resumeUrl'].toString();
            if (p['photo'] != null) _photoUrl = p['photo'].toString();
            if (p['status'] != null && p['status'].toString().isNotEmpty) {
              _status = p['status'].toString();
            }
            if (p['education'] is List) {
              _education = (p['education'] as List)
                  .whereType<Map<String, dynamic>>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();
            }
          });
        }
      }
    } catch (_) {}

    _fetchLatestProfile();
  }

  Future<void> _fetchLatestProfile() async {
    setState(() => _isLoading = true);
    try {
      final p = await _apiService.getProfile();
      if (!mounted) return;

      // Finding 8 Fix: Avoid overwriting user text fields if actively editing.
      if (_isEditing) {
        if (p['skills'] is List) {
          _skills = (p['skills'] as List).map((e) => e.toString()).toList();
        }
        _resumeUrl = (p['resumeUrl'] ?? p['resume'] ?? _resumeUrl).toString();
        _photoUrl = (p['photo'] ?? _photoUrl).toString();
        _status = (p['status'] ?? _status).toString();
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        final fetchedName = (p['fullName'] ?? p['name'] ?? '').toString();
        if (fetchedName.isNotEmpty) {
          _fullNameController.text = fetchedName;
        }
        if ((p['email'] ?? '').toString().isNotEmpty) {
          _emailController.text = p['email'].toString();
        }
        _phoneController.text = (p['phone'] ?? '').toString();
        _collegeController.text = (p['college'] ?? '').toString();
        _branchController.text = (p['branch'] ?? '').toString();
        _semesterController.text = (p['semester'] != null && p['semester'] != 0) ? p['semester'].toString() : '';
        _locationController.text = (p['location'] ?? '').toString();
        _bioController.text = (p['bio'] ?? '').toString();
        _githubController.text = (p['github'] ?? '').toString();
        _linkedInController.text = (p['linkedIn'] ?? '').toString();
        _portfolioController.text = (p['portfolio'] ?? '').toString();

        if (p['skills'] is List) {
          _skills = (p['skills'] as List).map((e) => e.toString()).toList();
        }
        _resumeUrl = (p['resumeUrl'] ?? p['resume'] ?? '').toString();
        _photoUrl = (p['photo'] ?? '').toString();
        _status = (p['status'] ?? 'Active').toString();
        if (p['education'] is List) {
          _education = (p['education'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        _isLoading = false;
      });

      // Sync to local disk cache
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_student_profile', jsonEncode(p));
      } catch (_) {}
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }

    // Fetch earned certificate count independently. Safe: returns 0 on failure.
    final certCount = await _apiService.getEarnedCertificatesCount();
    if (mounted) {
      setState(() => _earnedCerts = certCount);
    }
  }

  // Finding 5 Fixes: Input Validation
  String? _validateName(String value) {
    if (value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Full name must be at least 2 characters';
    return null;
  }

  String? _validatePhone(String value) {
    final t = value.trim();
    if (t.isEmpty) return null;
    if (!RegExp(r'^[+]?[\d\s()\-]{7,16}$').hasMatch(t)) {
      return 'Enter a valid phone number (7-16 digits)';
    }
    return null;
  }

  String? _validateSemester(String value) {
    final t = value.trim();
    if (t.isEmpty) return null;
    final n = int.tryParse(t);
    if (n == null || n < 1 || n > 12) {
      return 'Semester must be a number between 1 and 12';
    }
    return null;
  }

  /// Resolves relative URLs (e.g. /uploads/...) to full absolute URIs.
  Uri _resolveUri(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Uri.parse(value);
    }
    final root = ApiEndpoints.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    final path = value.startsWith('/') ? value : '/$value';
    return Uri.parse('$root$path');
  }

  // Finding 1 & 5 Fix: Strict validation and true error handling
  Future<void> _saveProfile() async {
    final nameValue = _fullNameController.text.trim();
    final nameError = _validateName(nameValue);
    final phoneError = _validatePhone(_phoneController.text);
    final semesterError = _validateSemester(_semesterController.text);
    final firstError = nameError ?? phoneError ?? semesterError;

    if (firstError != null) {
      HapticFeedback.vibrate();
      setState(() {
        _isSaving = false;
        _formError = firstError;
      });
      _showSnack(firstError, isError: true);
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isSaving = true;
      _formError = '';
    });

    final semester = int.tryParse(_semesterController.text.trim()) ?? 0;
    final payload = {
      'name': nameValue,
      'fullName': nameValue,
      'phone': _phoneController.text.trim(),
      'college': _collegeController.text.trim(),
      'branch': _branchController.text.trim(),
      'semester': semester,
      'location': _locationController.text.trim(),
      'bio': _bioController.text.trim(),
      'github': _githubController.text.trim(),
      'linkedIn': _linkedInController.text.trim(),
      'portfolio': _portfolioController.text.trim(),
      'skills': _skills,
      'resumeUrl': _resumeUrl,
      'resume': _resumeUrl,
      'photo': _photoUrl,
      'education': _education,
    };

    try {
      final saved = await _apiService.updateProfile(payload);

      // Persist display name for dashboard header
      try {
        const storage = FlutterSecureStorage();
        await storage.write(key: 'user_name', value: nameValue);
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _isEditing = false;
        _formError = '';
        if (saved['photo'] != null && saved['photo'].toString().isNotEmpty) {
          _photoUrl = saved['photo'].toString();
        }
      });

      try {
        context.read<StudentDashboardBloc>().add(RefreshStudentDashboardEvent());
      } catch (_) {}

      _showSnack('Profile updated successfully');
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : 'Could not save profile changes. Please try again.';
      setState(() {
        _isSaving = false;
        _isEditing = true; // Keep edit mode on failure so user doesn't lose inputs!
        _formError = message;
      });
      _showSnack(message, isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? LucideIcons.alertTriangle : LucideIcons.checkCircle2,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: Duration(seconds: isError ? 4 : 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Finding 4 Fix: Functional photo upload
  Future<void> _pickAndUploadPhoto() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty || result.files.single.path == null) {
        return;
      }

      final file = result.files.single;
      HapticFeedback.mediumImpact();
      setState(() => _isUploadingPhoto = true);

      final saved = await _apiService.uploadPhotoFile(file.path!, file.name);
      if (!mounted) return;

      setState(() {
        _isUploadingPhoto = false;
        _photoUrl = (saved['photo'] ?? _photoUrl).toString();
      });

      try {
        context.read<StudentDashboardBloc>().add(RefreshStudentDashboardEvent());
      } catch (_) {}

      _showSnack('Profile photo updated successfully');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      String message = e is ApiException ? e.message : 'Could not upload photo';
      if (message.contains('404') || message.contains('Not Found')) {
        message = 'Photo upload API is not configured in backend yet.';
      }
      _showSnack(message, isError: true);
    }
  }

  // Finding 3 Fix: Functional PDF file upload
  Future<void> _uploadResume() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty || result.files.single.path == null) {
        return;
      }

      final file = result.files.single;
      HapticFeedback.mediumImpact();
      setState(() => _isUploadingResume = true);

      final saved = await _apiService.uploadResumeFile(file.path!, file.name);
      if (!mounted) return;

      setState(() {
        _isUploadingResume = false;
        _resumeUrl = (saved['resumeUrl'] ?? saved['resume'] ?? _resumeUrl).toString();
      });

      _showSnack('Resume uploaded and attached to profile!');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingResume = false);
      String message = e is ApiException ? e.message : 'Could not upload resume';
      if (message.contains('404') || message.contains('Not Found')) {
        message = 'Resume file upload API is not configured in backend. Please use "Save Link" to attach a resume URL.';
      }
      _showSnack(message, isError: true);
    }
  }

  // Finding 3 Fix: Real url_launcher opening
  Future<void> _openResume() async {
    if (_resumeUrl.isEmpty) {
      _showSnack('No resume uploaded yet', isError: true);
      return;
    }
    try {
      final uri = _resolveUri(_resumeUrl);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        _showSnack('Could not launch resume link: $_resumeUrl', isError: true);
      }
    } catch (_) {
      _showSnack('Could not open the resume link', isError: true);
    }
  }

  void _addSkill() {
    final s = _newSkillController.text.trim();
    if (s.isNotEmpty && !_skills.contains(s)) {
      setState(() {
        _skills.add(s);
        _newSkillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  bool get _isActiveStatus => _status.toLowerCase() == 'active';

  void _removeEducation(int index) {
    setState(() {
      _education.removeAt(index);
    });
  }

  String _educationYearsText(Map<String, dynamic> e) {
    final start = (e['startYear'] ?? '').toString();
    final end = (e['endYear'] ?? '').toString();
    final grade = (e['grade'] ?? '').toString();
    final parts = <String>[
      if (start.isNotEmpty || end.isNotEmpty)
        '$start${end.isNotEmpty ? ' - $end' : ''}',
      if (grade.isNotEmpty) 'Grade: $grade',
    ];
    return parts.join('  •  ');
  }

  void _showAddEducationDialog() {
    final degreeC = TextEditingController();
    final instC = TextEditingController();
    final fieldC = TextEditingController();
    final startC = TextEditingController();
    final endC = TextEditingController();
    final gradeC = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Education', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogTextField(degreeC, 'Degree (e.g. B.Tech)', TextInputType.text),
                _dialogTextField(instC, 'Institution / College', TextInputType.text),
                _dialogTextField(fieldC, 'Field of study (e.g. CSE)', TextInputType.text),
                Row(
                  children: [
                    Expanded(child: _dialogTextField(startC, 'Start year', TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: _dialogTextField(endC, 'End year', TextInputType.number)),
                  ],
                ),
                _dialogTextField(gradeC, 'Grade / CGPA (optional)', TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final entry = <String, dynamic>{
                  'degree': degreeC.text.trim(),
                  'institution': instC.text.trim(),
                  'fieldOfStudy': fieldC.text.trim(),
                  'startYear': int.tryParse(startC.text.trim()),
                  'endYear': int.tryParse(endC.text.trim()),
                  'grade': gradeC.text.trim(),
                };
                Navigator.pop(dialogContext);
                setState(() {
                  _education.add(entry);
                });
              },
              child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogTextField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.inputFill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }

  void _showResumeUploadDialog(BuildContext context) {
    final urlController = TextEditingController(text: _resumeUrl);
    showDialog(
      context: context,
      builder: (dialogContext) {
        final screenSize = MediaQuery.sizeOf(dialogContext);
        final keyboardInset = MediaQuery.viewInsetsOf(dialogContext).bottom;
        final maxContentHeight = (screenSize.height * 0.55 - keyboardInset * 0.2).clamp(200.0, 480.0);

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          title: Row(
            children: [
              const Icon(LucideIcons.fileText, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: AutoSizeText(
                  'Upload / Update Resume',
                  maxLines: 1,
                  minFontSize: 12,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxContentHeight,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _uploadResume();
                      },
                      icon: const Icon(LucideIcons.paperclip, size: 16, color: Colors.white),
                      label: const Text('Choose PDF / Document File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('OR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter a PDF document link or web URL:',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: urlController,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'https://c2c.edu/resumes/my_resume.pdf',
                      hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final newUrl = urlController.text.trim();
                Navigator.pop(dialogContext);

                if (newUrl.isEmpty) {
                  _showSnack('Enter a resume URL or file name', isError: true);
                  return;
                }

                setState(() {
                  _resumeUrl = newUrl;
                });

                final payload = {
                  'resumeUrl': newUrl,
                  'resume': newUrl,
                };
                try {
                  await _apiService.updateProfile(payload);
                  _showSnack('Resume link saved to profile');
                } catch (e) {
                  final message = e is ApiException ? e.message : 'Could not save resume link';
                  if (mounted) _showSnack(message, isError: true);
                }
              },
              icon: const Icon(LucideIcons.link, size: 16, color: Colors.white),
              label: const Text('Save Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final nameText = _fullNameController.text.trim().isNotEmpty ? _fullNameController.text.trim() : 'Student';
    final initial = nameText.isNotEmpty ? nameText[0].toUpperCase() : 'S';
    final branchText = _branchController.text.trim();
    final semText = _semesterController.text.trim();
    final academicSub = (branchText.isNotEmpty || semText.isNotEmpty)
        ? [branchText, semText.isNotEmpty ? 'Semester $semText' : ''].where((s) => s.isNotEmpty).join(' • ')
        : 'Academic details not added';

    return SingleChildScrollView(
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
          // 1. HERO PROFILE CARD matching Figma Image 100%
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Cover Banner Gradient
                Container(
                  height: 90,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1D4ED8), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                ),

                // Avatar Box overlapping Cover Banner
                Transform.translate(
                  offset: const Offset(0, -42),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Finding 4 Fix: Functional Photo Edit Trigger
                        GestureDetector(
                          onTap: _pickAndUploadPhoto,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white, width: 3.5),
                                  image: _photoUrl.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(_resolveUri(_photoUrl).toString()),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: _isUploadingPhoto
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                      )
                                    : (_photoUrl.isEmpty
                                        ? Text(
                                            initial,
                                            style: const TextStyle(
                                              fontSize: 34,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          )
                                        : null),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.camera,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Name & Active Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: AutoSizeText(
                                nameText,
                                maxLines: 1,
                                minFontSize: 14,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _isActiveStatus
                                    ? const Color(0xFFE0F2FE)
                                    : AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: _isActiveStatus
                                      ? const Color(0xFF0284C7)
                                      : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          academicSub,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Form level error message if any
                        if (_formError.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.alertTriangle, size: 14, color: AppColors.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formError,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Edit / Save Profile Action Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppColors.border, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: _isEditing ? AppColors.primary : AppColors.surface,
                            ),
                            onPressed: () {
                              if (_isEditing) {
                                _saveProfile();
                              } else {
                                HapticFeedback.lightImpact();
                                setState(() => _isEditing = true);
                              }
                            },
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    _isEditing ? LucideIcons.check : LucideIcons.pencil,
                                    size: 16,
                                    color: _isEditing ? Colors.white : AppColors.textPrimary,
                                  ),
                            label: Text(
                              _isSaving
                                  ? 'Saving...'
                                  : (_isEditing ? 'Save profile' : 'Edit profile'),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: _isEditing ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. STAT CARDS ROW (Skills, Education, Certifications)
          Row(
            children: [
              _buildStatCard(
                icon: LucideIcons.shield,
                iconColor: const Color(0xFF0EA5E9),
                count: _skills.length,
                label: 'Skills',
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                icon: LucideIcons.graduationCap,
                iconColor: const Color(0xFF6366F1),
                count: _education.length,
                label: 'Education',
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                icon: LucideIcons.award,
                iconColor: const Color(0xFFF59E0B),
                count: _earnedCerts,
                label: 'Certifications',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. ACCOUNT CARD - Personal Information matching Figma
          _buildSectionCard(
            eyebrow: 'ACCOUNT',
            title: 'Personal information',
            icon: LucideIcons.userCheck,
            iconColor: const Color(0xFF2563EB),
            children: [
              _buildInputField(
                controller: _fullNameController,
                label: 'Full Name *',
                icon: LucideIcons.userCheck,
                enabled: _isEditing,
              ),
              _buildInputField(
                controller: _emailController,
                label: 'Email Address (Account ID)',
                icon: LucideIcons.mail,
                enabled: false,
              ),
              // Finding 7 Fix: Email Explanatory Note
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: const [
                    Icon(LucideIcons.lock, size: 13, color: AppColors.textMuted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Email is linked to your account authentication and cannot be edited directly.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              _buildInputField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: LucideIcons.phone,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              _buildInputField(
                controller: _collegeController,
                label: 'College',
                icon: LucideIcons.graduationCap,
                enabled: _isEditing,
              ),
              _buildInputField(
                controller: _branchController,
                label: 'Branch',
                icon: LucideIcons.bookOpen,
                enabled: _isEditing,
              ),
              _buildInputField(
                controller: _semesterController,
                label: 'Current Semester (1-12)',
                icon: LucideIcons.calendar,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
              ),
              _buildInputField(
                controller: _locationController,
                label: 'Location',
                icon: LucideIcons.building,
                enabled: _isEditing,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3.5 EDUCATION CARD - backend education[] entries
          _buildSectionCard(
            eyebrow: 'ACADEMICS',
            title: 'Education',
            icon: LucideIcons.graduationCap,
            iconColor: const Color(0xFF6366F1),
            children: [
              if (_education.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: Text(
                      'No education added yet',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                )
              else
                ..._education.asMap().entries.map((entry) {
                  final e = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  [e['degree'], e['fieldOfStudy']]
                                      .where((x) => (x?.toString() ?? '').isNotEmpty)
                                      .join(' · '),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if ((e['institution'] ?? '').toString().isNotEmpty)
                                  Text(
                                    e['institution'].toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  _educationYearsText(e),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isEditing)
                            IconButton(
                              icon: const Icon(
                                LucideIcons.trash2,
                                size: 16,
                                color: AppColors.error,
                              ),
                              onPressed: () => _removeEducation(entry.key),
                              tooltip: 'Remove education',
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _showAddEducationDialog,
                    icon: const Icon(LucideIcons.plus, size: 15, color: AppColors.primary),
                    label: const Text(
                      'Add education',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. EXPERTISE CARD - Skills matching Figma
          _buildSectionCard(
            eyebrow: 'EXPERTISE',
            title: 'Skills',
            icon: LucideIcons.sparkles,
            iconColor: const Color(0xFF10B981),
            children: [
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newSkillController,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Add a skill (e.g. Flutter, Node.js)',
                            hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.inputFill,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          onSubmitted: (_) => _addSkill(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onPressed: _addSkill,
                        child: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              if (_skills.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      'No skills added yet',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            skill,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          if (_isEditing) ...[
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _removeSkill(skill),
                              child: const Icon(
                                LucideIcons.x,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. SUMMARY CARD - About Me matching Figma
          _buildSectionCard(
            eyebrow: 'SUMMARY',
            title: 'About me',
            icon: LucideIcons.messageSquare,
            iconColor: const Color(0xFF8B5CF6),
            children: [
              TextField(
                controller: _bioController,
                enabled: _isEditing,
                maxLines: 3,
                style: TextStyle(
                  fontSize: 13,
                  color: _isEditing ? AppColors.textPrimary : AppColors.textSecondary,
                ),
                decoration: InputDecoration(
                  hintText: 'Tell recruiters about your background, career goals, and interests...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  filled: true,
                  fillColor: _isEditing ? AppColors.surface : AppColors.inputFill,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 6. PRESENCE CARD - Social & Links matching Figma
          _buildSectionCard(
            eyebrow: 'PRESENCE',
            title: 'Social & links',
            icon: LucideIcons.link,
            iconColor: const Color(0xFFF59E0B),
            children: [
              _buildInputField(
                controller: _githubController,
                label: 'GitHub',
                icon: LucideIcons.github,
                enabled: _isEditing,
              ),
              _buildInputField(
                controller: _linkedInController,
                label: 'LinkedIn',
                icon: LucideIcons.linkedin,
                enabled: _isEditing,
              ),
              _buildInputField(
                controller: _portfolioController,
                label: 'Portfolio',
                icon: LucideIcons.globe,
                enabled: _isEditing,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7. DOCUMENTS CARD - Resume matching Figma
          _buildSectionCard(
            eyebrow: 'DOCUMENTS',
            title: 'Resume',
            icon: LucideIcons.fileText,
            iconColor: const Color(0xFFEF4444),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: _isUploadingResume
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                            )
                          : const Icon(
                              LucideIcons.fileText,
                              color: AppColors.primary,
                              size: 24,
                            ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _resumeUrl.isNotEmpty ? _resumeUrl.split('/').last : 'No resume uploaded',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Add a resume link or file to apply to placement drives',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                            ),
                            onPressed: _openResume,
                            icon: const Icon(LucideIcons.externalLink, size: 14, color: AppColors.primary),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'View / Download',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                              elevation: 0,
                            ),
                            onPressed: () => _showResumeUploadDialog(context),
                            icon: const Icon(LucideIcons.upload, size: 14, color: Colors.white),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Replace / Upload',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required int count,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            AutoSizeText(
              label,
              maxLines: 1,
              minFontSize: 8,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String eyebrow,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? AppColors.surface : AppColors.inputFill,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
