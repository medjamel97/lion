import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../state/app_state.dart';

/// First-launch screen: collects the body data used for all health
/// calculations (BMI, calories, protein, water).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _heightCtrl = TextEditingController(text: '175');
  final _weightCtrl = TextEditingController(text: '75');
  final _ageCtrl = TextEditingController(text: '25');
  Sex _sex = Sex.male;
  ActivityLevel _activity = ActivityLevel.moderate;
  FitnessGoal _goal = FitnessGoal.buildMuscle;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  String? _numValidator(String? v, double min, double max, String label) {
    final parsed = double.tryParse((v ?? '').replaceAll(',', '.'));
    if (parsed == null) return 'Enter a number';
    if (parsed < min || parsed > max) return '$label must be $min-$max';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = UserProfile(
      name: _nameCtrl.text.trim().isEmpty ? 'Lion' : _nameCtrl.text.trim(),
      heightCm: double.parse(_heightCtrl.text.replaceAll(',', '.')),
      weightKg: double.parse(_weightCtrl.text.replaceAll(',', '.')),
      age: double.parse(_ageCtrl.text.replaceAll(',', '.')).round(),
      sex: _sex,
      activityLevel: _activity,
      goal: _goal,
    );
    await context.read<AppState>().saveProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 24),
                  Text('🦁', style: theme.textTheme.displayLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Lion Fitness',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tell us about yourself so we can calculate your health metrics.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name (optional)'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Height (cm)'),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              _numValidator(v, 100, 250, 'Height'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _weightCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Weight (kg)'),
                          keyboardType: TextInputType.number,
                          validator: (v) => _numValidator(v, 30, 300, 'Weight'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ageCtrl,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (v) => _numValidator(v, 13, 100, 'Age'),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<Sex>(
                    segments: const [
                      ButtonSegment(
                          value: Sex.male,
                          label: Text('Male'),
                          icon: Icon(Icons.male)),
                      ButtonSegment(
                          value: Sex.female,
                          label: Text('Female'),
                          icon: Icon(Icons.female)),
                    ],
                    selected: {_sex},
                    onSelectionChanged: (s) => setState(() => _sex = s.first),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ActivityLevel>(
                    initialValue: _activity,
                    decoration:
                        const InputDecoration(labelText: 'Activity level'),
                    items: [
                      for (final a in ActivityLevel.values)
                        DropdownMenuItem(value: a, child: Text(a.label)),
                    ],
                    onChanged: (a) =>
                        setState(() => _activity = a ?? _activity),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<FitnessGoal>(
                    initialValue: _goal,
                    decoration: const InputDecoration(labelText: 'Goal'),
                    items: [
                      for (final g in FitnessGoal.values)
                        DropdownMenuItem(value: g, child: Text(g.label)),
                    ],
                    onChanged: (g) => setState(() => _goal = g ?? _goal),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text('Start training'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
