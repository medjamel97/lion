import 'package:flutter/material.dart';

import '../data/exercise_library.dart';
import '../models/exercise.dart';

/// Multi-select picker over the built-in exercise library, filtered to the
/// day's target muscles (with a toggle to browse everything).
class ExercisePickerScreen extends StatefulWidget {
  final List<MuscleGroup> muscles;
  final Set<String> alreadyPicked;

  const ExercisePickerScreen({
    super.key,
    required this.muscles,
    this.alreadyPicked = const {},
  });

  @override
  State<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends State<ExercisePickerScreen> {
  final Set<String> _selected = {};
  bool _onlyTargetMuscles = true;
  String _query = '';

  List<MapEntry<MuscleGroup, List<Exercise>>> get _grouped {
    final muscles = _onlyTargetMuscles && widget.muscles.isNotEmpty
        ? widget.muscles
        : MuscleGroup.values;
    final q = _query.toLowerCase();
    return [
      for (final m in muscles)
        MapEntry(
          m,
          ExerciseLibrary.forMuscle(m)
              .where((e) =>
                  !widget.alreadyPicked.contains(e.id) &&
                  (q.isEmpty || e.name.toLowerCase().contains(q)))
              .toList(),
        ),
    ].where((entry) => entry.value.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = _grouped;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pick exercises',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
      ),
      floatingActionButton: _selected.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                final picked = _selected
                    .map(ExerciseLibrary.byId)
                    .whereType<Exercise>()
                    .toList();
                Navigator.of(context).pop(picked);
              },
              icon: const Icon(Icons.check),
              label: Text('Add ${_selected.length}'),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search exercises…',
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                if (widget.muscles.isNotEmpty)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      'Only today\'s muscles (${widget.muscles.map((m) => m.label).join(', ')})',
                      style: theme.textTheme.bodySmall,
                    ),
                    value: _onlyTargetMuscles,
                    onChanged: (v) =>
                        setState(() => _onlyTargetMuscles = v),
                  ),
              ],
            ),
          ),
          Expanded(
            child: groups.isEmpty
                ? Center(
                    child: Text('No exercises match',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    children: [
                      for (final entry in groups) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '${entry.key.emoji} ${entry.key.label}',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        for (final ex in entry.value)
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            child: CheckboxListTile(
                              value: _selected.contains(ex.id),
                              onChanged: (v) => setState(() {
                                if (v == true) {
                                  _selected.add(ex.id);
                                } else {
                                  _selected.remove(ex.id);
                                }
                              }),
                              title: Text(ex.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                '${ex.defaultSets} × ${ex.defaultReps} · ${ex.equipment.label}'
                                '${ex.isCompound ? ' · compound' : ''}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
