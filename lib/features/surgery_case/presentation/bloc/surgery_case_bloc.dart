import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/surgery_case.dart';
import '../../domain/usecases/create_surgery_case.dart';
import '../../domain/usecases/get_surgery_cases.dart';
import '../../domain/usecases/update_surgery_case.dart';

// Events
abstract class SurgeryCaseEvent extends Equatable {
  const SurgeryCaseEvent();

  @override
  List<Object?> get props => [];
}

class LoadSurgeryCases extends SurgeryCaseEvent {
  final String? patientId;
  const LoadSurgeryCases({this.patientId});

  @override
  List<Object?> get props => [patientId];
}

class CreateSurgeryCaseEvent extends SurgeryCaseEvent {
  final SurgeryCase surgeryCase;
  const CreateSurgeryCaseEvent(this.surgeryCase);

  @override
  List<Object?> get props => [surgeryCase];
}

class UpdateSurgeryCaseEvent extends SurgeryCaseEvent {
  final SurgeryCase surgeryCase;
  const UpdateSurgeryCaseEvent(this.surgeryCase);

  @override
  List<Object?> get props => [surgeryCase];
}

// States
abstract class SurgeryCaseState extends Equatable {
  const SurgeryCaseState();

  @override
  List<Object?> get props => [];
}

class SurgeryCaseInitial extends SurgeryCaseState {}

class SurgeryCaseLoading extends SurgeryCaseState {}

class SurgeryCaseListLoaded extends SurgeryCaseState {
  final List<SurgeryCase> cases;
  const SurgeryCaseListLoaded(this.cases);

  @override
  List<Object?> get props => [cases];
}

class SurgeryCaseCreated extends SurgeryCaseState {
  final SurgeryCase surgeryCase;
  const SurgeryCaseCreated(this.surgeryCase);

  @override
  List<Object?> get props => [surgeryCase];
}

class SurgeryCaseUpdated extends SurgeryCaseState {
  final SurgeryCase surgeryCase;
  const SurgeryCaseUpdated(this.surgeryCase);

  @override
  List<Object?> get props => [surgeryCase];
}

class SurgeryCaseError extends SurgeryCaseState {
  final String message;
  const SurgeryCaseError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class SurgeryCaseBloc extends Bloc<SurgeryCaseEvent, SurgeryCaseState> {
  final GetSurgeryCases getSurgeryCases;
  final CreateSurgeryCase createSurgeryCase;
  final UpdateSurgeryCase updateSurgeryCase;

  SurgeryCaseBloc({
    required this.getSurgeryCases,
    required this.createSurgeryCase,
    required this.updateSurgeryCase,
  }) : super(SurgeryCaseInitial()) {
    on<LoadSurgeryCases>(_onLoadSurgeryCases);
    on<CreateSurgeryCaseEvent>(_onCreateSurgeryCase);
    on<UpdateSurgeryCaseEvent>(_onUpdateSurgeryCase);
  }

  Future<void> _onLoadSurgeryCases(
    LoadSurgeryCases event,
    Emitter<SurgeryCaseState> emit,
  ) async {
    emit(SurgeryCaseLoading());
    final result = await getSurgeryCases(
      GetSurgeryCasesParams(patientId: event.patientId),
    );
    result.fold(
      (failure) => emit(SurgeryCaseError(failure.message)),
      (cases) => emit(SurgeryCaseListLoaded(cases)),
    );
  }

  Future<void> _onCreateSurgeryCase(
    CreateSurgeryCaseEvent event,
    Emitter<SurgeryCaseState> emit,
  ) async {
    emit(SurgeryCaseLoading());
    final result = await createSurgeryCase(event.surgeryCase);
    result.fold(
      (failure) => emit(SurgeryCaseError(failure.message)),
      (surgeryCase) => emit(SurgeryCaseCreated(surgeryCase)),
    );
  }

  Future<void> _onUpdateSurgeryCase(
    UpdateSurgeryCaseEvent event,
    Emitter<SurgeryCaseState> emit,
  ) async {
    emit(SurgeryCaseLoading());
    final result = await updateSurgeryCase(event.surgeryCase);
    result.fold(
      (failure) => emit(SurgeryCaseError(failure.message)),
      (surgeryCase) => emit(SurgeryCaseUpdated(surgeryCase)),
    );
  }
}
