# ChitFlow – Digital Chit Fund Management System

A simple Flutter app (student-project style UI) for managing family/community chit funds.
Two roles: **Admin** (creates members & chits, updates monthly auctions, uploads auction PDFs)
and **Member** (views their chits, auction history, and downloads auction PDFs).

Built with: Flutter, Cloud Firestore, Firebase Storage, Hive (local cache), Provider.

---

## 0. What you need installed first

| Tool | Check with | Install from |
|---|---|---|
| Flutter SDK | `flutter --version` | https://docs.flutter.dev/get-started/install |
| Android Studio (or VS Code + Flutter/Dart plugins) | — | https://developer.android.com/studio |
| An emulator or a physical phone with USB debugging | `flutter devices` | — |
| Node.js (only needed for the Firebase CLI) | `node -v` | https://nodejs.org |

Run `flutter doctor` and fix anything marked with a red ✗ before continuing.

---

## 1. Get the project onto your machine

1. Download/copy the `chitflow` folder I generated onto your machine.
2. Open a terminal inside that folder.
3. This project currently contains only the `lib/` (Dart code) and `pubspec.yaml`.
   Flutter needs platform folders (`android/`, `ios/`, etc.) which are machine-specific,
   so generate them locally:

   ```bash
   flutter create . --org com.chitflow --project-name chitflow
   ```

   This safely fills in the missing `android/`, `ios/`, `web/` etc. folders **without**
   touching your existing `lib/` and `pubspec.yaml`.

4. Install dependencies:

   ```bash
   flutter pub get
   ```

---

## 2. Firebase Setup (you said you already have a Firebase account)

### Step 1 — Create a Firebase project
1. Go to https://console.firebase.google.com
2. Click **Add project** → give it a name, e.g. `chitflow-app` → finish the wizard.

### Step 2 — Enable Cloud Firestore
1. In the left sidebar: **Build → Firestore Database**.
2. Click **Create database**.
3. Choose **Start in test mode** (fine for a student project — lets you read/write for ~30 days without auth rules blocking you).
4. Pick a location close to you → **Enable**.

You do **not** need to manually create collections — the app creates `users` and `chits`
automatically the first time you use it. But if you want to see the structure, it will look like:

```
users/<phone_number>        -> { name, phone, password, role, createdAt }
chits/<autoId>               -> { chitName, totalAmount, totalMembers, totalMonths, members: {...}, createdDate }
chits/<autoId>/months/month_1 -> { auctionDate, auctionTime, chitValue, bidAmount, prizeAmount, winnerName, dividend, pdfUrl, updatedAt }
```

### Step 3 — Enable Firebase Storage (for auction PDFs)
1. Left sidebar: **Build → Storage**.
2. Click **Get started** → **Start in test mode** → choose the same location → **Done**.

### Step 4 — Set (relaxed) security rules for development

**Firestore rules** (Firestore Database → Rules tab):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**Storage rules** (Storage → Rules tab):
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```
⚠️ These rules allow anyone to read/write — perfectly fine for a student/demo project,
but **do not use this in a real production app**. Click **Publish** after pasting.

### Step 5 — Connect your Flutter app to this Firebase project

The easiest way is the **FlutterFire CLI**, which auto-generates `lib/firebase_options.dart`
for you (I've included a placeholder version — you must replace it using this step).

```bash
# 1. Install the Firebase CLI (one-time)
npm install -g firebase-tools

# 2. Log in
firebase login

# 3. Install the FlutterFire CLI (one-time)
dart pub global activate flutterfire_cli

# 4. From inside your chitflow project folder, run:
flutterfire configure
```

- It will list your Firebase projects → select the one you created (e.g. `chitflow-app`).
- Select the platforms you want (Android / iOS — pick at least Android).
- It automatically:
  - Overwrites `lib/firebase_options.dart` with your real project keys.
  - Registers an Android app in Firebase and downloads `google-services.json`
    into `android/app/`.
  - (For iOS) downloads `GoogleService-Info.plist` into `ios/Runner/`.

That's it — no manual Firebase config editing needed.

---

## 3. Create the first Admin account

The app has no built-in "sign up" for Admins (per the spec, there's exactly one Admin,
created manually) — you create it directly in Firestore:

1. Firebase Console → **Firestore Database** → **Start collection**.
2. Collection ID: `users`
3. Document ID: your admin phone number, e.g. `9999999999`
4. Add these fields:

   | Field | Type | Value |
   |---|---|---|
   | name | string | `Admin` |
   | phone | string | `9999999999` |
   | password | string | `admin123` |
   | role | string | `admin` |

5. Save.

Now you can log in to the app using **Admin → phone: 9999999999 → password: admin123**.

Member accounts don't need this manual step — the Admin creates them from inside the app
(Dashboard → "Member" floating button).

---

## 4. Run the app

Plug in a phone (USB debugging on) or start an emulator, then:

```bash
flutter devices        # confirm a device is detected
flutter run
```

---

## 5. How to use it

**As Admin:**
1. Log in with the admin account you created in Firestore.
2. Tap the **Member** button → create a few member accounts (name, phone, password).
3. Tap the **Chit** button → fill chit details → select members → **Create Chit**.
4. Tap a chit on the dashboard → open **Month 1** → fill auction details → upload a PDF → **Update**.
   Month 2 unlocks automatically once Month 1 is filled, and so on.

**As Member:**
1. Log out (top-right icon) or open a second device/emulator.
2. On the opening screen choose **Member**, log in with the phone/password the Admin gave you.
3. You'll only see chits you were added to. Tap a chit → tap a completed month → view details → **Download Auction PDF**.

---

## 6. Project structure

```
lib/
├── models/         # AppUser, ChitModel, MonthModel
├── services/        # firestore_service, hive_service, storage_service
├── providers/        # auth_provider, chit_provider (state management)
├── screens/
│   ├── opening/       # role selection screen
│   ├── login/         # shared login screen
│   ├── admin/          # dashboard, create member, create chit, month list, update auction
│   └── member/          # dashboard, view auction (read-only)
├── widgets/          # custom_button, custom_textfield, chit_card
├── utils/            # constants, validators
├── firebase_options.dart  # generated by `flutterfire configure`
└── main.dart
```

---

## 7. Notes / known limitations (student-project scope)

- Passwords are stored in plain text in Firestore for simplicity, as specified — this is
  **not secure** and shouldn't be used for a real money-related app without adding proper
  Firebase Authentication and hashing.
- Firestore/Storage rules above are wide open (`allow read, write: if true`) to keep setup
  simple. Tighten these before sharing the app publicly.
- Month "locking" logic: for Admin, a month unlocks once the previous month is filled in.
  For Members, a month is viewable only once the Admin has filled it in.

---

## 8. Troubleshooting

- **`flutter pub get` fails on Hive/build_runner versions** → run `flutter pub upgrade --major-versions`.
- **App crashes on startup with a Firebase error** → you likely skipped `flutterfire configure`,
  so `lib/firebase_options.dart` still has placeholder `REPLACE_ME` values.
- **PDF upload fails** → check Storage rules were published (Step 4 above) and that you're
  connected to the internet.
- **`flutter create .` complains the directory isn't empty** → that's expected/safe, it just
  fills in missing platform folders; your `lib/` and `pubspec.yaml` are untouched.
