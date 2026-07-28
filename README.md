# 🦁 Lion Fitness

A Flutter + Firebase app that organizes your workout sessions around **your own training/rest cycle**, tracks your body metrics, keeps your plan aligned with healthy training habits, and plays your Spotify workout soundtrack in-app.

## Features

### 🗓 Cycle-based scheduling
Define your training rhythm as a repeating pattern of training (`1`) and rest (`0`) days — exactly like `1010101` (every other day) or `1101101` (2 on / 1 off / 2 on / 2 off). Cycles can be 2–14 days long and repeat forever from your start date. Presets included:

| Preset | Pattern | Level |
|---|---|---|
| Full Body ×3 | `1010101` | Beginner |
| Upper / Lower | `1101101` | Intermediate |
| Push / Pull / Legs | `1110110` | Intermediate+ |
| Beginner ×2 + Cardio | `1001001` | Getting started |

### 💪 Muscle & exercise planning
For every training day, pick the target muscle groups and choose exercises from a built-in library of ~60 of the most well-known movements (bench press, squat, deadlift, pull-up, hip thrust…), each with hypertrophy-standard default sets, reps and rest times. Everything is editable.

### 🩺 Health metrics from your height/weight
Enter height, weight, age, sex, activity level and goal, and the app computes:
- **BMI** + WHO category and your **healthy weight range**
- **BMR** (Mifflin-St Jeor) and **TDEE** (maintenance calories)
- **Target calories** for your goal (lean bulk +300 / cut −500)
- **Daily protein** (1.6–2.2 g/kg — sports-nutrition consensus for muscle growth)
- **Daily water** (~35 ml/kg)

### 🧠 Built-in coach (world health guidelines)
The plan validator continuously checks your schedule against widely accepted guidance:
- WHO: 150–300 min moderate activity/week and strength training on **2+ days/week**
- **48h recovery** before hitting the same muscle again
- **10–20 hard sets per muscle per week** (flags junk volume above ~20)
- At least one full rest day; warns on 6+ consecutive training days

### 🎵 Spotify player
An embedded Spotify player (official Spotify embed — no API keys needed) with curated workout playlists, or paste any Spotify playlist/album/track/artist link.

### 📈 Tracking
Mark sessions done, keep a history, and watch your streak grow.

## Getting started

```bash
flutter pub get
flutter run
```

The app works **immediately** with on-device storage. To enable cloud sync:

## Firebase setup (optional but recommended)

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Anonymous** sign-in (Authentication → Sign-in method).
3. Create a **Cloud Firestore** database.
4. Run:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This regenerates `lib/firebase_options.dart` with your project keys.
5. In the generated file the app looks for `DefaultFirebaseOptions.isConfigured` — add `static const bool isConfigured = true;` to the generated class (the placeholder ships with `false` so the app can run without Firebase).
6. Recommended Firestore security rules (each anonymous user can only touch their own data):
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{uid}/{document=**} {
         allow read, write: if request.auth != null && request.auth.uid == uid;
       }
     }
   }
   ```

## Tech

- Flutter (Material 3, dark "lion" theme), `provider` for state
- `firebase_core` / `firebase_auth` (anonymous) / `cloud_firestore`, with a `shared_preferences` fallback behind a single `StorageService` interface
- `webview_flutter` + `url_launcher` for the Spotify embed
- Core logic (cycle math, health formulas, plan validation, Spotify URL parsing) covered by unit tests: `flutter test`

## Disclaimer

The guidance shown in the app (WHO activity levels, protein ranges, recovery windows) is general educational information, not medical advice.
