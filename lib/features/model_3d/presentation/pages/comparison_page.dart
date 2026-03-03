import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';

@RoutePage()
class ComparisonPage extends StatefulWidget {
  final String originalModelUrl;
  final String morphedModelUrl;

  const ComparisonPage({
    super.key,
    required this.originalModelUrl,
    required this.morphedModelUrl,
  });

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  late final Flutter3DController _originalController;
  late final Flutter3DController _morphedController;
  double _sliderValue = 0.5;
  bool _isSplitView = true;

  @override
  void initState() {
    super.initState();
    _originalController = Flutter3DController();
    _morphedController = Flutter3DController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Before / After'),
        actions: [
          IconButton(
            icon: Icon(_isSplitView ? Icons.compare : Icons.view_stream),
            onPressed: () => setState(() => _isSplitView = !_isSplitView),
            tooltip: _isSplitView ? 'Slider View' : 'Split View',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isSplitView
                ? _buildSplitView()
                : _buildSliderView(),
          ),

          // Labels
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLabel(context, 'Before', Colors.red),
                _buildLabel(context, 'After', Colors.green),
              ],
            ),
          ),

          // Animation slider (slider view only)
          if (!_isSplitView)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  const Text('Before'),
                  Expanded(
                    child: Slider(
                      value: _sliderValue,
                      onChanged: (v) => setState(() => _sliderValue = v),
                    ),
                  ),
                  const Text('After'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSplitView() {
    return Row(
      children: [
        // Original (left)
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('Before',
                    style: context.textTheme.labelMedium),
              ),
              Expanded(
                child: Flutter3DViewer(
                  controller: _originalController,
                  src: widget.originalModelUrl,
                ),
              ),
            ],
          ),
        ),
        // Divider
        Container(width: 2, color: context.colorScheme.outline),
        // Morphed (right)
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('After',
                    style: context.textTheme.labelMedium),
              ),
              Expanded(
                child: Flutter3DViewer(
                  controller: _morphedController,
                  src: widget.morphedModelUrl,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderView() {
    return Stack(
      children: [
        // Full-width original
        Flutter3DViewer(
          controller: _originalController,
          src: widget.originalModelUrl,
        ),
        // Reveal morphed based on slider
        ClipRect(
          clipper: _RevealClipper(revealFraction: _sliderValue),
          child: Flutter3DViewer(
            controller: _morphedController,
            src: widget.morphedModelUrl,
          ),
        ),
        // Slider line indicator
        Positioned(
          left: MediaQuery.of(context).size.width * _sliderValue - 1,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: context.textTheme.bodyMedium),
      ],
    );
  }
}

class _RevealClipper extends CustomClipper<Rect> {
  final double revealFraction;

  _RevealClipper({required this.revealFraction});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * revealFraction, size.height);
  }

  @override
  bool shouldReclip(_RevealClipper oldClipper) {
    return oldClipper.revealFraction != revealFraction;
  }
}
