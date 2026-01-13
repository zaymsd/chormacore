---
description: How to implement Firebase Authentication for login and register
---

# Firebase Authentication Implementation Workflow

## Prerequisites

1. Pastikan Flutter SDK sudah terinstall dengan versi terbaru
2. Memiliki akun Google dan akses ke Firebase Console
3. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

---

## Step 1: Create Firebase Project

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik "Add Project" atau "Create Project"
3. Masukkan nama project (contoh: "ChormaCore")
4. Enable/Disable Google Analytics sesuai kebutuhan
5. Tunggu project selesai dibuat

---

## Step 2: Enable Email/Password Authentication

1. Di Firebase Console, pilih project yang baru dibuat
2. Navigasi ke **Build > Authentication**
3. Klik tab **Sign-in method**
4. Klik **Email/Password**
5. Toggle **Enable** ke ON
6. Klik **Save**

---

## Step 3: Configure Firebase for Flutter

// turbo
1. Buka terminal di root project Flutter:
```bash
cd d:\UTB\semester 5\pemrograman mobile 2\UAS\chormacore
```

2. Run FlutterFire CLI untuk konfigurasi otomatis:
```bash
flutterfire configure
```

3. Pilih project Firebase yang sudah dibuat
4. Pilih platform yang diinginkan (android, ios, web)
5. File `lib/firebase_options.dart` akan di-generate otomatis
6. File `android/app/google-services.json` akan di-download otomatis (Android)
7. File `ios/Runner/GoogleService-Info.plist` akan di-download otomatis (iOS)

---

## Step 4: Add Firebase Dependencies

// turbo
1. Tambahkan dependencies di `pubspec.yaml`:
```bash
flutter pub add firebase_core firebase_auth cloud_firestore
```

2. Get dependencies:
```bash
flutter pub get
```

---

## Step 5: Create Firebase Auth Service

1. Buat file baru: `lib/data/services/firebase_auth_service.dart`
2. Implementasikan methods:
   - `signInWithEmailAndPassword(email, password)`
   - `createUserWithEmailAndPassword(email, password)`
   - `signOut()`
   - `getCurrentUser()`
   - `authStateChanges()`

---

## Step 6: Update User Model

1. Buka `lib/data/models/user_model.dart`
2. Tambahkan field `firebaseUid`
3. Tambahkan factory method `fromFirebaseUser()`

---

## Step 7: Update User Repository

1. Buka `lib/data/repositories/user_repository.dart`
2. Ganti operasi SQLite dengan Firestore
3. Update CRUD operations untuk Firestore collection 'users'

---

## Step 8: Update Auth Provider

1. Buka `lib/features/auth/providers/auth_provider.dart`
2. Inject `FirebaseAuthService`
3. Update `login()`, `register()`, `logout()` methods
4. Update `initialize()` untuk listen auth state changes

---

## Step 9: Update Login & Register Pages

1. Update error handling untuk Firebase exceptions
2. (Optional) Tambahkan "Lupa Password" di Login page
3. (Optional) Tambahkan email verification flow di Register page

---

## Step 10: Update main.dart

1. Import Firebase packages:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
```

2. Initialize Firebase di `main()`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ... rest of initialization
  runApp(const ChromaCoreApp());
}
```

---

## Step 11: Test the Implementation

// turbo
1. Run aplikasi:
```bash
flutter run
```

2. Test registration dengan email baru
3. Test login dengan akun yang sudah dibuat
4. Test logout
5. Verifikasi di Firebase Console > Authentication > Users

---

## Troubleshooting

### Android Build Issues
Jika ada error saat build Android:
1. Pastikan `minSdkVersion` di `android/app/build.gradle` minimal 21
2. Enable multidex jika diperlukan

### iOS Build Issues
Jika ada error saat build iOS:
1. Pastikan `ios/Podfile` memiliki minimum deployment target iOS 13.0
2. Run `cd ios && pod install`

### Web Issues
Jika menggunakan platform web:
1. Pastikan Firebase web config sudah ditambahkan di `web/index.html`
