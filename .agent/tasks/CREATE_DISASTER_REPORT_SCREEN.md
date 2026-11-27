# TASK: Implementasi Halaman Buat Laporan Bencana

**Screen**: Buat Laporan Bencana — Pantaura Flutter  
**Stitch Project**: `projects/13707441510623217137`  
**Design lokal**: `.stitch_pantaura_flutter/buat_laporan_bencana_siagakita/code.html` + `screen.png`  
**Route**: `AppRoutes.createReport` (`/report/create`) — menggantikan `_PlaceholderDetailScreen` di `app_router.dart`  
**Target file**: `lib/features/reports/create/`

---

## Fase 0: Persiapan & Desain

- [x] Baca `AGENT.md` dan internalisasi rules (Riverpod 3.5, go_router, permission handler, WCAG AAA, touch target 48–56dp)
- [x] **Cek design Stitch lokal terlebih dahulu**: `code.html` lalu `screen.png`. **Jangan akses MCP Stitch** kecuali diperintahkan
- [x] Baca `lib/core/routing/app_router.dart` — `AppRoutes.createReport` masih memakai `_PlaceholderDetailScreen`; ganti dengan screen ini, jangan hapus placeholder itu
- [x] Baca `API.md` bagian `POST /reports` (field: `disaster_type`, `latitude`, `longitude`, `description`, `address`, `media[]`)
- [x] Baca `lib/core/services/report_service.dart` — `createReport(...)`
- [x] Baca `lib/core/services/permission_service.dart` + `permissionServiceProvider` di `core/providers.dart`
- [x] Baca `lib/features/incidents/add_report/widgets/location_section.dart` — pola `flutter_osm_plugin`
- [x] Baca `lib/features/incidents/add_report/add_report_state.dart` — `kMaxReportMediaCount`, `kMaxReportDescriptionLength`, `quickTextsByDisaster`, `getQuickTextsForDisaster()` (dipakai ulang untuk foto & deskripsi)
- [x] Baca `lib/features/incidents/add_report/widgets/` — pola galeri horizontal & chip cepat
- [x] Baca `lib/core/theme/` — AppColors, AppTypography, AppSpacing, AppRadius, AppShadows

---

## Fase 1: State & Data Layer

- [x] Buat `lib/features/reports/create/create_report_state.dart`
  - [x] `CreateReportData` immutable: `disasterType` (`String`, default `'flood'`), `pin` (`GeoPoint`), `address` (`String`), `mediaFiles` (`List<XFile>`), `description` (`String`), `isLocating` (`bool`), `isSubmitting` (`bool`)
  - [x] Konstanta debug: `GeoPoint(latitude: -6.19099, longitude: 106.84264)` sebagai lokasi awal
  - [x] Method `copyWith`
- [x] Buat `lib/features/reports/create/create_report_notifier.dart`
  - [x] `CreateReportNotifier extends AsyncNotifier<CreateReportData>` + `AsyncNotifierProvider` (tanpa family)
  - [x] `build()`: posisi awal = konstanta debug (bukan langsung GPS agar cepat tampil)
  - [x] `refreshLocation()`: permission lokasi → `Geolocator.getCurrentPosition()` (timeout 8s) → update pin; gagal → tetap koordinat debug
  - [x] `movePin(GeoPoint point)`: dipanggil saat user menggeser peta / long-press
  - [x] `setAddress(String)`, `setDisasterType(String)`, `addMedia(List<XFile>)`, `removeMedia(int)` (maks 5), `appendQuickText(String)` (maks 500 karakter, hindari duplikat)
  - [x] `submit()`: validasi jenis + ≥1 foto + deskripsi → `reportService.createReport(...)`; sukses → invalidate `homeNotifierProvider` & `mapProvider`, lalu `context.pop()`

---

## Fase 2: Screen & Widget (urutan atas → bawah sesuai `code.html`)

- [x] Buat `lib/features/reports/create/create_report_screen.dart` (`ConsumerStatefulWidget`)
  - [x] Semua widget turunan di `lib/features/reports/create/widgets/`
  - [x] `MapController` dengan `initPosition` = koordinat debug
  - [x] Permission lokasi diminta saat screen dibuka (bukan di `build()`)

### 2.1 — Banner Urgensi

- [x] Widget `CreateReportUrgencyBanner` — "Laporan Cepat Siaga", chip "< 1 Menit", narasi, baris merah "Darurat Jiwa? Hubungi 112" → pakai dialog darurat 112 yang sama dengan home

### 2.2 — Section 1: Jenis Kejadian

- [x] Widget `DisasterTypeSelector`
  - [x] Grid 2 kolom, 4 kartu min tinggi 104dp: Banjir (`flood`), Gempa Bumi (`earthquake`), Tanah Longsor (`landslide`), Kebakaran (`fire`)
  - [x] Kartu terpilih: `surfaceTintIce` + checkmark; ikon & subtitle sesuai desain
  - [x] Tap → `setDisasterType(...)`

### 2.3 — Section 2: Lokasi Kejadian (peta interaktif + pin)

- [x] Widget `LocationPickerSection`
  - [x] Header bernomor "2" + chip "Wajib"
  - [x] `OSMFlutter` interaktif (tinggi ±192dp), koordinat awal `(-6.19099, 106.84264)`
  - [x] Pin otomatis di posisi user setelah `refreshLocation()`; sebelum ada GPS pakai koordinat debug
  - [x] **User dapat menggerakan pin**: pin mengikuti center peta saat peta digeser (`onMapMoved`) atau ditempatkan via `onGeoPointLongPress`; sinkron ke `pin` state
  - [x] Tombol "GPS Akurat" → `refreshLocation()` + `mapController.moveTo(...)`
  - [x] Teks panduan "Geser peta untuk menyesuaikan titik"
  - [x] Card detail lokasi: alamat terdeteksi, akurasi, koordinat, dan tombol **"Ketik Alamat Patokan Manual"** → `TextField` alamat → `setAddress(...)`
  - [x] Alamat manual wajib bisa diisi bila reverse geocode tidak tersedia

