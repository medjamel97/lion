import 'package:flutter/foundation.dart';

import '../models/session_log.dart';
import '../models/user_profile.dart';
import '../models/weight_entry.dart';
import '../models/workout_plan.dart';
import '../services/health_calculator.dart';
import '../services/plan_validator.dart';
import '../services/storage_service.dart';

const kDefaultSpotifyUrl =
    'https://open.spotify.com/playlist/37i9dQZF1DX76Wlfdnj7AP'; // "Beast Mode"

class AppState extends ChangeNotifier {
  final StorageService storage;

  UserProfile? _profile;
  WorkoutPlan _plan = WorkoutPlan.empty();
  List<SessionLog> _logs = [];
  List<WeightEntry> _weights = [];
  String _spotifyUrl = kDefaultSpotifyUrl;
  bool _loaded = false;

  AppState({required this.storage});

  bool get isLoaded => _loaded;
  bool get hasProfile => _profile != null;
  UserProfile? get profile => _profile;
  WorkoutPlan get plan => _plan;
  List<SessionLog> get logs => List.unmodifiable(_logs);
  List<WeightEntry> get weightEntries => List.unmodifiable(_weights);
  String get spotifyUrl => _spotifyUrl;
  String get backendName => storage.backendName;

  HealthMetrics? get metrics =>
      _profile == null ? null : HealthCalculator.compute(_profile!);

  List<PlanAdvice> get planAdvice => PlanValidator.validate(_plan);

  Future<void> load() async {
    try {
      _profile = await storage.loadProfile();
      final plan = await storage.loadPlan();
      if (plan != null) _plan = plan;
      _logs = await storage.loadLogs();
      _weights = await storage.loadWeightEntries()
        ..sort((a, b) => a.date.compareTo(b.date));
      _spotifyUrl = await storage.loadSpotifyUrl() ?? kDefaultSpotifyUrl;
    } catch (e) {
      debugPrint('Failed to load saved data: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    final weightChanged = _profile?.weightKg != profile.weightKg;
    _profile = profile;
    notifyListeners();
    await storage.saveProfile(profile);
    // Every weight change becomes a data point on the progress chart.
    if (weightChanged || _weights.isEmpty) {
      await logWeight(profile.weightKg);
    }
  }

  /// Records today's weight (one entry per calendar day, newest wins).
  Future<void> logWeight(double weightKg) async {
    final entry = WeightEntry(date: DateTime.now(), weightKg: weightKg);
    _weights = [
      ..._weights.where((w) => w.dayKey != entry.dayKey),
      entry,
    ]..sort((a, b) => a.date.compareTo(b.date));
    // Keep the profile's current weight in sync with the latest entry.
    if (_profile != null && _profile!.weightKg != weightKg) {
      _profile = _profile!.copyWith(weightKg: weightKg);
      await storage.saveProfile(_profile!);
    }
    notifyListeners();
    await storage.saveWeightEntries(_weights);
  }

  Future<void> removeWeightEntry(WeightEntry entry) async {
    _weights =
        _weights.where((w) => w.dayKey != entry.dayKey).toList();
    notifyListeners();
    await storage.saveWeightEntries(_weights);
  }

  Future<void> savePlan(WorkoutPlan plan) async {
    _plan = plan;
    notifyListeners();
    await storage.savePlan(plan);
  }

  Future<void> updateDay(int index, DayPlan day) async {
    await savePlan(_plan.withDay(index, day));
  }

  Future<void> setSpotifyUrl(String url) async {
    _spotifyUrl = url;
    notifyListeners();
    await storage.saveSpotifyUrl(url);
  }

  // ── Session logging ────────────────────────────────────────────────
  bool isLoggedOn(DateTime date) {
    return _logs.any((l) =>
        l.date.year == date.year &&
        l.date.month == date.month &&
        l.date.day == date.day);
  }

  Future<void> logSession(SessionLog log) async {
    _logs = [..._logs, log];
    notifyListeners();
    await storage.saveLogs(_logs);
  }

  Future<void> removeLog(String id) async {
    _logs = _logs.where((l) => l.id != id).toList();
    notifyListeners();
    await storage.saveLogs(_logs);
  }

  /// Consecutive completed training days (rest days don't break the streak).
  int get streak {
    var count = 0;
    var day = DateTime.now();
    // Today only counts if already logged; start from yesterday otherwise.
    if (!isLoggedOn(day) && _plan.isTrainingDay(_plan.cycleIndexFor(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    for (var i = 0; i < 365; i++) {
      final isTraining = _plan.isTrainingDay(_plan.cycleIndexFor(day));
      if (isTraining) {
        if (isLoggedOn(day)) {
          count++;
        } else {
          break;
        }
      }
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  int get sessionsThisWeek {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return _logs
        .where((l) => !l.date.isBefore(weekStart))
        .length;
  }
}
