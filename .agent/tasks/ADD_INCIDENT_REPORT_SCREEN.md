# TASK: Implementasi Halaman Tambah Laporan Insiden

**Screen**: Tambah Laporan Insiden — Pantaura Flutter  
**Stitch Project**: `projects/13707441510623217137`  
**Design lokal**: `.stitch_pantaura_flutter/tambah_laporan_insiden_siagakita/code.html` + `screen.png`  
**Route**: nested dari detail insiden → `/incidents/:id/report` (`AppRoutes.incidentAddReportPath`)  
**Kembali**: `context.pop()` ke detail insiden setelah manual close **atau** upload berhasil  
**Target file**: `lib/features/incidents/add_report/`

---

## Fase 0: Persiapan & Desain

- [x] Baca `AGENT.md` dan internalisasi rules (Riverpod, go_router, Riverpod lint, WCAG AAA, touch target 48–56dp)
- [x] **Cek design Stitch lokal terlebih dahulu**: baca `code.html` lalu lihat `screen.png` pada folder design di atas. **Jangan akses MCP Stitch** kecuali user memerintahkan eksplisit
- [x] Baca `lib/features/incidents/incident_detail_screen.dart` — sumber data insiden induk & titik berangkat CTA "Tambah Laporan"
- [x] Baca `lib/features/incidents/incident_detail_state.dart` + `incident_detail_notifier.dart` untuk pola `AsyncNotifier` Riverpod 3.5
- [x] Baca `lib/core/models/api_models.dart` — `IncidentDetailModel`, `ReportModel`, `MediaModel`
- [x] Baca `lib/core/services/incident_service.dart` — `addIncidentReport(...)` (POST `/incidents/{incident}/reports`, multipart `latitude`, `longitude`, `description`, `media[]`)
- [x] Baca `lib/core/routing/app_router.dart` + `app_routes.dart` (jangan hapus `_PlaceholderDetailScreen` / `_PlaceholderTabScreen`)
- [x] Baca `lib/core/theme/` — AppColors, AppTypography, AppSpacing, AppRadius, AppShadows
- [x] Baca `lib/features/home/home_screen.dart` untuk pola penempatan pengecekan permission saat masuk home

---

## Fase 1: Permission Handler (prasyarat, kerjakan lebih dulu)

- [x] Buat `lib/core/services/permission_service.dart`
  - [x] Method `requestLocationPermission()`: `Permission.locationWhenInUse` → `serviceStatus.isEnabled` + `.isGranted`
  - [x] Method `requestCameraPermission()`: `Permission.camera`
  - [x] Method `requestGalleryPermission()`: `Permission.photos` (Android 13+) / `Permission.storage` (fallback Android ≤12)
  - [x] Method `ensureAll()`: dipanggil sekali setiap kali memasuki home screen, hasil di-cache di provider agar tidak meminta ulang dalam sesi yang sama
  - [x] Tangani `PermissionStatus.permanentlyDenied` → `openAppSettings()` dengan dialog penjelasan
- [x] Daftarkan provider di `lib/core/providers.dart` (`permissionServiceProvider`)
- [x] Di `lib/features/home/home_screen.dart`: panggil `ensureAll()` saat masuk home (initState / saat auth menjadi `AuthAuthenticated`); **jangan blokir home** jika ditolak, hanya simpan statusnya
- [x] Cek ulang `android/app/src/main/AndroidManifest.xml` — tambahkan bila belum ada:
  - [x] `android.permission.CAMERA`
  - [x] `android.permission.READ_MEDIA_IMAGES` (API 33+)
  - [x] `android.permission.READ_EXTERNAL_STORAGE android:maxSdkVersion="32"` (legacy)
  - [x] Evaluasi `ACCESS_FOREGROUND_LOCATION` (bukan permission Android standar) — dihapus bersama `<service MyNavigationService ...>` yang tidak terpakai
  - [x] Pertahankan `INTERNET`, `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`; evaluasi `ACCESS_BACKGROUND_LOCATION` (dihapus karena tidak dipakai)
- [x] Pastikan image picker & geolocator memakai permission service sebelum dipanggil (jangan request permission di dalam `build()`)

---

## Fase 2: State & Data Layer

