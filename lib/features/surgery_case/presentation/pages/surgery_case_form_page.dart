import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth;
import '../../domain/entities/surgery_case.dart';
import '../bloc/surgery_case_bloc.dart';

@RoutePage()
class SurgeryCaseFormPage extends StatefulWidget {
  final String patientId;
  final String? caseId;

  const SurgeryCaseFormPage({
    super.key,
    @PathParam('patientId') required this.patientId,
    @PathParam('caseId') this.caseId,
  });

  @override
  State<SurgeryCaseFormPage> createState() => _SurgeryCaseFormPageState();
}

class _SurgeryCaseFormPageState extends State<SurgeryCaseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  String _surgeryType = 'rhinoplasty';
  DateTime? _scheduledDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SurgeryCaseBloc>(),
      child: BlocConsumer<SurgeryCaseBloc, SurgeryCaseState>(
        listener: (context, state) {
          if (state is SurgeryCaseCreated || state is SurgeryCaseUpdated) {
            context.router.maybePop();
          }
          if (state is SurgeryCaseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                  widget.caseId != null ? 'Edit Case' : 'New Surgery Case'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: _titleController,
                      labelText: 'Case Title',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DropdownButtonFormField<String>(
                      value: _surgeryType,
                      decoration: const InputDecoration(
                        labelText: 'Surgery Type',
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'rhinoplasty', child: Text('Rhinoplasty')),
                        DropdownMenuItem(
                            value: 'otoplasty', child: Text('Otoplasty')),
                        DropdownMenuItem(
                            value: 'facelift', child: Text('Facelift')),
                        DropdownMenuItem(
                            value: 'other', child: Text('Other')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _surgeryType = v);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _descriptionController,
                      labelText: 'Description',
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GestureDetector(
                      onTap: _pickScheduledDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Schedule Date (Optional)',
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _scheduledDate != null
                                  ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                                  : 'Select date',
                              style: _scheduledDate != null
                                  ? null
                                  : TextStyle(
                                      color: Theme.of(context).hintColor,
                                    ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Theme.of(context).hintColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _notesController,
                      labelText: 'Surgeon Notes',
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton.primary(
                      text: 'Create Case',
                      isExpanded: true,
                      isLoading: state is SurgeryCaseLoading,
                      onPressed: () => _submit(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickScheduledDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _scheduledDate = date);
    }
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    final surgeonId = authState is auth.Authenticated ? authState.user.id : '';

    final surgeryCase = SurgeryCase(
      id: widget.caseId ?? '',
      surgeonId: surgeonId,
      patientId: widget.patientId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      surgeryType: _surgeryType,
      status: _scheduledDate != null ? 'scheduled' : 'planning',
      scheduledDate: _scheduledDate,
      surgeonNotes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<SurgeryCaseBloc>().add(CreateSurgeryCaseEvent(surgeryCase));
  }
}
