import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/models/college_dashboard_model.dart';
import '../data/services/college_api_service.dart';

abstract class CollegeEvent {}

class LoadCollegeDashboard extends CollegeEvent {}

class RefreshCollegeDashboard extends CollegeEvent {}

abstract class CollegeState {}

class CollegeInitial extends CollegeState {}

class CollegeLoading extends CollegeState {}

class CollegeLoaded extends CollegeState {
  final CollegeDashboardModel data;

  CollegeLoaded({required this.data});
}

class CollegeError extends CollegeState {
  final String message;

  CollegeError({required this.message});
}

class CollegeBloc extends Bloc<CollegeEvent, CollegeState> {
  final CollegeApiService _apiService;

  CollegeBloc({CollegeApiService? apiService})
      : _apiService = apiService ?? CollegeApiService(),
        super(CollegeInitial()) {
    on<LoadCollegeDashboard>(_onLoadDashboard);
    on<RefreshCollegeDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadCollegeDashboard event,
    Emitter<CollegeState> emit,
  ) async {
    emit(CollegeLoading());
    try {
      final data = await _apiService.fetchDashboardData();
      emit(CollegeLoaded(data: data));
    } catch (e) {
      emit(CollegeError(message: 'Failed to load dashboard data. Please try again.'));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshCollegeDashboard event,
    Emitter<CollegeState> emit,
  ) async {
    try {
      final data = await _apiService.fetchDashboardData();
      emit(CollegeLoaded(data: data));
    } catch (e) {
      // Keep previous data if refresh fails
    }
  }
}
