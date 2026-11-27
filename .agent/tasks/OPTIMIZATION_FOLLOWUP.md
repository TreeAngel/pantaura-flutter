# TASK: Optimasi & Tindak Lanjut Catatan Pantaura Flutter

**Sumber**: catatan user (6 poin) — dikerjakan bertahap, satu fase bisa jadi sub-task terpisah  
**Target umum**: `lib/features/map`, `lib/features/reports`, `lib/features/incidents`, `lib/features/home`, `lib/core`  
**Aturan**: selalu rujuk `AGENT.md`; cek design Stitch lokal sebelum MCP; **jangan** akses MCP Stitch tanpa instruksi eksplisit

---

## Fase 0: Audit & Persiapan

- [x] Baca `AGENT.md` dan internalisasi rules (Riverpod 3.5, go_router, permission handler, WCAG AAA)
- [x] Baca `lib/features/map/map_screen.dart`, `map_state.dart`, `map_notifier.dart`, dan `widgets/incident_pin.dart`
- [x] Baca `lib/features/reports/create/widgets/location_picker_section.dart` — sumber masalah pin menumpuk & konflik scroll
- [x] Baca `lib/core/services/watch_area_service.dart`, `API.md` bagian WatchAreas & Alerts, `lib/features/home/home_notifier.dart`
- [x] Audit semua pemanggilan `ImagePicker().pickImage(...)` di `lib/features`
- [x] Inventaris widget duplikat di `lib/features/**/widgets/` dan `lib/core/widgets/`
- [x] Baca 3 notifier chip cepat: `create_report_notifier.dart`, `add_report_notifier.dart`, `recovered_notifier.dart`

---

## Fase 1: Safe Zone (Posko) Dikonsumsi di Map Screen

- [x] Tambahkan `safeZones` (`List<SafeZoneModel>`) ke `MapData` + `copyWith`
- [x] Di `MapNotifier.build()`, fetch paralel `getIncidentsMap()` + `getSafeZones().catchError((_) => <SafeZoneModel>[])`
- [x] Buat marker posko terpisah dari marker insiden:
  - [x] Prefix id `safezone_<id>`, warna hijau (`AppColors.statusResolved`), ikon `health_and_safety`/`local_hospital`
  - [x] Tanpa badge `reportsCount`
  - [x] Disimpan di daftar marker yang sama tetapi tidak ikut filter status insiden
- [x] `findIncidentIdByPoint()` **harus mengabaikan** titik posko; bila perlu tambah `findSafeZoneByPoint()`
- [x] Tap pin posko → tidak membuka `IncidentPreviewSheet`; tampilkan snackbar/info ringkas nama + alamat posko (atau no-op yang jelas)
- [x] Pastikan marker posko tidak duplikat saat filter/status berubah (sinkron marker seperti insiden)
- [x] Jika daftar kosong, tidak ada marker posko dan tidak ada error

---

## Fase 2: Watch Area & Push-Notification Endpoint

- [x] `WatchAreaService` sudah punya `getWatchAreas`, `createWatchArea`, `deleteWatchArea`, `getAlerts`, `markAlertAsRead` — pastikan `watchAreaServiceProvider` terdaftar di `core/providers.dart`
- [x] Buat notifier/provider untuk watch area (mis. `lib/features/home/watch_area_notifier.dart`) yang membungkus CRUD + mark-as-read
- [x] Home sudah memanggil `GET /watch-areas` & `GET /alerts`; tambahkan:
  - [x] UI tambah area pantauan (label, lat/lng, radius) via `POST /watch-areas`, maksimal **5** area
  - [x] UI hapus area via `DELETE /watch-areas/{id}`
  - [x] Tap notifikasi alert → `POST /alerts/{id}/read`, update `unreadAlertsCount`
- [x] Jika endpoint registrasi token push/FCM tidak terdokumentasi di `API.md`, batasi pada notifikasi in-app + tandai sudah dibaca, dan catat keterbatasan di task
- [x] Pastikan `selectWatchArea()` di home tetap memfilter insiden via `getNearbyIncidents(lat, lng, radius)`

---

## Fase 3: Pin Point di Create Report — Performance & Gesture

