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

class _PatientListView extends StatelessWidget {
  const _PatientListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
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
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: state.patients.length,
                itemBuilder: (context, index) {
                  final patient = state.patients[index];
                  return PatientCard(
                    patient: patient,
                    onTap: () => context.router.push(
                      PatientDetailRoute(patientId: patient.id),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.router.push(PatientFormRoute()),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    final bloc = context.read<PatientListBloc>();
    showSearch(
      context: context,
      delegate: _PatientSearchDelegate(bloc),
    );
  }
}

class _PatientSearchDelegate extends SearchDelegate<String?> {
  final PatientListBloc bloc;

  _PatientSearchDelegate(this.bloc);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    bloc.add(SearchPatientsEvent(query));
    return BlocBuilder<PatientListBloc, PatientListState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is PatientListLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: state.patients.length,
            itemBuilder: (context, index) {
              final patient = state.patients[index];
              return PatientCard(
                patient: patient,
                onTap: () {
                  close(context, null);
                  context.router.push(
                    PatientDetailRoute(patientId: patient.id),
                  );
                },
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);
}
