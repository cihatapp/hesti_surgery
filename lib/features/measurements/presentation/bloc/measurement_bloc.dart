import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/measurement_remote_datasource.dart';
import '../../domain/entities/measurement.dart';

// Events
abstract class MeasurementEvent extends Equatable {
  const MeasurementEvent();

  @override
  List<Object?> get props => [];
}

class LoadMeasurements extends MeasurementEvent {
  final String caseId;
  const LoadMeasurements(this.caseId);

  @override
  List<Object?> get props => [caseId];
}

class SaveMeasurementEvent extends MeasurementEvent {
  final Measurement measurement;
  const SaveMeasurementEvent(this.measurement);

  @override
  List<Object?> get props => [measurement];
}

class DeleteMeasurementEvent extends MeasurementEvent {
  final String measurementId;
  const DeleteMeasurementEvent(this.measurementId);

  @override
  List<Object?> get props => [measurementId];
}

// States
abstract class MeasurementState extends Equatable {
  const MeasurementState();

  @override
  List<Object?> get props => [];
}

class MeasurementInitial extends MeasurementState {}

class MeasurementLoading extends MeasurementState {}

class MeasurementsLoaded extends MeasurementState {
  final List<Measurement> measurements;
  const MeasurementsLoaded(this.measurements);

  /// Group measurements by phase
  Map<String, List<Measurement>> get grouped {
    final map = <String, List<Measurement>>{};
    for (final m in measurements) {
      (map[m.phase] ??= []).add(m);
    }
    return map;
  }

  @override
  List<Object?> get props => [measurements];
}

class MeasurementSaved extends MeasurementState {
  final Measurement measurement;
  const MeasurementSaved(this.measurement);

  @override
  List<Object?> get props => [measurement];
}

class MeasurementError extends MeasurementState {
  final String message;
  const MeasurementError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class MeasurementBloc extends Bloc<MeasurementEvent, MeasurementState> {
  final MeasurementRemoteDataSource remoteDataSource;

  MeasurementBloc({required this.remoteDataSource})
      : super(MeasurementInitial()) {
    on<LoadMeasurements>(_onLoad);
    on<SaveMeasurementEvent>(_onSave);
    on<DeleteMeasurementEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadMeasurements event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(MeasurementLoading());
    try {
      final measurements = await remoteDataSource.getMeasurements(event.caseId);
      emit(MeasurementsLoaded(measurements));
    } catch (e) {
      emit(MeasurementError(e.toString()));
    }
  }

  Future<void> _onSave(
    SaveMeasurementEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    try {
      final saved = await remoteDataSource.saveMeasurement(event.measurement);
      emit(MeasurementSaved(saved));
    } catch (e) {
      emit(MeasurementError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteMeasurementEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    try {
      await remoteDataSource.deleteMeasurement(event.measurementId);
    } catch (e) {
      emit(MeasurementError(e.toString()));
    }
  }
}