- [x] **Akarna**: `LocationPickerSection` menghapus + menambah marker native pada setiap `onMapMoved`, sehingga marker menumpuk/bertabrakan dan berat
- [x] Buat marker **sekali** saat `onMapIsReady`, lalu reposisi dengan `MapController.changeLocationMarker(oldPoint, newPoint, markerIcon:)` (atau `setIconMarker`) — **jangan** `removeMarker`/`addMarker` berulang
- [x] Debounce `onMapMoved` (150–250 ms) dan hanya update state bila pergeseran > ambang (mis. 0.00005 derajat)
- [x] Bungkus peta dengan `RepaintBoundary`; jangan rebuild `OSMFlutter` saat state form berubah (gunakan `ValueKey` stabil)
- [x] Konflik geser vertikal dengan `SingleChildScrollView`:
  - [x] Berikan `GestureDetector(behavior: HitTestBehavior.opaque, onVerticalDragUpdate: (_) {}, onVerticalDragEnd: (_) {})` di sekitar peta agar drag dimenangkan peta, **atau**
  - [x] Pindahkan peta ke area fixed (mis. `SliverPersistentHeader` pinned) di luar scroll vertikal
  - [ ] Verifikasi manual: drag di peta menggeser peta, bukan halaman; scroll di luar peta tetap normal
- [x] `onGeoPointLongPress` tetap bisa menempatkan pin tanpa menggeser peta
- [x] Pastikan koordinat awal demo `(-6.19099, 106.84264)` tetap dipakai

---

## Fase 4: Pengecekan Permission di Semua Pick Media

- [x] Audit: 3 lokasi picker ditemukan — `create_report_notifier.dart`, `add_report_screen.dart`, `recovered_screen.dart`
- [x] Tambahkan helper terpusat `PermissionService.pickImageWithPermission(ImageSource source) → Future<XFile?>`:
  - [x] Kamera → `requestCameraPermission()`, galeri → `requestGalleryPermission()`
  - [x] Tolak → snackbar jelas; `permanentlyDenied` → `showPermanentlyDeniedDialog(...)` + `openAppSettings()`
  - [x] `isLimited` (iOS/Android 13) dianggap boleh
- [x] Ubah ketiga lokasi memakai helper tersebut; hapus `ImagePicker().pickImage(...)` langsung di screen/notifier
- [x] Cek ulang `AndroidManifest.xml`: `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE (maxSdkVersion=32)`
- [ ] Verifikasi manual: izin ditolak → tidak crash & ada pesan; izin diberikan → foto masuk daftar

---

## Fase 5: Chip Deskripsi Instan Bisa Di-Unselect

- [x] Ubah `appendQuickText(String)` → `toggleQuickText(String)` di 3 notifier:
  - [x] Jika teks sudah ada di deskripsi → hapus teks tersebut (termasuk pembersihan tanda baca/spasi berlebih)
  - [x] Jika belum ada → tambahkan seperti sebelumnya, batas 500 karakter
- [x] Update 3 widget chip (`report_description_section.dart`, `description_section.dart`, `recovery_description_section.dart`) memanggil `toggleQuickText`, bukan `appendQuickText`
- [x] Pastikan state `isSelected` (berdasarkan `contains`) berubah setelah tap kedua
- [x] Pastikan `TextEditingController` di create_report tersinkron saat teks dihapus
- [ ] Verifikasi manual: tap chip → teks muncul & chip aktif; tap lagi → teks hilang & chip nonaktif

---

## Fase 6: Pindahkan Widget Umum ke `core/widgets/`

- [x] Group A (paling banyak dipakai): `SectionStepHeader`, `QuickTextChip`, `MediaThumbnail`, `EmptyMediaCard`
- [x] Group B: `EvidencePhotoSection` — generalisasi judul/badge, dipakai ulang oleh add_report, create_report, recovered
- [x] Group C: shell `DescriptionSection` + chip cepat — generalisasi (judul, placeholder, daftar teks, counter)
- [x] Group D: `SubmitBar` / sticky action bar — generalisasi label, ikon, loading
- [x] Group E: app bar/header polos → `FormAppBar` (3 form) + `SectionHeader` (map/history/profile)
- [ ] Group F: `IncidentSummaryCard` (add_report & recovered) → `CoreIncidentSummaryCard` — **tidak jadi digabung** karena konten kedua kartu berbeda (status chip vs dua chip verifikasi posisi); stylings sudah memakai token core
- [x] Strategi: buat widget core generik dulu, feature wrapper tipis tetap ada sementara, migrasi satu grup demikian, jalankan `flutter analyze` tiap grup
- [x] Jangan pindahkan widget yang benar-benar spesifik (mis. `TruthDeclarationCard`, `ValidationBanner`, `InvalidLocationDialog`)
- [x] Update semua import & hapus file lama hanya setelah tidak ada referensi

