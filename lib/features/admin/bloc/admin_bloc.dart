import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AdminEvent {}

class LoadAdminUsers extends AdminEvent {}

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final int activeUsersCount;
  AdminLoaded({required this.activeUsersCount});
}

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(AdminInitial()) {
    on<LoadAdminUsers>((event, emit) async {
      emit(AdminLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      emit(AdminLoaded(activeUsersCount: 15400));
    });
  }
}
