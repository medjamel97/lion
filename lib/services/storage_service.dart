import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_log.dart';
import '../models/user_profile.dart';
import '../models/weight_entry.dart';
import '../models/workout_plan.dart';

/// Persistence abstraction. The app uses Firestore when Firebase is
/// configured, and falls back to on-device storage otherwise, so it always
/// works out of the box.
abstract class StorageService {
  String get backendName;

  Future<UserProfile?> loadProfile();
  Future<void> saveProfile(UserProfile profile);

  Future<WorkoutPlan?> loadPlan();
  Future<void> savePlan(WorkoutPlan plan);

  Future<List<SessionLog>> loadLogs();
  Future<void> saveLogs(List<SessionLog> logs);

  Future<String?> loadSpotifyUrl();
  Future<void> saveSpotifyUrl(String url);

  Future<List<WeightEntry>> loadWeightEntries();
  Future<void> saveWeightEntries(List<WeightEntry> entries);
}

// ─────────────────────────────────────────────────────────────────────
class LocalStorageService implements StorageService {
  static const _profileKey = 'lion_profile';
  static const _planKey = 'lion_plan';
  static const _logsKey = 'lion_logs';
  static const _spotifyKey = 'lion_spotify';
  static const _weightsKey = 'lion_weights';

  @override
  String get backendName => 'On-device storage';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<UserProfile?> loadProfile() async {
    final raw = (await _prefs).getString(_profileKey);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await (await _prefs).setString(_profileKey, jsonEncode(profile.toJson()));
  }

  @override
  Future<WorkoutPlan?> loadPlan() async {
    final raw = (await _prefs).getString(_planKey);
    if (raw == null) return null;
    return WorkoutPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> savePlan(WorkoutPlan plan) async {
    await (await _prefs).setString(_planKey, jsonEncode(plan.toJson()));
  }

  @override
  Future<List<SessionLog>> loadLogs() async {
    final raw = (await _prefs).getString(_logsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => SessionLog.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> saveLogs(List<SessionLog> logs) async {
    await (await _prefs)
        .setString(_logsKey, jsonEncode(logs.map((l) => l.toJson()).toList()));
  }

  @override
  Future<String?> loadSpotifyUrl() async =>
      (await _prefs).getString(_spotifyKey);

  @override
  Future<void> saveSpotifyUrl(String url) async {
    await (await _prefs).setString(_spotifyKey, url);
  }

  @override
  Future<List<WeightEntry>> loadWeightEntries() async {
    final raw = (await _prefs).getString(_weightsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => WeightEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> saveWeightEntries(List<WeightEntry> entries) async {
    await (await _prefs).setString(
        _weightsKey, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }
}

// ─────────────────────────────────────────────────────────────────────
class FirestoreStorageService implements StorageService {
  final String uid;
  final FirebaseFirestore _db;

  FirestoreStorageService({required this.uid, FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  @override
  String get backendName => 'Firebase (synced)';

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(uid);

  @override
  Future<UserProfile?> loadProfile() async {
    final snap = await _userDoc.get();
    final data = snap.data()?['profile'];
    if (data == null) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _userDoc.set({'profile': profile.toJson()}, SetOptions(merge: true));
  }

  @override
  Future<WorkoutPlan?> loadPlan() async {
    final snap = await _userDoc.get();
    final data = snap.data()?['plan'];
    if (data == null) return null;
    return WorkoutPlan.fromJson(_deepCast(data));
  }

  @override
  Future<void> savePlan(WorkoutPlan plan) async {
    await _userDoc.set({'plan': plan.toJson()}, SetOptions(merge: true));
  }

  @override
  Future<List<SessionLog>> loadLogs() async {
    final snap = await _userDoc.collection('logs').orderBy('date').get();
    return snap.docs.map((d) => SessionLog.fromJson(d.data())).toList();
  }

  @override
  Future<void> saveLogs(List<SessionLog> logs) async {
    final batch = _db.batch();
    final col = _userDoc.collection('logs');
    final existing = await col.get();
    final keep = logs.map((l) => l.id).toSet();
    for (final doc in existing.docs) {
      if (!keep.contains(doc.id)) batch.delete(doc.reference);
    }
    for (final log in logs) {
      batch.set(col.doc(log.id), log.toJson());
    }
    await batch.commit();
  }

  @override
  Future<String?> loadSpotifyUrl() async {
    final snap = await _userDoc.get();
    return snap.data()?['spotifyUrl'] as String?;
  }

  @override
  Future<void> saveSpotifyUrl(String url) async {
    await _userDoc.set({'spotifyUrl': url}, SetOptions(merge: true));
  }

  @override
  Future<List<WeightEntry>> loadWeightEntries() async {
    final snap = await _userDoc.get();
    final data = snap.data()?['weights'];
    if (data == null) return [];
    return (data as List)
        .map((e) => WeightEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> saveWeightEntries(List<WeightEntry> entries) async {
    await _userDoc.set(
      {'weights': entries.map((e) => e.toJson()).toList()},
      SetOptions(merge: true),
    );
  }

  /// Firestore returns nested maps as `Map<String, dynamic>` but nested lists
  /// keep their inner maps as `Map<dynamic, dynamic>`; normalize recursively.
  static Map<String, dynamic> _deepCast(dynamic value) {
    final map = Map<String, dynamic>.from(value as Map);
    map.updateAll((key, v) {
      if (v is Map) return _deepCast(v);
      if (v is List) {
        return v.map((e) => e is Map ? _deepCast(e) : e).toList();
      }
      return v;
    });
    return map;
  }
}

/// Signs in anonymously so each device gets a stable Firebase uid without
/// asking the user to create an account.
Future<String> ensureSignedIn() async {
  final auth = FirebaseAuth.instance;
  final existing = auth.currentUser;
  if (existing != null) return existing.uid;
  final cred = await auth.signInAnonymously();
  return cred.user!.uid;
}