### 2.4 — Section 3: Bukti Foto (sama seperti tambah laporan insiden)

- [x] Widget `ReportEvidenceSection` — **reuse pola** `EvidencePhotoSection` dari tambah laporan insiden
  - [x] Dua tombol "Buka Kamera" / "Pilih Galeri" (permission camera & gallery)
  - [x] Galeri thumbnail scroll **horizontal di dalam card**, `clipBehavior: Clip.antiAlias`, tidak overflow
  - [x] Maks 5 foto, tiap thumbnail ada tombol hapus, slot "+ Tambah (Maks 5)"
  - [x] Jangan tampilkan keterangan kompresi cerdas

### 2.5 — Section 4: Deskripsi Singkat (sama seperti tambah laporan insiden)

- [x] Widget `ReportDescriptionSection` — **reuse pola** `DescriptionSection` dari tambah laporan insiden
  - [x] Chip cepat dari `getQuickTextsForDisaster(disasterType)` (4 jenis bencana)
  - [x] Tap chip → `appendQuickText()`
  - [x] Textarea 4 baris, counter `X / 500 karakter`

### 2.6 — Sticky CTA

- [x] Widget `SubmitReportBar` — tombol "Kirim Laporan Bencana Sekarang" 56dp, loading saat submit
- [x] Sukses → invalidate provider + `context.pop()` kembali ke home

---

## Fase 3: Routing

- [x] Di `app_router.dart`, ganti `_PlaceholderDetailScreen(title: 'Buat Laporan Bencana')` dengan `const CreateReportScreen()`
- [x] Bottom nav center FAB "Lapor" (`PantauraBottomNav`) sudah mengarah ke `AppRoutes.createReport` — pastikan tidak diubah
- [x] `_PlaceholderDetailScreen` tidak dihapus (masih dipakai Placeholder lain bila ada)

---

## Fase 4: Validasi & Quality

- [x] Cek ulang `code.html` + `screen.png` sebelum MCP Stitch (MCP hanya jika diperintahkan)
- [x] `flutter analyze` → 0 error pada file baru
- [x] Peta interaktif: pin awal di `(-6.19099, 106.84264)`, bisa digeser user, tombol GPS bekerja
- [x] Foto & deskripsi identik perilakunya dengan tambah laporan insiden
- [x] Touch target ≥ 48dp, tidak ada overflow pada grid kategori & galeri horizontal
- [x] Tidak ada bang operator (`!`) di kode baru; widget berupa class terpisah; `const` digunakan

---

## Checklist Progress Ringkas

| Fase | Status |
|------|--------|
| 0 — Persiapan & desain lokal | ✅ Selesai |
| 1 — State & notifier | ✅ Selesai |
| 2 — Screen & widgets | ✅ Selesai |
| 3 — Routing | ✅ Selesai |
| 4 — Validasi & quality | ✅ Selesai (`flutter analyze` bersih pada file fitur) |

---

## Catatan Implementasi

- Gunakan `flutter_osm_plugin` (`GeoPoint`, `OSMFlutter`, `MapController`), **bukan** `flutter_map`/`latlong2`.
- Koordinat debug dipakai sebagai fallback agar UI tetap terisi saat GPS ditolak / emulator tanpa lokasi.
- Foto & deskripsi menyalin perilaku task `ADD_INCIDENT_REPORT_SCREEN.md`, termasuk batas 5 foto dan 500 karakter.
- `ref.listen` harus di dalam `build()` (Riverpod 3), bukan `initState()`.
- Dialog 112 sebaiknya diekstrak ke widget bersama agar home & screen ini identik.

---

## Catatan Implementasi Aktual

- File dibuat: `lib/features/reports/create/{create_report_state,create_report_notifier,create_report_screen}.dart` dan `widgets/{create_report_app_bar,create_report_urgency_banner,disaster_type_selector,location_picker_section,report_evidence_section,report_description_section,submit_report_bar}.dart`.
- Dialog 112 diekstrak ke `lib/core/widgets/emergency_112_dialog.dart`; `home_screen.dart` kini memanggil helper tersebut (perilaku identik).
- `app_router.dart`: `AppRoutes.createReport` → `const CreateReportScreen()`. `_PlaceholderDetailScreen` sengaja dipertahankan sesuai instruksi, sehingga analyzer memberi warning `unused_element` (tidak error).
- `GeoPoint` bukan konstanta Dart: `kCreateReportDemoPin` dideklarasikan `final`, dan state memakai factory `CreateReportData.initial()`.
- Pin peta: marker mengikuti center peta (`onMapMoved`) atau ditempatkan via long-press (`onGeoPointLongPress`); tombol "GPS Akurat" memanggil permission + Geolocator lalu `moveTo`.
- Foto & deskripsi memakai ulang konstanta `kMaxReportMediaCount`, `kMaxReportDescriptionLength`, dan `getQuickTextsForDisaster()` dari `add_report_state.dart`.
- `MultipartFile.fromFile()` di Dio 5 bersifat async — harus di-`await`.
- `flutter analyze lib/features/reports lib/core/widgets/emergency_112_dialog.dart lib/features/home/home_screen.dart` → **No issues found**.
