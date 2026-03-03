import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../injection_container.dart';
import '../bloc/patient_list_bloc.dart';
import '../widgets/patient_card.dart';

@RoutePage()
class PatientListPage extends StatelessWidget {
  const PatientListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PatientListBloc>()..add(const LoadPatients()),
      child: const _PatientListView(),
    );
  }
}

class _PatientListView extends StatefulWidget {
  const _PatientListView();

  @override
  State<_PatientListView> createState() => _PatientListViewState();
}

class _PatientListViewState extends State<_PatientListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
      ),
      body: BlocConsumer<PatientListBloc, PatientListState>(
        listener: (context, state) {
          if (state is PatientCreated || state is PatientUpdated) {
            context.read<PatientListBloc>().add(const LoadPatients());
          }
        },
        builder: (context, state) {
          if (state is PatientListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PatientListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => context
                        .read<PatientListBloc>()
                        .add(const LoadPatients()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is PatientListLoaded) {
            if (state.patients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text('No patients yet'),
                    const SizedBox(height: AppSpacing.sm),
                    const Text('Tap + to add your first patient'),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PatientListBloc>().add(const LoadPatients());
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.xs,
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search patients...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _searchController,
                          builder: (_, value, __) {
                            if (value.text.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                context
                                    .read<PatientListBloc>()
                                    .add(const LoadPatients());
                              },
                            );
                          },
                        ),
                      ),
                      onChanged: (query) {
                        if (query.isEmpty) {
                          context
                              .read<PatientListBloc>()
                              .add(const LoadPatients());
                        } else {
                          context
                              .read<PatientListBloc>()
                              .add(SearchPatientsEvent(query));
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: state.patients.length,
                      itemBuilder: (context, index) {
                        final patient = state.patients[index];
                        return PatientCard(
                          patient: patient,
                          onTap: () async {
                            await context.router.push(
                              PatientDetailRoute(patientId: patient.id),
                            );
                            if (context.mounted) {
                              context
                                  .read<PatientListBloc>()
                                  .add(const LoadPatients());
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.router.push(PatientFormRoute());
          if (context.mounted) {
            context.read<PatientListBloc>().add(const LoadPatients());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
