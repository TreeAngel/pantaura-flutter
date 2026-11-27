# AGENT GUIDELINES & PROJECT CONTEXT: PANTAURA

Panduan kerja, standar arsitektur, tech stack, dan instruksi khusus pengembangan aplikasi **Pantaura** (sebelumnya SiagaKita).

---

## 1. Aturan Komunikasi & Kerja AI Assistant (User Rules)

* **Jawaban Langsung & Ringkas**:
  - Jika pengguna hanya memberikan pertanyaan, jawab langsung, to the point, dan hanya menjawab apa yang ditanyakan tanpa penjelasan panjang yang bertele-tele.
* **Penggunaan Skill Otomatis**:
  - Wajib secara otomatis menerapkan instruksi dan best practices dari `.agent/skills/dart-flutter-patterns/SKILL.md` setiap kali mengerjakan kode Dart & Flutter di proyek ini tanpa perlu instruksi implisit/eksplisit.
* **State Management**:
  - Seterusnya selalu gunakan **Riverpod** (`flutter_riverpod` & `riverpod_lint`) untuk state management di seluruh fitur aplikasi.
* **Sinkronisasi Desain (Stitch)**:
  - Selalu sinkronkan dan jadikan desain dari project Stitch **"Pantaura Flutter"** (`projects/13707441510623217137`) serta [DESIGN.md] sebagai acuan visual utama (WCAG AAA, Elder-Friendly, touch target min 48-56px).
* **Routing Menggunakan go_router**:
  - Untuk routing project flutter selalu gunakan dependensi (`go_router`).

---

## 2. Tech Stack & Environment

* **Platform**: Flutter (Mobile Android & iOS)
* **SDK Constraint**: Dart `^3.14.0` / Flutter SDK
* **Gradle & Build Toolchain Android**:
  - **Gradle Version**: `9.5.0` (dikonfigurasi pada `gradle-wrapper.properties`)
  - **Android Gradle Plugin (AGP)**: `9.3.1` (dikonfigurasi pada `settings.gradle.kts`)
  - **Kotlin Version**: `2.4.20`
  - **CMake SDK**: `3.22.1` (diperlukan oleh paket FFI/JNI)
  - **Incremental Build**: `kotlin.incremental=false` di `gradle.properties` (untuk menghindari file-lock cache bug `.tab` di Windows).

---

## 3. Dependencies Utama (`pubspec.yaml`)

### **State Management & Architecture**
* `flutter_riverpod: ^3.5.0` — State management modern (Notifier / AsyncNotifier).
* `riverpod_lint: ^3.2.0` — Linter khusus Riverpod untuk menjaga best practice.

### **Networking & API**
* `dio: ^5.11.1` — HTTP Client dengan interceptor untuk token auth, header JSON, dan custom exception mapping.
* **Base URL Production**: `https://pantaura.mizaru.my.id/api/v1`
* **Dokumentasi API Lengkap**: Tertera pada [API.md].

### **Navigation & UI**
* `go_router: ^18.1.4` — Declarative routing dengan auth guards.
* **Font lokal** (tanpa `google_fonts`) — Plus Jakarta Sans (Headlines) & Inter (Body/Labels) dari folder `fonts/`, dideklarasikan di `pubspec.yaml`, dipakai lewat `AppTypography`.
* `material_ui: ^1.11.1` — Komponen UI Material.
* `flutter_svg: ^2.5.0` — Rendering aset ikon & ilustrasi SVG.

### **Device, Maps & Hardware**
* `flutter_osm_plugin: ^4.1.0` — Visualisasi peta OpenStreetMap native untuk preview & peta interaktif.
* `geolocator: ^14.1.2` — Deteksi koordinat GPS pengguna untuk laporan darurat & geofencing.
* `image_picker: ^1.2.4` — Pengambilan foto & video bukti laporan insiden / resolusi bencana.
* `flutter_image_compress_lite: ^3.0.1` — Kompresi gambar sebelum upload laporan/resolusi.

---

## 4. Struktur Folder & Arsitektur (`lib/`)

