import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../state/app_state.dart';
import '../widgets/bmi_gauge.dart';
import '../widgets/stat_card.dart';
import '../widgets/weight_chart.dart';

/// Body data, calculated health metrics, WHO guidelines and session history.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final profile = state.profile;
    final metrics = state.metrics;
    if (profile == null || metrics == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My health',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editProfile(context, profile),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Text('🦁')),
              title: Text(profile.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              subtitle: Text(
                '${profile.heightCm.toStringAsFixed(0)} cm · ${profile.weightKg.toStringAsFixed(1)} kg · ${profile.age} y · ${profile.goal.label}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              trailing: Tooltip(
                message: 'Where your data is saved',
                child: Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: Icon(
                    state.backendName.startsWith('Firebase')
                        ? Icons.cloud_done
                        : Icons.phone_android,
                    size: 16,
                  ),
                  label: Text(
                    state.backendName.startsWith('Firebase')
                        ? 'Cloud'
                        : 'Device',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── BMI gauge ───────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('BMI ${metrics.bmi.toStringAsFixed(1)}',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      Text('· ${metrics.bmiCategory}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  BmiGauge(bmi: metrics.bmi),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Weight progress ─────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Weight progress',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const Spacer(),
                      FilledButton.tonalIcon(
                        onPressed: () => _logWeight(context, profile),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Log weight'),
                      ),
                    ],
                  ),
                  if (state.weightEntries.length >= 2) ...[
                    const SizedBox(height: 4),
                    Builder(builder: (context) {
                      final first = state.weightEntries.first.weightKg;
                      final last = state.weightEntries.last.weightKg;
                      final delta = last - first;
                      final sign = delta >= 0 ? '+' : '';
                      return Text(
                        '$sign${delta.toStringAsFixed(1)} kg since ${_fmtDate(state.weightEntries.first.date)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      );
                    }),
                  ],
                  const SizedBox(height: 8),
                  WeightChart(entries: state.weightEntries),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Metrics grid ────────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.9,
            children: [
              StatCard(
                label: 'Healthy weight',
                value:
                    '${metrics.healthyWeightMinKg.toStringAsFixed(0)}-${metrics.healthyWeightMaxKg.toStringAsFixed(0)} kg',
                sub: 'for your height',
                icon: Icons.balance,
              ),
              StatCard(
                label: 'BMR',
                value: '${metrics.bmr.round()} kcal',
                sub: 'at complete rest',
                icon: Icons.battery_charging_full,
              ),
              StatCard(
                label: 'Maintenance',
                value: '${metrics.tdee.round()} kcal',
                sub: 'daily energy (TDEE)',
                icon: Icons.local_fire_department,
              ),
              StatCard(
                label: 'Target calories',
                value: '${metrics.targetCalories.round()} kcal',
                sub: 'to ${profile.goal.label.toLowerCase()}',
                icon: Icons.flag_outlined,
                color: Colors.greenAccent,
              ),
              StatCard(
                label: 'Protein',
                value:
                    '${metrics.proteinMinG.round()}-${metrics.proteinMaxG.round()} g',
                sub: 'per day for muscle growth',
                icon: Icons.egg_alt_outlined,
                color: Colors.orangeAccent,
              ),
              StatCard(
                label: 'Water',
                value: '${metrics.waterLiters.toStringAsFixed(1)} L',
                sub: 'per day',
                icon: Icons.water_drop_outlined,
                color: Colors.lightBlueAccent,
              ),
              StatCard(
                label: 'Sessions/week',
                value: state.plan.trainingDaysPerWeek.toStringAsFixed(1),
                sub: 'in your current cycle',
                icon: Icons.fitness_center,
              ),
            ],
          ),

          // ── WHO habits ──────────────────────────────────────────────
          const SizedBox(height: 16),
          Text('Healthy habits (WHO)',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const _HabitTile(
              icon: Icons.directions_run,
              text:
                  '150-300 min of moderate aerobic activity per week (or 75-150 min vigorous).'),
          const _HabitTile(
              icon: Icons.fitness_center,
              text:
                  'Muscle-strengthening activity for all major muscle groups on 2+ days per week.'),
          const _HabitTile(
              icon: Icons.hotel,
              text:
                  '7-9 hours of sleep per night — most muscle repair happens while you sleep.'),
          const _HabitTile(
              icon: Icons.egg_alt_outlined,
              text:
                  '1.6-2.2 g of protein per kg of body weight daily, spread over 3-5 meals.'),
          const _HabitTile(
              icon: Icons.trending_up,
              text:
                  'Progressive overload: add a little weight or a rep each week — that\'s what drives growth.'),
          const _HabitTile(
              icon: Icons.self_improvement,
              text:
                  'Give each muscle ~48h before training it hard again, and keep 1+ full rest day weekly.'),

          // ── History ─────────────────────────────────────────────────
          const SizedBox(height: 16),
          Text('Session history',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (state.logs.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No sessions logged yet. Finish today\'s workout and hit "Mark session done"!',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          for (final log in state.logs.reversed.take(30))
            Card(
              margin: const EdgeInsets.symmetric(vertical: 3),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.check_circle,
                    color: Colors.greenAccent, size: 20),
                title: Text(
                  log.dayLabel.isEmpty ? 'Workout' : log.dayLabel,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${_fmtDate(log.date)}'
                  '${log.durationMinutes > 0 ? ' · ${log.durationMinutes} min' : ''}'
                  '${log.muscleNames.isEmpty ? '' : ' · ${log.muscleNames.join(', ')}'}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () =>
                      context.read<AppState>().removeLog(log.id),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _logWeight(BuildContext context, UserProfile profile) async {
    final state = context.read<AppState>();
    final ctrl =
        TextEditingController(text: profile.weightKg.toStringAsFixed(1));
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log today\'s weight'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
              labelText: 'Weight (kg)', suffixText: 'kg'),
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
      ),
    );
    if (saved == true) {
      final value = double.tryParse(ctrl.text.replaceAll(',', '.'));
      if (value != null && value >= 30 && value <= 300) {
        await state.logWeight(value);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a weight between 30 and 300 kg')),
        );
      }
    }
    ctrl.dispose();
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _editProfile(BuildContext context, UserProfile profile) async {
    final state = context.read<AppState>();
    final nameCtrl = TextEditingController(text: profile.name);
    final heightCtrl =
        TextEditingController(text: profile.heightCm.toStringAsFixed(0));
    final weightCtrl =
        TextEditingController(text: profile.weightKg.toStringAsFixed(1));
    final ageCtrl = TextEditingController(text: '${profile.age}');
    var sex = profile.sex;
    var activity = profile.activityLevel;
    var goal = profile.goal;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Edit profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: heightCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Height (cm)'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: weightCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Weight (kg)'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: ageCtrl,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<Sex>(
                      segments: const [
                        ButtonSegment(value: Sex.male, label: Text('Male')),
                        ButtonSegment(
                            value: Sex.female, label: Text('Female')),
                      ],
                      selected: {sex},
                      onSelectionChanged: (s) =>
                          setDialogState(() => sex = s.first),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ActivityLevel>(
                      initialValue: activity,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(labelText: 'Activity'),
                      items: [
                        for (final a in ActivityLevel.values)
                          DropdownMenuItem(
                              value: a,
                              child: Text(a.label,
                                  overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (a) =>
                          setDialogState(() => activity = a ?? activity),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<FitnessGoal>(
                      initialValue: goal,
                      decoration: const InputDecoration(labelText: 'Goal'),
                      items: [
                        for (final g in FitnessGoal.values)
                          DropdownMenuItem(value: g, child: Text(g.label)),
                      ],
                      onChanged: (g) => setDialogState(() => goal = g ?? goal),
                    ),
                  ],
                ),
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
      final height =
          double.tryParse(heightCtrl.text.replaceAll(',', '.'));
      final weight =
          double.tryParse(weightCtrl.text.replaceAll(',', '.'));
      final age = int.tryParse(ageCtrl.text);
      await state.saveProfile(profile.copyWith(
        name: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
        heightCm: (height != null && height >= 100 && height <= 250)
            ? height
            : null,
        weightKg:
            (weight != null && weight >= 30 && weight <= 300) ? weight : null,
        age: (age != null && age >= 13 && age <= 100) ? age : null,
        sex: sex,
        activityLevel: activity,
        goal: goal,
      ));
    }
    nameCtrl.dispose();
    heightCtrl.dispose();
    weightCtrl.dispose();
    ageCtrl.dispose();
  }
}

class _HabitTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HabitTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: theme.colorScheme.primary, size: 20),
        title: Text(text, style: theme.textTheme.bodySmall),
      ),
    );
  }
}
