import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../injection_container.dart';
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
                      prefixIcon: const Icon(Icons.title),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _surgeryType,
                      decoration: const InputDecoration(
                        labelText: 'Surgery Type',
                        prefixIcon: Icon(Icons.medical_services),
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _descriptionController,
                      labelText: 'Description',
                      prefixIcon: const Icon(Icons.description),
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _scheduledDate != null
                            ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                            : 'Schedule Date (Optional)',
                      ),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: _pickScheduledDate,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _notesController,
                      labelText: 'Surgeon Notes',
                      prefixIcon: const Icon(Icons.notes),
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ElevatedButton(
                      onPressed: state is SurgeryCaseLoading
                          ? null
                          : () => _submit(context),
                      child: state is SurgeryCaseLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Case'),
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

    final surgeonId = Supabase.instance.client.auth.currentUser?.id ?? '';

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
