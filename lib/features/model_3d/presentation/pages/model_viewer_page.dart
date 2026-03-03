import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../injection_container.dart';
import '../bloc/model_viewer_bloc.dart';

@RoutePage()
class ModelViewerPage extends StatelessWidget {
  final String caseId;

  const ModelViewerPage({
    super.key,
    @PathParam('caseId') required this.caseId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ModelViewerBloc>()..add(LoadModels(caseId)),
      child: _ModelViewerView(caseId: caseId),
    );
  }
}

class _ModelViewerView extends StatefulWidget {
  final String caseId;

  const _ModelViewerView({required this.caseId});

  @override
  State<_ModelViewerView> createState() => _ModelViewerViewState();
}

class _ModelViewerViewState extends State<_ModelViewerView> {
  Flutter3DController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = Flutter3DController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Model'),
        actions: [
          BlocBuilder<ModelViewerBloc, ModelViewerState>(
            builder: (context, state) {
              final hasModel = state is ModelUrlLoaded;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: hasModel
                        ? () {
                            final url = (state as ModelUrlLoaded).url;
                            context.router.push(MorphingRoute(
                              modelId: widget.caseId,
                              modelUrl: url,
                            ));
                          }
                        : null,
                    tooltip: 'Morph',
                  ),
                  IconButton(
                    icon: const Icon(Icons.compare),
                    onPressed: hasModel
                        ? () {
                            final url = (state as ModelUrlLoaded).url;
                            context.router.push(ComparisonRoute(
                              originalModelUrl: url,
                              morphedModelUrl: url,
                            ));
                          }
                        : null,
                    tooltip: 'Compare',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ModelViewerBloc, ModelViewerState>(
        builder: (context, state) {
          if (state is ModelsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReconstructionInProgress) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.status),
                ],
              ),
            );
          }

          if (state is ModelUrlLoaded) {
            return _build3DViewer(state.url);
          }

          if (state is ModelsLoaded && state.models.isNotEmpty) {
            // Load the first model's URL
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<ModelViewerBloc>().add(
                    LoadModelUrl(state.models.first.storagePath),
                  );
            });
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ModelViewerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: AppSpacing.md),
                  Text(state.message, textAlign: TextAlign.center),
                ],
              ),
            );
          }

          // No models - show reconstruction prompt
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.view_in_ar,
                  size: 64,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('No 3D model yet'),
                const SizedBox(height: AppSpacing.sm),
                const Text('Capture photos first, then generate a 3D model'),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () {
                    final surgeonId =
                        Supabase.instance.client.auth.currentUser?.id ?? '';
                    context.read<ModelViewerBloc>().add(
                          RequestReconstruction(
                            caseId: widget.caseId,
                            surgeonId: surgeonId,
                            photoStoragePath:
                                'patient-photos/${widget.caseId}/',
                          ),
                        );
                  },
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Generate 3D Model'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _build3DViewer(String modelUrl) {
    return Flutter3DViewer(
      controller: _controller!,
      src: modelUrl,
    );
  }
}
