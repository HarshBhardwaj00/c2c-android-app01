import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/models/college_student_model.dart';
import '../data/services/student_directory_api_service.dart';

abstract class StudentDirectoryEvent {}

class FetchStudentsEvent extends StudentDirectoryEvent {
  final String query;
  final String department;
  final bool isSilent;

  FetchStudentsEvent({this.query = '', this.department = 'All', this.isSilent = false});
}

class CreateStudentEvent extends StudentDirectoryEvent {
  final Map<String, dynamic> studentData;

  CreateStudentEvent({required this.studentData});
}

class UpdateStudentEvent extends StudentDirectoryEvent {
  final String id;
  final Map<String, dynamic> studentData;

  UpdateStudentEvent({required this.id, required this.studentData});
}

class DeleteStudentEvent extends StudentDirectoryEvent {
  final String id;

  DeleteStudentEvent({required this.id});
}

class FetchEligibleStudentsEvent extends StudentDirectoryEvent {}

abstract class StudentDirectoryState {}

class StudentDirectoryInitial extends StudentDirectoryState {}

class StudentDirectoryLoading extends StudentDirectoryState {}

class StudentDirectoryLoaded extends StudentDirectoryState {
  final List<CollegeStudentModel> students;
  final String selectedDepartment;
  final String searchQuery;
  final String? successMessage;

  StudentDirectoryLoaded({
    required this.students,
    required this.selectedDepartment,
    required this.searchQuery,
    this.successMessage,
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
    on<CreateStudentEvent>(_onCreateStudent);
    on<UpdateStudentEvent>(_onUpdateStudent);
    on<DeleteStudentEvent>(_onDeleteStudent);
    on<FetchEligibleStudentsEvent>(_onFetchEligibleStudents);
  }

  Future<void> _onFetchStudents(
    FetchStudentsEvent event,
    Emitter<StudentDirectoryState> emit,
  ) async {
    if (!event.isSilent && state is! StudentDirectoryLoaded) {
      emit(StudentDirectoryLoading());
    }
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
      emit(StudentDirectoryError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateStudent(
    CreateStudentEvent event,
    Emitter<StudentDirectoryState> emit,
  ) async {
    try {
      final created = await _apiService.createStudent(event.studentData);
      final currentList = state is StudentDirectoryLoaded
          ? List<CollegeStudentModel>.from((state as StudentDirectoryLoaded).students)
          : <CollegeStudentModel>[];
      currentList.insert(0, created);

      emit(StudentDirectoryLoaded(
        students: currentList,
        selectedDepartment: state is StudentDirectoryLoaded ? (state as StudentDirectoryLoaded).selectedDepartment : 'All',
        searchQuery: state is StudentDirectoryLoaded ? (state as StudentDirectoryLoaded).searchQuery : '',
        successMessage: 'Student "${created.name}" registered successfully!',
      ));
    } catch (e) {
      emit(StudentDirectoryError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateStudent(
    UpdateStudentEvent event,
    Emitter<StudentDirectoryState> emit,
  ) async {
    try {
      final updated = await _apiService.updateStudent(event.id, event.studentData);
      if (state is StudentDirectoryLoaded) {
        final currentList = List<CollegeStudentModel>.from((state as StudentDirectoryLoaded).students);
        final index = currentList.indexWhere((s) => s.id == event.id);
        if (index != -1) {
          currentList[index] = updated;
        }
        emit(StudentDirectoryLoaded(
          students: currentList,
          selectedDepartment: (state as StudentDirectoryLoaded).selectedDepartment,
          searchQuery: (state as StudentDirectoryLoaded).searchQuery,
          successMessage: 'Student "${updated.name}" updated successfully!',
        ));
      } else {
        add(FetchStudentsEvent());
      }
    } catch (e) {
      emit(StudentDirectoryError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteStudent(
    DeleteStudentEvent event,
    Emitter<StudentDirectoryState> emit,
  ) async {
    try {
      await _apiService.deleteStudent(event.id);
      if (state is StudentDirectoryLoaded) {
        final currentList = List<CollegeStudentModel>.from((state as StudentDirectoryLoaded).students)
          ..removeWhere((s) => s.id == event.id);
        emit(StudentDirectoryLoaded(
          students: currentList,
          selectedDepartment: (state as StudentDirectoryLoaded).selectedDepartment,
          searchQuery: (state as StudentDirectoryLoaded).searchQuery,
          successMessage: 'Student record deleted successfully.',
        ));
      } else {
        add(FetchStudentsEvent());
      }
    } catch (e) {
      emit(StudentDirectoryError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchEligibleStudents(
    FetchEligibleStudentsEvent event,
    Emitter<StudentDirectoryState> emit,
  ) async {
    emit(StudentDirectoryLoading());
    try {
      final students = await _apiService.fetchEligibleStudents();
      emit(StudentDirectoryLoaded(
        students: students,
        selectedDepartment: 'All',
        searchQuery: '',
      ));
    } catch (e) {
      emit(StudentDirectoryError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
