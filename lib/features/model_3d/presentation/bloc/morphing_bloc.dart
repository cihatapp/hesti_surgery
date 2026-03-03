import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/model_3d_remote_datasource.dart';
import '../../domain/entities/morph_parameters.dart';

// Events
abstract class MorphingEvent extends Equatable {
  const MorphingEvent();

  @override
  List<Object?> get props => [];
}

class InitializeMorphing extends MorphingEvent {
  final String modelId;
  final MorphParameters? initialParameters;

  const InitializeMorphing({
    required this.modelId,
    this.initialParameters,
  });

  @override
  List<Object?> get props => [modelId];
}

class UpdateMorphParameter extends MorphingEvent {
  final String parameterName;
  final double value;

  const UpdateMorphParameter({
    required this.parameterName,
    required this.value,
  });

  @override
  List<Object?> get props => [parameterName, value];
}

class SaveMorphParameters extends MorphingEvent {
  const SaveMorphParameters();
}

class ResetMorphParameters extends MorphingEvent {
  const ResetMorphParameters();
}

// States
abstract class MorphingState extends Equatable {
  const MorphingState();

  @override
  List<Object?> get props => [];
}

class MorphingInitial extends MorphingState {}

class MorphingReady extends MorphingState {
  final String modelId;
  final MorphParameters parameters;
  final bool hasUnsavedChanges;

  const MorphingReady({
    required this.modelId,
    required this.parameters,
    this.hasUnsavedChanges = false,
  });

  @override
  List<Object?> get props => [modelId, parameters, hasUnsavedChanges];
}

class MorphingSaving extends MorphingState {}

class MorphingSaved extends MorphingState {}

class MorphingError extends MorphingState {
  final String message;
  const MorphingError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class MorphingBloc extends Bloc<MorphingEvent, MorphingState> {
  final Model3DRemoteDataSource remoteDataSource;

  String? _currentModelId;
  MorphParameters _parameters = const MorphParameters();

  MorphingBloc({required this.remoteDataSource}) : super(MorphingInitial()) {
    on<InitializeMorphing>(_onInitialize);
    on<UpdateMorphParameter>(_onUpdateParameter);
    on<SaveMorphParameters>(_onSave);
    on<ResetMorphParameters>(_onReset);
  }

  void _onInitialize(
    InitializeMorphing event,
    Emitter<MorphingState> emit,
  ) {
    _currentModelId = event.modelId;
    _parameters = event.initialParameters ?? const MorphParameters();
    emit(MorphingReady(
      modelId: event.modelId,
      parameters: _parameters,
    ));
  }

  void _onUpdateParameter(
    UpdateMorphParameter event,
    Emitter<MorphingState> emit,
  ) {
    _parameters = switch (event.parameterName) {
      'tipProjection' => _parameters.copyWith(tipProjection: event.value),
      'dorsalHumpReduction' =>
        _parameters.copyWith(dorsalHumpReduction: event.value),
      'tipRotation' => _parameters.copyWith(tipRotation: event.value),
      'nostrilWidth' => _parameters.copyWith(nostrilWidth: event.value),
      'chinProjection' => _parameters.copyWith(chinProjection: event.value),
      'bridgeWidth' => _parameters.copyWith(bridgeWidth: event.value),
      'alarBase' => _parameters.copyWith(alarBase: event.value),
      _ => _parameters,
    };

    emit(MorphingReady(
      modelId: _currentModelId!,
      parameters: _parameters,
      hasUnsavedChanges: true,
    ));
  }

  Future<void> _onSave(
    SaveMorphParameters event,
    Emitter<MorphingState> emit,
  ) async {
    if (_currentModelId == null) return;

    emit(MorphingSaving());
    try {
      await remoteDataSource.updateMorphParameters(
        _currentModelId!,
        _parameters.toJson(),
      );
      emit(MorphingSaved());
      emit(MorphingReady(
        modelId: _currentModelId!,
        parameters: _parameters,
      ));
    } catch (e) {
      emit(MorphingError(e.toString()));
    }
  }

  void _onReset(
    ResetMorphParameters event,
    Emitter<MorphingState> emit,
  ) {
    _parameters = const MorphParameters();
    emit(MorphingReady(
      modelId: _currentModelId!,
      parameters: _parameters,
      hasUnsavedChanges: true,
    ));
  }
}