Menerapkan layered architecture berbasis fitur (*Feature-First*):

```
lib/
├── core/
│   ├── models/           # Objek data model & serialisasi JSON (User, Incident, Report, dll.)
│   ├── network/          # ApiClient (Dio), ApiConfig, ApiException
│   ├── services/         # Layer komunikasi HTTP per modul (AuthService, IncidentService, dll.)
│   ├── theme/            # Token desain (AppColors, AppTypography, AppSpacing, AppTheme)
│   ├── utils/            # Helper & validator (AuthValidators, Formatters)
│   ├── widgets/          # Komponen global reusable (AppButton, IncidentStatusChip)
│   └── providers.dart    # Dependency Injection Riverpod untuk service & client
├── features/
│   ├── splash/           # Splash screen dengan simulasi live sensor check
│   ├── auth/             # Login, Registrasi, AuthNotifier, AuthState
│   ├── incidents/        # Daftar bencana, detail insiden, peta bencana
│   ├── reports/          # Form buat laporan & riwayat laporan
│   ├── resolutions/      # Pengajuan bukti penanganan/pemulihan bencana
│   └── safe_zones/       # Daftar titik evakuasi dan posko siaga
└── main.dart             # Entry point aplikasi & ProviderScope
```

---

## 5. Flutter & Dart Best Practices

1. **State Management Riverpod**:
   - Gunakan `Notifier` / `AsyncNotifier` untuk mengelola state mutable.
   - Gunakan sealed class untuk state (misal `Loading`, `Success`, `Error`).
   - Hindari logic bisnis di dalam widget (`ConsumerStatefulWidget` / `ConsumerWidget` hanya menangani UI & interaksi).
2. **Null Safety & Dart 3 Patterns**:
   - Hindari bang operator (`!`), gunakan fallback `??` atau pattern matching.
   - Gunakan destructuring dan switch expressions untuk memproses variasi data enum/status.
3. **Validasi Input**:
   - Selalu lakukan validasi email (format RFC regex) dan kata sandi (minimal 12 karakter dengan setidaknya 1 huruf kapital dan 1 huruf kecil serta 1 karakter khusus) sebelum request dikirim ke backend.
4. **Networking**:
   - Tangani error menggunakan `ApiException` terpusat agar pesan error backend selalu ramah pengguna.
   - Lampirkan token Sanctum secara otomatis via Dio interceptor.
5. **Aksesibilitas (WCAG AAA)**:
   - Target sentuh minimal 48dp (tombol utama 54-56dp ramah lansia).
   - Kontras warna teks dan latar belakang harus memenuhi rasio kontras tinggi sesuai panduan desain.
6. **Media Pengambilan Foto/Video**:
   - Gunakan `image_picker` untuk mengambil foto/video dan untuk memilih media dari galeri.
   - Gunakan `flutter_image_compress_lite` untuk kompresi gambar sebelum upload.
   - Saat pengambilan media menggunakan dengan camera, pastikan untuk menggunakan resolusi yang optimal untuk upload.
   - File gambar sementara disimpan dicache sampai laporan media diupload/keluar dari screen terkait, setelah itu hapus file cache tersebut.
   - Handling MainActivity destruction (`image_picker`)
When under high memory pressure the Android system may kill the MainActivity of the application using the image_picker. On Android the image_picker makes use of the default Intent.ACTION_GET_CONTENT or MediaStore.ACTION_IMAGE_CAPTURE intents. This means that while the intent is executing the source application is moved to the background and becomes eligible for cleanup when the system is low on memory. When the intent finishes executing, Android will restart the application. Since the data is never returned to the original call use the ImagePicker.retrieveLostData() method to retrieve the lost data. For example:

```python
Future<void> getLostData() async {
  final picker = ImagePicker();
  final LostDataResponse response = await picker.retrieveLostData();
  if (response.isEmpty) {
    return;
  }
  final List<XFile>? files = response.files;
  if (files != null) {
    _handleLostFiles(files);
  } else {
    _handleError(response.exception);
  }
}
```

This check should always be run at startup in order to detect and handle this case.