import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/patient.dart';
import '../../domain/usecases/create_patient.dart';
import '../../domain/usecases/get_patients.dart';
import '../../domain/usecases/search_patients.dart';
import '../../domain/usecases/update_patient.dart';

// Events
abstract class PatientListEvent extends Equatable {
  const PatientListEvent();

  @override
  List<Object?> get props => [];
}

class LoadPatients extends PatientListEvent {
  const LoadPatients();
}

class SearchPatientsEvent extends PatientListEvent {
  final String query;
  const SearchPatientsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class CreatePatientEvent extends PatientListEvent {
  final Patient patient;
  const CreatePatientEvent(this.patient);

  @override
  List<Object?> get props => [patient];
}

class UpdatePatientEvent extends PatientListEvent {
  final Patient patient;
  const UpdatePatientEvent(this.patient);

  @override
  List<Object?> get props => [patient];
}

// States
abstract class PatientListState extends Equatable {
  const PatientListState();

  @override
  List<Object?> get props => [];
}

class PatientListInitial extends PatientListState {}

class PatientListLoading extends PatientListState {}

class PatientListLoaded extends PatientListState {
  final List<Patient> patients;
  const PatientListLoaded(this.patients);

  @override
  List<Object?> get props => [patients];
}

class PatientListError extends PatientListState {
  final String message;
  const PatientListError(this.message);

  @override
  List<Object?> get props => [message];
}

class PatientCreated extends PatientListState {
  final Patient patient;
  const PatientCreated(this.patient);

  @override
  List<Object?> get props => [patient];
}

class PatientUpdated extends PatientListState {
  final Patient patient;
  const PatientUpdated(this.patient);

  @override
  List<Object?> get props => [patient];
}

// BLoC
class PatientListBloc extends Bloc<PatientListEvent, PatientListState> {
  final GetPatients getPatients;
  final CreatePatient createPatient;
  final UpdatePatient updatePatient;
  final SearchPatients searchPatients;

  PatientListBloc({
    required this.getPatients,
    required this.createPatient,
    required this.updatePatient,
    required this.searchPatients,
  }) : super(PatientListInitial()) {
    on<LoadPatients>(_onLoadPatients);
    on<SearchPatientsEvent>(_onSearchPatients);
    on<CreatePatientEvent>(_onCreatePatient);
    on<UpdatePatientEvent>(_onUpdatePatient);
  }

  Future<void> _onLoadPatients(
    LoadPatients event,
    Emitter<PatientListState> emit,
  ) async {
    emit(PatientListLoading());
    final result = await getPatients(const NoParams());
    result.fold(
      (failure) => emit(PatientListError(failure.message)),
      (patients) => emit(PatientListLoaded(patients)),
    );
  }

  Future<void> _onSearchPatients(
    SearchPatientsEvent event,
    Emitter<PatientListState> emit,
  ) async {
    emit(PatientListLoading());
    final result = await searchPatients(event.query);
    result.fold(
      (failure) => emit(PatientListError(failure.message)),
      (patients) => emit(PatientListLoaded(patients)),
    );
  }

  Future<void> _onCreatePatient(
    CreatePatientEvent event,
    Emitter<PatientListState> emit,
  ) async {
    emit(PatientListLoading());
    final result = await createPatient(event.patient);
    result.fold(
      (failure) => emit(PatientListError(failure.message)),
      (patient) => emit(PatientCreated(patient)),
    );
  }

  Future<void> _onUpdatePatient(
    UpdatePatientEvent event,
    Emitter<PatientListState> emit,
  ) async {
    emit(PatientListLoading());
    final result = await updatePatient(event.patient);
    result.fold(
      (failure) => emit(PatientListError(failure.message)),
      (patient) => emit(PatientUpdated(patient)),
    );
  }
}