---

## Fase 7: Validasi & Quality

- [x] `flutter analyze lib` → 0 error (hanya 3 warning placeholder routing yang sengaja dipertahankan)
- [ ] Safe zone marker tampil di peta dan tidak mengganggu tap pin insiden (verifikasi visual)
- [ ] Create-report map: marker tidak menumpuk, drag peta tidak menggulir halaman, performa ringan (verifikasi manual)
- [ ] Watch area CRUD + mark-as-read bekerja bila endpoint tersedia (verifikasi manual/live)
- [x] Semua media picker lewat helper permission (grep: `ImagePicker()` hanya di `PermissionService`)
- [ ] Chip instan bisa di-unselect di 3 screen (verifikasi manual)
- [x] Widget umum sudah di `core/widgets/` dan import bersih
- [x] Tidak ada bang operator (`!`) di kode baru; touch target ≥48dp; `const` digunakan

---

## Checklist Progress Ringkas

| Fase | Status |
|------|--------|
| 0 — Audit & persiapan | ✅ Selesai |
| 1 — Safe zone di map | ✅ Selesai |
| 2 — Watch area & notifikasi | ✅ Selesai |
| 3 — Pin create-report & gesture | 🟡 Implementasi selesai; verifikasi manual drag belum |
| 4 — Permission pick media | ✅ Kode selesai; verifikasi manual izin pending |
| 5 — Chip unselect | ✅ Kode selesai; verifikasi manual tap pending |
| 6 — Widget ke core | 🟡 Group A–E selesai; Group F sengaja tidak digabung |
| 7 — Validasi | 🟡 `flutter analyze lib` bersih; verifikasi manual/visual pending |

---

## Catatan Implementasi

- `MapController.changeLocationMarker(...)` tersedia di `flutter_osm_plugin 4.1.0` — gunakan untuk reposisi marker, bukan remove/add.
- `HomeNotifier` sudah mengonsumsi `GET /watch-areas` & `GET /alerts`; yang belum adalah CRUD tambah/hapus + `markAlertAsRead`.
- Ketiga picker sudah punya pengecekan permission secara lokal, tetapi belum terpusat — Fase 4 menyatukannya agar tidak ada yang terlewat.
- Fase 2: `API.md` tidak mendokumentasikan endpoint registrasi token FCM; implementasi dibatasi pada notifikasi in-app + `POST /alerts/{id}/read`. `HomeNotifier.syncWatchAreaData()` menyinkronkan perubahan tanpa reload penuh.
- Fase 3: path aktual `location_picker_section.dart` adalah `lib/features/reports/widgets/location_picker_section.dart` (bukan `lib/features/reports/create/widgets/...`). Implementasi marker sekali + `changeLocationMarker`, debounce 200 ms, `RepaintBoundary`, dan `GestureDetector` opaque sudah diterapkan. Verifikasi gesture manual masih perlu di emulator/perangkat.
- Fase 1: `flutter analyze lib/features/map` → No issues found. Marker posko memakai prefix `safezone_`, tidak ikut filter status, dan tap posko hanya snackbar.
- Fase 4: helper `PermissionService.pickImageWithPermission/pickMultiImagesWithPermission({context})` — `ImagePicker()` kini hanya ada di service. Izin tolak/permanentlyDenied ditangani; manifest sudah memiliki izin yang dibutuhkan.
- Fase 5: helper `toggleQuickTextInDescription()` di `add_report_state.dart` dipakai 3 notifier; chip kini toggle (tambah/hapus) dan controller create-report tersinkron.
- Fase 6: widget inti baru di `core/widgets/`: `SectionStepHeader`, `QuickTextChip`, `MediaThumbnail`, `EmptyMediaCard`, `EvidencePhotoSection`, `DescriptionSection`, `SubmitBar`, `FormAppBar`, `SectionHeader`. `IncidentSummaryCard` tidak digabung (konten berbeda).
- Validasi akhir: `flutter analyze lib` → hanya 3 warning placeholder routing di `app_router.dart` (sengaja dipertahankan dari task sebelumnya).
