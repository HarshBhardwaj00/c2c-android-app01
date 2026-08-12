import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/models/placement_drive_model.dart';
import '../domain/models/placement_hub_dashboard_data.dart';
import '../data/services/placement_hub_api_service.dart';

// --- Events ---
abstract class PlacementHubEvent {}

class FetchDrivesEvent extends PlacementHubEvent {
  final String query;
  final String status;
  final String selectedTab;

  FetchDrivesEvent({
    this.query = '',
    this.status = 'All',
    this.selectedTab = 'Overview',
  });
}

class ChangeTabEvent extends PlacementHubEvent {
  final String tab;

  ChangeTabEvent(this.tab);
}

class AssignRecruiterEvent extends PlacementHubEvent {
  final String coordinatorName;
  final String driveCycle;

  AssignRecruiterEvent({
    required this.coordinatorName,
    required this.driveCycle,
  });
}

// --- States ---
abstract class PlacementHubState {}

class PlacementHubInitial extends PlacementHubState {}

class PlacementHubLoading extends PlacementHubState {}

class PlacementHubLoaded extends PlacementHubState {
  final List<PlacementDriveModel> drives;
  final PlacementHubDashboardData dashboardData;
  final String selectedStatus;
  final String searchQuery;
  final String selectedTab;
  final bool isSubmitting;

  PlacementHubLoaded({
    required this.drives,
    required this.dashboardData,
    required this.selectedStatus,
    required this.searchQuery,
    required this.selectedTab,
    this.isSubmitting = false,
  });

  PlacementHubLoaded copyWith({
    List<PlacementDriveModel>? drives,
    PlacementHubDashboardData? dashboardData,
    String? selectedStatus,
    String? searchQuery,
    String? selectedTab,
    bool? isSubmitting,
  }) {
    return PlacementHubLoaded(
      drives: drives ?? this.drives,
      dashboardData: dashboardData ?? this.dashboardData,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTab: selectedTab ?? this.selectedTab,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class PlacementHubError extends PlacementHubState {
  final String message;

  PlacementHubError({required this.message});
}

// --- BLoC ---
class PlacementHubBloc extends Bloc<PlacementHubEvent, PlacementHubState> {
  final PlacementHubApiService _apiService;

  PlacementHubBloc({PlacementHubApiService? apiService})
      : _apiService = apiService ?? PlacementHubApiService(),
        super(PlacementHubInitial()) {
    on<FetchDrivesEvent>(_onFetchDrives);
    on<ChangeTabEvent>(_onChangeTab);
    on<AssignRecruiterEvent>(_onAssignRecruiter);
  }

  Future<void> _onFetchDrives(
    FetchDrivesEvent event,
    Emitter<PlacementHubState> emit,
  ) async {
    emit(PlacementHubLoading());
    try {
      final dashboardData = await _apiService.fetchDashboardData(tab: event.selectedTab);
      final drives = await _apiService.fetchPlacementDrives(
        query: event.query,
        status: event.status,
      );

      emit(PlacementHubLoaded(
        drives: drives,
        dashboardData: dashboardData,
        selectedStatus: event.status,
        searchQuery: event.query,
        selectedTab: event.selectedTab,
      ));
    } catch (e) {
      emit(PlacementHubError(message: 'Failed to load Placement Hub data.'));
    }
  }

  Future<void> _onChangeTab(
    ChangeTabEvent event,
    Emitter<PlacementHubState> emit,
  ) async {
    if (state is PlacementHubLoaded) {
      final currentState = state as PlacementHubLoaded;
      emit(currentState.copyWith(selectedTab: event.tab));
      final updatedData = await _apiService.fetchDashboardData(tab: event.tab);
      emit(currentState.copyWith(
        selectedTab: event.tab,
        dashboardData: updatedData,
      ));
    }
  }

  Future<void> _onAssignRecruiter(
    AssignRecruiterEvent event,
    Emitter<PlacementHubState> emit,
  ) async {
    if (state is PlacementHubLoaded) {
      final currentState = state as PlacementHubLoaded;
      emit(currentState.copyWith(isSubmitting: true));

      await _apiService.assignRecruiter(
        coordinatorName: event.coordinatorName,
        driveCycle: event.driveCycle,
      );

      // Create new recruiter entry for local dynamic UI responsiveness
      final updatedRecruiters = List<RecruiterAllocationModel>.from(currentState.dashboardData.recruiters)
        ..add(RecruiterAllocationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          companyId: 'c_new',
          initials: event.coordinatorName.isNotEmpty
              ? event.coordinatorName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
              : 'RC',
          name: event.coordinatorName,
          title: 'Assigned Officer (${event.driveCycle})',
          activeCount: 1,
        ));

      final newDashboard = PlacementHubDashboardData(
        calendarEvents: currentState.dashboardData.calendarEvents,
        offerPipelines: currentState.dashboardData.offerPipelines,
        recruiters: updatedRecruiters,
        todaysLineup: currentState.dashboardData.todaysLineup,
        activeCyclesCount: currentState.dashboardData.activeCyclesCount + 1,
        totalCandidatesCount: currentState.dashboardData.totalCandidatesCount,
      );

      emit(currentState.copyWith(
        dashboardData: newDashboard,
        isSubmitting: false,
      ));
    }
  }
}
