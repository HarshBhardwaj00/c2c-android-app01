import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/student_api_service.dart';
import '../domain/models/student_dashboard_model.dart';

// --- Events ---
abstract class StudentDashboardEvent {}

class LoadStudentDashboardEvent extends StudentDashboardEvent {}

class RefreshStudentDashboardEvent extends StudentDashboardEvent {}

class ChangeStudentTabEvent extends StudentDashboardEvent {
  final int newTab;
  ChangeStudentTabEvent(this.newTab);
}

// --- States ---
abstract class StudentDashboardState {
  final int activeTab;
  const StudentDashboardState({this.activeTab = 0});
}

class StudentDashboardInitialState extends StudentDashboardState {
  const StudentDashboardInitialState({super.activeTab});
}

class StudentDashboardLoadingState extends StudentDashboardState {
  const StudentDashboardLoadingState({super.activeTab});
}

class StudentDashboardLoadedState extends StudentDashboardState {
  final StudentDashboardModel data;
  final List<Map<String, dynamic>> notifications;
  final List<Map<String, dynamic>> projects;

  const StudentDashboardLoadedState({
    required this.data,
    required this.notifications,
    required this.projects,
    super.activeTab,
  });

  StudentDashboardLoadedState copyWith({
    StudentDashboardModel? data,
    List<Map<String, dynamic>>? notifications,
    List<Map<String, dynamic>>? projects,
    int? activeTab,
  }) {
    return StudentDashboardLoadedState(
      data: data ?? this.data,
      notifications: notifications ?? this.notifications,
      projects: projects ?? this.projects,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

class StudentDashboardErrorState extends StudentDashboardState {
  final String message;
  const StudentDashboardErrorState(this.message, {super.activeTab});
}

// --- Bloc ---
typedef StudentBloc = StudentDashboardBloc;

class StudentDashboardBloc
    extends Bloc<StudentDashboardEvent, StudentDashboardState> {
  final StudentApiService apiService;

  StudentDashboardBloc({StudentApiService? apiService})
      : apiService = apiService ?? StudentApiService(),
        super(const StudentDashboardInitialState()) {
    on<LoadStudentDashboardEvent>(_onLoadDashboard);
    on<RefreshStudentDashboardEvent>(_onRefreshDashboard);
    on<ChangeStudentTabEvent>(_onChangeTab);
  }

  Future<void> _onLoadDashboard(
    LoadStudentDashboardEvent event,
    Emitter<StudentDashboardState> emit,
  ) async {
    emit(StudentDashboardLoadingState(activeTab: state.activeTab));
    try {
      final dashboardData = await apiService.getStudentDashboard();
      final notifications = await apiService.getNotifications();
      final projects = await apiService.getProjects();

      emit(
        StudentDashboardLoadedState(
          data: dashboardData,
          notifications: notifications,
          projects: projects,
          activeTab: state.activeTab,
        ),
      );
    } catch (e) {
      emit(
        StudentDashboardErrorState(
          'Failed to load dashboard: ${e.toString()}',
          activeTab: state.activeTab,
        ),
      );
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshStudentDashboardEvent event,
    Emitter<StudentDashboardState> emit,
  ) async {
    try {
      final dashboardData = await apiService.getStudentDashboard();
      final notifications = await apiService.getNotifications();
      final projects = await apiService.getProjects();

      emit(
        StudentDashboardLoadedState(
          data: dashboardData,
          notifications: notifications,
          projects: projects,
          activeTab: state.activeTab,
        ),
      );
    } catch (_) {
      // Keep existing loaded state on silent refresh failure
    }
  }

  void _onChangeTab(
    ChangeStudentTabEvent event,
    Emitter<StudentDashboardState> emit,
  ) {
    if (state is StudentDashboardLoadedState) {
      final current = state as StudentDashboardLoadedState;
      emit(current.copyWith(activeTab: event.newTab));
    } else {
      emit(StudentDashboardLoadingState(activeTab: event.newTab));
      add(LoadStudentDashboardEvent());
    }
  }
}
