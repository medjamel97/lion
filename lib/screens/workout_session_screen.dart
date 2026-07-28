import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/exercise_library.dart';
import '../models/exercise.dart';
import '../models/session_log.dart';
import '../models/workout_plan.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Live workout mode: tick off each set, get an automatic rest countdown
/// between sets, and log the session (with duration) when done.
class WorkoutSessionScreen extends StatefulWidget {
  final DayPlan dayPlan;

  const WorkoutSessionScreen({super.key, required this.dayPlan});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late final DateTime _startedAt;
  late final List<List<bool>> _setsDone;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  // Rest timer state.
  Timer? _restTimer;
  int _restRemaining = 0;
  int _restTotal = 0;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _setsDone = [
      for (final pe in widget.dayPlan.exercises)
        List<bool>.filled(pe.sets, false),
    ];
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = DateTime.now().difference(_startedAt));
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  int get _totalSets => _setsDone.fold(0, (sum, l) => sum + l.length);
  int get _doneSets =>
      _setsDone.fold(0, (sum, l) => sum + l.where((d) => d).length);
  bool get _anyProgress => _doneSets > 0;
  bool get _allDone => _doneSets == _totalSets && _totalSets > 0;

  void _toggleSet(int exIndex, int setIndex) {
    final wasDone = _setsDone[exIndex][setIndex];
    setState(() => _setsDone[exIndex][setIndex] = !wasDone);
    if (!wasDone) {
      HapticFeedback.lightImpact();
      final rest = widget.dayPlan.exercises[exIndex].restSeconds;
      final isLastSet = _allDone;
      if (rest > 0 && !isLastSet) _startRest(rest);
    }
  }

  void _startRest(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restTotal = seconds;
      _restRemaining = seconds;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restRemaining <= 1) {
        t.cancel();
        HapticFeedback.mediumImpact();
        setState(() => _restRemaining = 0);
      } else {
        setState(() => _restRemaining--);
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() => _restRemaining = 0);
  }

  Future<void> _finish() async {
    final state = context.read<AppState>();
    final now = DateTime.now();
    await state.logSession(SessionLog(
      id: 'log_${now.millisecondsSinceEpoch}',
      date: now,
      dayLabel: widget.dayPlan.label,
      muscleNames: widget.dayPlan.muscles.map((m) => m.label).toList(),
      exercisesCompleted: widget.dayPlan.exercises.length,
      durationMinutes: (_elapsed.inSeconds / 60).ceil(),
    ));
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Session logged — ${_fmtDuration(_elapsed)} of work. Roar! 🦁')),
      );
    }
  }

  Future<bool> _confirmLeave() async {
    if (!_anyProgress || _allDone) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave workout?'),
        content: const Text(
            'Your progress in this session will be lost unless you finish it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep training'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  static String _fmtDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercises = widget.dayPlan.exercises;
    final resting = _restRemaining > 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeave() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.dayPlan.label.isEmpty
                    ? 'Workout'
                    : widget.dayPlan.label,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                '⏱ ${_fmtDuration(_elapsed)}  ·  $_doneSets/$_totalSets sets',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Progress bar across the whole session.
            LinearProgressIndicator(
              value: _totalSets == 0 ? 0 : _doneSets / _totalSets,
              minHeight: 5,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                itemCount: exercises.length,
                itemBuilder: (context, i) {
                  final pe = exercises[i];
                  final ex = ExerciseLibrary.byId(pe.exerciseId);
                  if (ex == null) return const SizedBox.shrink();
                  final done = _setsDone[i].every((d) => d);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(ex.primaryMuscle.emoji,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ex.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    decoration: done
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: done
                                        ? theme.colorScheme.onSurfaceVariant
                                        : null,
                                  ),
                                ),
                              ),
                              Text(
                                '${pe.reps} reps',
                                style: theme.textTheme.labelMedium?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (var s = 0; s < pe.sets; s++)
                                _SetChip(
                                  index: s + 1,
                                  done: _setsDone[i][s],
                                  onTap: () => _toggleSet(i, s),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomSheet: resting
            ? _RestBar(
                remaining: _restRemaining,
                total: _restTotal,
                onSkip: _skipRest,
              )
            : null,
        floatingActionButton: resting
            ? null
            : FloatingActionButton.extended(
                onPressed: _anyProgress ? _finish : null,
                backgroundColor:
                    _anyProgress ? null : theme.colorScheme.surfaceContainerHighest,
                icon: Icon(_allDone ? Icons.emoji_events : Icons.flag),
                label: Text(_allDone ? 'Finish — all sets done!' : 'Finish workout'),
              ),
      ),
    );
  }
}

class _SetChip extends StatelessWidget {
  final int index;
  final bool done;
  final VoidCallback onTap;

  const _SetChip({required this.index, required this.done, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 44,
        decoration: BoxDecoration(
          color: done
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: done
              ? Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 20)
              : Text(
                  'Set $index',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
        ),
      ),
    );
  }
}

class _RestBar extends StatelessWidget {
  final int remaining;
  final int total;
  final VoidCallback onSkip;

  const _RestBar({
    required this.remaining,
    required this.total,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
      decoration: const BoxDecoration(
        gradient: LionTheme.heroGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: total == 0 ? 0 : remaining / total,
                    strokeWidth: 4,
                    color: const Color(0xFF221800),
                    backgroundColor: Colors.white24,
                  ),
                  Center(
                    child: Text(
                      '$remaining',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF221800),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Rest — breathe, shake it out',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF221800),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF221800)),
              child: const Text('Skip'),
            ),
          ],
        ),
      ),
    );
  }
}
