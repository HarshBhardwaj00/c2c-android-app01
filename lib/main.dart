import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/routes/app_router.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/student/bloc/student_bloc.dart';
import 'features/college/bloc/college_bloc.dart';
import 'features/admin/bloc/admin_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Unlock 90Hz/120Hz High Refresh Rate on supported devices
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (e) {
    debugPrint('High refresh rate setup skipped: $e');
  }

  await ThemeController.instance.load();

  runApp(const C2CApp());
}

class C2CApp extends StatelessWidget {
  const C2CApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<StudentBloc>(create: (context) => StudentBloc()),
        BlocProvider<CollegeBloc>(create: (context) => CollegeBloc()),
        BlocProvider<AdminBloc>(create: (context) => AdminBloc()),
      ],
      child: ListenableBuilder(
        listenable: ThemeController.instance,
        builder: (context, _) => MaterialApp.router(
          title: 'Campus2Corporate',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeController.instance.mode,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
