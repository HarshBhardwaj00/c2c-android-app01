import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/student_bloc.dart';
import 'student_notifications_page.dart';

class StudentAlertsView extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final VoidCallback? onBackPressed;

  const StudentAlertsView({
    super.key,
    required this.notifications,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return StudentNotificationsPage(
      initialNotifications: notifications,
      onBackPressed: onBackPressed ??
          () {
            context.read<StudentDashboardBloc>().add(ChangeStudentTabEvent(0));
          },
    );
  }
}
