import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/exercise_library.dart';
import '../models/exercise.dart';
import '../models/workout_plan.dart';
import '../state/app_state.dart';
import 'exercise_picker_screen.dart';

/// Plan a single training day of the cycle: name it, pick target muscles,
/// then add exercises from the library.
class DayPlannerScreen extends StatefulWidget {
  final int dayIndex;

  const DayPlannerScreen({super.key, required this.dayIndex});

  @override
  State<DayPlannerScreen> createState() => _DayPlannerScreenState();
}

class _DayPlannerScreenState extends State<DayPlannerScreen> {
  late final TextEditingController _labelCtrl;

  @override
  void initState() {
    super.initState();
    final day = context.read<AppState>().plan.days[widget.dayIndex];
    _labelCtrl = TextEditingController(text: day.label);
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  DayPlan get _day => context.read<AppState>().plan.days[widget.dayIndex];

  Future<void> _update(DayPlan day) =>
      context.read<AppState>().updateDay(widget.dayIndex, day);

  Future<void> _toggleMuscle(MuscleGroup muscle) async {
    final day = _day;
    final muscles = List<MuscleGroup>.from(day.muscles);
    if (muscles.contains(muscle)) {
      muscles.remove(muscle);
      // Drop exercises that no longer match any selected muscle.
      final exercises = day.exercises.where((pe) {
        final ex = ExerciseLibrary.byId(pe.exerciseId);
        return ex != null && muscles.contains(ex.primaryMuscle);
      }).toList();
      await _update(day.copyWith(muscles: muscles, exercises: exercises));
    } else {
      muscles.add(muscle);
      await _update(day.copyWith(muscles: muscles));
    }
  }

  Future<void> _addExercises() async {
    final day = _day;
    final selected = await Navigator.of(context).push<List<Exercise>>(
      MaterialPageRoute(
        builder: (_) => ExercisePickerScreen(
          muscles: day.muscles,
          alreadyPicked: day.exercises.map((e) => e.exerciseId).toSet(),
        ),
      ),
    );
    if (selected == null || selected.isEmpty) return;
    final added = selected.map((ex) => PlannedExercise(
          exerciseId: ex.id,
          sets: ex.defaultSets,
          reps: ex.defaultReps,
        ));
    await _update(
        day.copyWith(exercises: [...day.exercises, ...added]));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch so the list rebuilds after edits.
    final day = context
        .watch<AppState>()
        .plan
        .days[widget.dayIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Day ${widget.dayIndex + 1} of cycle',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
      ),
      floatingActionButton: day.muscles.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _addExercises,
              icon: const Icon(Icons.add),
              label: const Text('Add exercises'),
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        children: [
          TextField(
            controller: _labelCtrl,
            decoration: const InputDecoration(
              labelText: 'Session name',
              hintText: 'e.g. Push day, Leg day…',
            ),
            onChanged: (v) => _update(_day.copyWith(label: v)),
          ),
          const SizedBox(height: 16),
          Text('Target muscles',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in MuscleGroup.values)
                FilterChip(
                  label: Text('${m.emoji} ${m.label}'),
                  selected: day.muscles.contains(m),
                  onSelected: (_) => _toggleMuscle(m),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Exercises (${day.exercises.length})',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (day.exercises.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  day.muscles.isEmpty
                      ? 'Pick at least one muscle group above, then add exercises.'
                      : 'No exercises yet — tap "Add exercises" to pick from the library.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          for (var i = 0; i < day.exercises.length; i++)
            _exerciseCard(context, day, i),
        ],
      ),
    );
  }

  Widget _exerciseCard(BuildContext context, DayPlan day, int i) {
    final theme = Theme.of(context);
    final pe = day.exercises[i];
    final ex = ExerciseLibrary.byId(pe.exerciseId);
    if (ex == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Text(ex.primaryMuscle.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ex.name,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    '${pe.sets} sets × ${pe.reps} · rest ${pe.restSeconds}s',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit sets/reps',
              icon: const Icon(Icons.tune, size: 20),
              onPressed: () => _editPrescription(context, day, i),
            ),
            IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () {
                final exercises = List<PlannedExercise>.from(day.exercises)
                  ..removeAt(i);
                _update(day.copyWith(exercises: exercises));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editPrescription(
      BuildContext context, DayPlan day, int i) async {
    final pe = day.exercises[i];
    var sets = pe.sets;
    var rest = pe.restSeconds;
    final repsCtrl = TextEditingController(text: pe.reps);

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Sets, reps & rest'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sets'),
                      Row(
                        children: [
                          IconButton(
                            onPressed: sets > 1
                                ? () => setDialogState(() => sets--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$sets'),
                          IconButton(
                            onPressed: sets < 10
                                ? () => setDialogState(() => sets++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextField(
                    controller: repsCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Reps', hintText: 'e.g. 8-12'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rest (s)'),
                      Row(
                        children: [
                          IconButton(
                            onPressed: rest >= 30
                                ? () => setDialogState(() => rest -= 15)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$rest'),
                          IconButton(
                            onPressed: rest <= 285
                                ? () => setDialogState(() => rest += 15)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      final exercises = List<PlannedExercise>.from(day.exercises);
      exercises[i] = pe.copyWith(
        sets: sets,
        reps: repsCtrl.text.trim().isEmpty ? pe.reps : repsCtrl.text.trim(),
        restSeconds: rest,
      );
      await _update(day.copyWith(exercises: exercises));
    }
    repsCtrl.dispose();
  }
}
