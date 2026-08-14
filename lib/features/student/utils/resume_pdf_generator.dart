import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';

class ResumePdfGenerator {
  static Future<Uint8List> generateResumePdf({
    required String fullName,
    required String headline,
    required String email,
    required String phone,
    required String location,
    required String linkedin,
    required String github,
    required String summary,
    required List<String> skills,
    required List<Map<String, String>> experience,
    required List<Map<String, String>> education,
    required List<Map<String, String>> certifications,
    String template = 'modern',
  }) async {
    final pdf = pw.Document();

    final primaryColor = template == 'modern'
        ? PdfColor.fromHex('#4F46E5')
        : (template == 'technical' ? PdfColor.fromHex('#0F172A') : PdfColor.fromHex('#1E293B'));

    final textColor = PdfColor.fromHex('#0F172A');
    final mutedColor = PdfColor.fromHex('#64748B');
    final borderColor = PdfColor.fromHex('#E2E8F0');

    final contactItems = [
      email.trim(),
      phone.trim(),
      location.trim(),
      linkedin.trim(),
      github.trim(),
    ].where((s) => s.isNotEmpty).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // 1. Header (Name, Title, Contacts)
            pw.Header(
              level: 0,
              decoration: const pw.BoxDecoration(border: pw.Border()),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    fullName.isNotEmpty ? fullName : 'Your Full Name',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  if (headline.isNotEmpty) ...[
                    pw.SizedBox(height: 3),
                    pw.Text(
                      headline,
                      style: pw.TextStyle(
                        fontSize: 13,
                        color: mutedColor,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                  if (contactItems.isNotEmpty) ...[
                    pw.SizedBox(height: 6),
                    pw.Text(
                      contactItems.join('  •  '),
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        color: mutedColor,
                      ),
                    ),
                  ],
                  pw.SizedBox(height: 10),
                  pw.Divider(color: borderColor, thickness: 1),
                  pw.SizedBox(height: 8),
                ],
              ),
            ),

            // 2. Professional Summary
            if (summary.trim().isNotEmpty) ...[
              _buildPdfSectionHeader('PROFESSIONAL SUMMARY', primaryColor),
              pw.SizedBox(height: 4),
              pw.Text(
                summary.trim(),
                style: pw.TextStyle(
                  fontSize: 10,
                  color: textColor,
                  lineSpacing: 1.4,
                ),
              ),
              pw.SizedBox(height: 14),
            ],

            // 3. Technical & Professional Skills
            if (skills.isNotEmpty) ...[
              _buildPdfSectionHeader('SKILLS & EXPERTISE', primaryColor),
              pw.SizedBox(height: 6),
              pw.Wrap(
                spacing: 6,
                runSpacing: 4,
                children: skills.map((skill) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F1F5F9'),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      border: pw.Border.all(color: borderColor, width: 0.5),
                    ),
                    child: pw.Text(
                      skill,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              pw.SizedBox(height: 14),
            ],

            // 4. Professional Experience & Projects
            if (experience.isNotEmpty) ...[
              _buildPdfSectionHeader('WORK EXPERIENCE & PROJECTS', primaryColor),
              pw.SizedBox(height: 6),
              ...experience.map((exp) {
                final role = exp['role'] ?? '';
                final company = exp['company'] ?? '';
                final duration = exp['duration'] ?? '';
                final details = exp['description'] ?? '';

                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            role,
                            style: pw.TextStyle(
                              fontSize: 10.5,
                              fontWeight: pw.FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          pw.Text(
                            duration,
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                      if (company.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          company,
                          style: pw.TextStyle(
                            fontSize: 9.5,
                            color: primaryColor,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                      if (details.isNotEmpty) ...[
                        pw.SizedBox(height: 3),
                        pw.Text(
                          details,
                          style: pw.TextStyle(
                            fontSize: 9.5,
                            color: textColor,
                            lineSpacing: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 8),
            ],

            // 5. Education
            if (education.isNotEmpty) ...[
              _buildPdfSectionHeader('EDUCATION', primaryColor),
              pw.SizedBox(height: 6),
              ...education.map((edu) {
                final degree = edu['degree'] ?? '';
                final school = edu['school'] ?? '';
                final year = edu['year'] ?? '';
                final grade = edu['grade'] ?? '';

                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              degree,
                              style: pw.TextStyle(
                                fontSize: 10.5,
                                fontWeight: pw.FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              school,
                              style: pw.TextStyle(
                                fontSize: 9.5,
                                color: mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          if (year.isNotEmpty)
                            pw.Text(
                              year,
                              style: pw.TextStyle(
                                fontSize: 9,
                                color: mutedColor,
                              ),
                            ),
                          if (grade.isNotEmpty)
                            pw.Text(
                              grade,
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 8),
            ],

            // 6. Certifications
            if (certifications.isNotEmpty) ...[
              _buildPdfSectionHeader('CERTIFICATIONS & HONORS', primaryColor),
              pw.SizedBox(height: 6),
              ...certifications.map((cert) {
                final name = cert['name'] ?? '';
                final issuer = cert['issuer'] ?? '';
                final year = cert['year'] ?? '';

                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          issuer.isNotEmpty ? '$name ($issuer)' : name,
                          style: pw.TextStyle(
                            fontSize: 9.5,
                            color: textColor,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      if (year.isNotEmpty)
                        pw.Text(
                          year,
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: mutedColor,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfSectionHeader(String title, PdfColor color) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 4),
      padding: const pw.EdgeInsets.only(bottom: 3),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: color, width: 1.5),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: color,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  /// Triggers full download flow: Saves PDF to device disk, shows options modal, and enables instant Open & Share
  static Future<void> exportResumePdf({
    required BuildContext context,
    required String fullName,
    required String headline,
    required String email,
    required String phone,
    required String location,
    required String linkedin,
    required String github,
    required String summary,
    required List<String> skills,
    required List<Map<String, String>> experience,
    required List<Map<String, String>> education,
    required List<Map<String, String>> certifications,
    String template = 'modern',
  }) async {
    final pdfBytes = await generateResumePdf(
      fullName: fullName,
      headline: headline,
      email: email,
      phone: phone,
      location: location,
      linkedin: linkedin,
      github: github,
      summary: summary,
      skills: skills,
      experience: experience,
      education: education,
      certifications: certifications,
      template: template,
    );

    final cleanName = fullName.trim().isEmpty ? 'Student' : fullName.trim().replaceAll(' ', '_');
    final cleanFileName = '${cleanName}_Resume.pdf';

    // 1. Save locally to device storage
    File? savedFile;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$cleanFileName');
      await file.writeAsBytes(pdfBytes, flush: true);
      savedFile = file;
    } catch (_) {
      try {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$cleanFileName');
        await file.writeAsBytes(pdfBytes, flush: true);
        savedFile = file;
      } catch (_) {}
    }

    if (!context.mounted) return;

    // Show floating snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Resume PDF generated successfully! ($cleanFileName)'),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        action: savedFile != null
            ? SnackBarAction(
                label: 'OPEN',
                textColor: Colors.white,
                onPressed: () => OpenFilex.open(savedFile!.path),
              )
            : null,
      ),
    );

    // 2. Present user with instant Open / Share / Print sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: context.brdr),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.priLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.fileCheck, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resume PDF Downloaded!',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: context.txtPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cleanFileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: context.txtSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(height: 1, color: context.brdr),
              const SizedBox(height: 14),

              // Option 1: Open PDF File directly
              if (savedFile != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.eye, color: Color(0xFF2563EB), size: 20),
                  ),
                  title: Text(
                    'Open PDF File',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.txtPrimary),
                  ),
                  subtitle: Text(
                    'View in your device PDF viewer',
                    style: TextStyle(fontSize: 12, color: context.txtSecondary),
                  ),
                  trailing: const Icon(LucideIcons.chevronRight, size: 16),
                  onTap: () async {
                    Navigator.pop(modalCtx);
                    await OpenFilex.open(savedFile!.path);
                  },
                ),

              // Option 2: Share / Save to Drive / WhatsApp / Files
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.share2, color: Color(0xFF16A34A), size: 20),
                ),
                title: Text(
                  'Share / Save to Files',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.txtPrimary),
                ),
                subtitle: Text(
                  'Save to Drive, WhatsApp, or File Manager',
                  style: TextStyle(fontSize: 12, color: context.txtSecondary),
                ),
                trailing: const Icon(LucideIcons.chevronRight, size: 16),
                onTap: () async {
                  Navigator.pop(modalCtx);
                  await Printing.sharePdf(bytes: pdfBytes, filename: cleanFileName);
                },
              ),

              // Option 3: System Print / Spooler
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.printer, color: Color(0xFF9333EA), size: 20),
                ),
                title: Text(
                  'Print / System Dialog',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.txtPrimary),
                ),
                subtitle: Text(
                  'Open Android system print manager',
                  style: TextStyle(fontSize: 12, color: context.txtSecondary),
                ),
                trailing: const Icon(LucideIcons.chevronRight, size: 16),
                onTap: () async {
                  Navigator.pop(modalCtx);
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdfBytes,
                    name: cleanFileName,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
