import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/models/college_student_model.dart';
import '../data/services/student_directory_api_service.dart';

abstract class StudentDirectoryEvent {}

class FetchStudentsEvent extends StudentDirectoryEvent {
  final String query;
  final String department;

  FetchStudentsEvent({this.query = '', this.department = 'All'});
}

abstract class StudentDirectoryState {}

class StudentDirectoryInitial extends StudentDirectoryState {}

class StudentDirectoryLoading extends StudentDirectoryState {}

class StudentDirectoryLoaded extends StudentDirectoryState {
  final List<CollegeStudentModel> students;
  final String selectedDepartment;
  final String searchQuery;

  StudentDirectoryLoaded({
    required this.students,
    required this.selectedDepartment,
    required this.searchQuery,
  });
}

class StudentDirectoryError extends StudentDirectoryState {
  final String message;

  StudentDirectoryError({required this.message});
}

class StudentDirectoryBloc extends Bloc<StudentDirectoryEvent, StudentDirectoryState> {
  final StudentDirectoryApiService _apiService;

  StudentDirectoryBloc({StudentDirectoryApiService? apiService})
      : _apiService = apiService ?? StudentDirectoryApiService(),
        super(StudentDirectoryInitial()) {
    on<FetchStudentsEvent>(_onFetchStudents);
  }

  Future<void> _onFetchStudents(
    FetchStudentsEvent event,
    Emitter<StudentDirectoryState> emit,
  ) async {
    emit(StudentDirectoryLoading());
    try {
      final students = await _apiService.fetchStudents(
        query: event.query,
        department: event.department,
      );
      emit(StudentDirectoryLoaded(
        students: students,
        selectedDepartment: event.department,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(StudentDirectoryError(message: 'Failed to load students.'));
    }
  }
}