- [x] Buat `lib/features/incidents/add_report/add_report_state.dart`
  - [x] `AddReportData` immutable: `incident` (`IncidentDetailModel`), `userPosition` (`Position?`), `distanceMeters` (`double?`), `isLocationValid` (`bool`, default `false` = jarak ≤ 500 m), `mediaFiles` (`List<XFile>`), `description` (`String`), `isSubmitting` (`bool`), `errorMessage` (`String?`)
  - [x] Method `copyWith`
  - [x] Konstanta `quickTextsByDisaster`: `flood`, `earthquake`, `landslide`, `fire` (list teks instan, ≤ 6 item per jenis)
- [x] Buat `lib/features/incidents/add_report/add_report_notifier.dart`
  - [x] `AddReportNotifier extends AsyncNotifier<AddReportData>` dengan argumen `incidentId` lewat konstruktor, didaftarkan dengan `AsyncNotifierProvider.family`
  - [x] `build()`: ambil `IncidentDetailModel` dari `incidentDetailProvider(incidentId)`, inisialisasi state
  - [x] `refreshLocation()`: cek permission lokasi → `Geolocator.getCurrentPosition()` → hitung jarak ke lat/lng insiden (Haversine via `Geolocator.distanceBetween`, meter) → update `userPosition`, `distanceMeters`, `isLocationValid`
  - [x] `addMedia(List<XFile>)`, `removeMedia(int index)` — maksimal 5 file
  - [x] `appendQuickText(String text)`: sisipkan ke `description` bila belum ada, batasi 500 karakter
  - [x] `submit()`: validasi lokasi + ≥1 foto + deskripsi tidak kosong → `incidentService.addIncidentReport(latitude, longitude, description, mediaFiles)` → sukses: invalidate `incidentDetailProvider(incidentId)`
- [x] Jarak 500 m (`kMaxReportRadiusMeters`) menjadi satu-satunya sumber kebenaran validasi posisi

---

## Fase 3: Screen & Widget (urutan atas → bawah sesuai `code.html`)

- [x] Buat `lib/features/incidents/add_report/add_report_screen.dart`
  - [x] `AddReportScreen extends ConsumerStatefulWidget` dengan `final String incidentId`
  - [x] Saat screen selesai dimuat (`initState` + `addPostFrameCallback`) panggil `refreshLocation()` otomatis
  - [x] Semua widget turunan diletakkan di `lib/features/incidents/add_report/widgets/`

### 3.1 — AppBar

- [x] Widget `AddReportAppBar` — back arrow `context.pop()`, judul "Tambah Laporan Insiden", subjudul "Pantaura Darurat" dengan ikon verified, avatar kanan
- [x] Tombol back minimum 48×48dp

### 3.2 — Card Ringkasan Insiden (mewarisi data detail)

- [x] Widget `IncidentSummaryCard`
  - [x] Label "Menambah Laporan Pada Insiden" + chip status "Terkonfirmasi Aktif" (`IncidentStatusChip`)
  - [x] Judul insiden = `incident.title`, alamat = `incident.address` (fallback koordinat)
  - [x] Kotak informasi: "Laporan Anda akan digabungkan ke rantai data insiden ini …"
  - [x] Data diambil dari `incidentDetailProvider`, bukan hardcode

### 3.3 — Section Posisi & Peta Statis

- [x] Widget `LocationSection`
  - [x] Header bernomor "1" + judul "Posisi Anda Saat Ini" + chip "Wajib"
  - [x] Chip status hijau "Dalam Radius Aman Insiden" + teks "Berjarak ~X meter dari titik utama (Maks. 500m)"; merah bila tidak valid; teks jarak merah bila ≤ 500m (radius bencana) dan hijau bila > 500m
  - [x] `FlutterMap` statis: `InteractionOptions(flags: InteractiveFlag.none)`, tinggi 176dp
  - [x] Dua pin: merah "Titik Utama" di koordinat insiden (icon sesuai jenis bencana; flood, earthquake, landslide, fire), biru "Posisi Anda (~Xm)" di koordinat user
  - [x] Overlay koordinat GPS di pojok kiri bawah
  - [x] Tombol "Segarkan GPS" (tinggi ≥48dp): minta lokasi terbaru lalu refresh peta
  - [x] Teks penjelas: "Otomatis mengunci koordinat GPS …"

