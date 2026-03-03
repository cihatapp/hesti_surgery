import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/morphing_bloc.dart';
import '../widgets/morph_control_panel.dart';

@RoutePage()
class MorphingPage extends StatelessWidget {
  final String modelId;
  final String modelUrl;

  const MorphingPage({
    super.key,
    required this.modelId,
    required this.modelUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MorphingBloc>()..add(InitializeMorphing(modelId: modelId)),
      child: _MorphingView(modelId: modelId, modelUrl: modelUrl),
    );
  }
}

class _MorphingView extends StatefulWidget {
  final String modelId;
  final String modelUrl;

  const _MorphingView({required this.modelId, required this.modelUrl});

  @override
  State<_MorphingView> createState() => _MorphingViewState();
}

class _MorphingViewState extends State<_MorphingView> {
  late final Flutter3DController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Flutter3DController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MorphingBloc, MorphingState>(
      listener: (context, state) {
        if (state is MorphingSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Morph parameters saved')),
          );
        }
        if (state is MorphingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Morphing'),
          ),
          body: Column(
            children: [
              // 3D Viewer (top half)
              Expanded(
                flex: 3,
                child: Flutter3DViewer(
                  controller: _controller,
                  src: widget.modelUrl,
                ),
              ),

              // Morph controls (bottom half)
              if (state is MorphingReady)
                Expanded(
                  flex: 2,
                  child: MorphControlPanel(
                    parameters: state.parameters,
                    hasUnsavedChanges: state.hasUnsavedChanges,
                    onParameterChanged: (name, value) {
                      context.read<MorphingBloc>().add(
                            UpdateMorphParameter(
                              parameterName: name,
                              value: value,
                            ),
                          );
                    },
                    onReset: () {
                      context.read<MorphingBloc>().add(
                            const ResetMorphParameters(),
                          );
                    },
                    onSave: () {
                      context.read<MorphingBloc>().add(
                            const SaveMorphParameters(),
                          );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