### 3.4 — Section Foto Bukti

- [x] Widget `EvidencePhotoSection`
  - [x] Header bernomor "2" + "Bukti Kondisi Terbaru" + chip "Wajib (Min. 1 Foto)"
  - [x] Dua tombol aksi "Ambil Foto" (kamera) & "Pilih Galeri" (image_picker) — tinggi ≥54dp
  - [x] Galeri thumbnail **scroll horizontal** di dalam card: `SingleChildScrollView(scrollDirection: Axis.horizontal)` + `Row`, `clipBehavior: Clip.antiAlias`
  - [x] Maksimal 5 foto; tiap thumbnail punya tombol hapus; slot "+ Tambah Foto (Maks. 5)"

### 3.5 — Section Deskripsi & Chip Cepat

- [x] Widget `DescriptionSection`
  - [x] Header bernomor "3" + "Deskripsi Perkembangan" + chip "Wajib"
  - [x] Chip cepat **memakai gaya desain lapor kondisi pulih** (`surfaceContainerLow`, rounded-lg, teks `+ …`)
  - [x] Daftar teks instan per jenis bencana (`flood`, `earthquake`, `landslide`, `fire`)
  - [x] Tap chip → `appendQuickText()` ke textarea, hindari duplikat
  - [x] Textarea 5 baris, `maxLength: 500`, counter "X / 500"

### 3.6 — Sticky CTA

- [x] Widget `SubmitReportBar` — tombol "Kirim Laporan Tambahan" tinggi 54dp, loading saat `isSubmitting`, teks penenang di bawahnya
- [x] Sukses → `ref.invalidate(incidentDetailProvider(incidentId))` lalu `context.pop()` kembali ke detail insiden
- [x] Gagal → snackbar memakai `ApiException.message`

---

## Fase 4: Routing

- [x] Tambah `AppRoutes.incidentAddReportPath = '/incidents/:id/report'` dan helper `incidentAddReport(String id)` di `app_routes.dart`
- [x] Daftarkan `GoRoute` di `app_router.dart` dengan `builder` → `AddReportScreen(incidentId: state.pathParameters['id'] ?? '')`
- [x] CTA "Tambah Laporan" di detail insiden → `context.push(AppRoutes.incidentAddReport(data.incident.id), extra: data.incident)`
- [x] Pastikan back / sukses kembali ke detail insiden; placeholder lama tidak dihapus

---

## Fase 5: Validasi & Quality

- [x] **Cek ulang design lokal** (`code.html` + `screen.png`) sebelum implementasi; tanpa akses MCP Stitch
- [x] `analyze_files` → `No errors` pada seluruh file baru dan file yang diubah
- [x] Semua touch target ≥ 48dp (CTA 54dp)
- [x] Tidak ada bang operator (`!`) di kode baru
- [x] Semua widget berupa class terpisah di folder `widgets/`, bukan method yang return Widget
- [x] `const` digunakan di mana memungkinkan
- [x] Tidak ada overflow pada galeri horizontal & textarea saat keyboard muncul

---

## Checklist Progress Ringkas

| Fase | Status |
|------|--------|
| 0 — Persiapan & desain lokal | ✅ Selesai |
| 1 — Permission handler & manifest | ✅ Selesai |
| 2 — State & notifier | ✅ Selesai |
| 3 — Screen & widgets | ✅ Selesai |
| 4 — Routing nested | ✅ Selesai |
| 5 — Validasi & quality | ✅ Selesai |

---

## Catatan Implementasi

- Riverpod 3.5: gunakan `AsyncNotifier` + argumen konstruktor, bukan `FamilyAsyncNotifier`.
- Peta memakai `NetworkTileProvider` default; **jangan** memanggil `BuiltInMapCachingProvider.getOrCreateInstance()` di dalam `build()` (menyebabkan error JNI `path_provider`, lihat `.log/debugconsole.log`).
- Chip cepat sengaja mengikuti gaya screen **lapor kondisi pulih** sesuai instruksi, bukan gaya pill pada `code.html` screen ini.
- Permission lokasi & media dicek setiap kali masuk home screen, bukan hanya saat membuka form.
