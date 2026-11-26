# TASK: Implementasi Halaman Detail Insiden

**Screen**: Detail Insiden Bencana — Pantaura Flutter  
**Stitch Project**: `projects/13707441510623217137`  
**Screen ID**: `screens/94ae0915c1364c219b37dd5ce64c3fc8`  
**Route**: `/incidents/:id` → `AppRoutes.incidentDetailPath`  
**Target file**: `lib/features/incidents/incident_detail_screen.dart`

---

## Fase 0: Persiapan & Desain

- [x] Baca AGENT.md dan internalisasi rules
- [x] Baca file routing `lib/core/routing/app_router.dart` (L79-88 target, L143-179 jangan hapus)
- [x] Baca `lib/core/models/api_models.dart` — `IncidentDetailModel`, `ReportModel`, `ResolutionSubmissionModel`, `SafeZoneModel`
- [x] Baca `lib/core/services/incident_service.dart` — `getIncidentDetail()`, `toggleConfirm()`
- [x] Baca `lib/core/services/safe_zone_service.dart` — `getSafeZones()`
- [x] Baca `lib/core/providers.dart` — `incidentServiceProvider`, `safeZoneServiceProvider`
- [x] Baca `lib/features/home/home_screen.dart` L125-176 — `_showEmergency112Dialog()` untuk replikasi
- [x] Baca `lib/core/theme/` — AppColors, AppTypography, AppSpacing, AppRadius, AppShadows
- [x] Baca `lib/core/widgets/incident_status_chip.dart` — `IncidentStatusChip`
- [x] Download Stitch design screenshot untuk referensi visual

---

## Fase 1: State & Data Layer

- [x] Buat `lib/features/incidents/incident_detail_state.dart`
  - [x] Class `MediaItem` — gabungan media dari report/resolution dengan metadata (description, createdAt, source type)
  - [x] Class `TimelineEntry` — unified entry dari `ReportModel` atau `ResolutionSubmissionModel` (id, description, createdAt, media, type, authorName)
  - [x] Class `IncidentDetailData` — immutable state utama
    - [x] `incident`: `IncidentDetailModel`
    - [x] `timeline`: `List<TimelineEntry>` (sorted ascending default)
    - [x] `allMedia`: `List<MediaItem>` (sorted by createdAt ascending)
    - [x] `nearestSafeZone`: `SafeZoneModel?`
    - [x] `isSortAscending`: `bool` (default `true`)
    - [x] `visibleMediaCount`: `int` (default `10`)
    - [x] `isConfirmLoading`: `bool` (default `false`)
    - [x] Method `copyWith`

- [x] Buat `lib/features/incidents/incident_detail_notifier.dart`
  - [x] `IncidentDetailNotifier extends AsyncNotifier<IncidentDetailData>`
  - [x] Provider: `AsyncNotifierProvider.family<IncidentDetailNotifier, IncidentDetailData, String>`
  - [x] `build(String incidentId)`: fetch `getIncidentDetail` + `getSafeZones` secara concurrent
  - [x] Compute nearest safe zone (Euclidean distance dari incident lat/lng)
  - [x] Build `timeline` list (merge reports + resolutions, sort asc by date)
  - [x] Build `allMedia` list (collect semua media dari reports + resolutions, sort by createdAt)
  - [x] Method `toggleSort()`: reverse `timeline`, toggle `isSortAscending`
  - [x] Method `showMoreMedia()`: increment `visibleMediaCount` by 10
  - [x] Method `toggleConfirm(String incidentId)`: call `incidentService.toggleConfirm()`

---

## Fase 2: Screen Utama

- [x] Buat `lib/features/incidents/incident_detail_screen.dart`
  - [x] `IncidentDetailScreen extends ConsumerStatefulWidget` dengan `final String incidentId`
  - [x] Gunakan `ref.watch(incidentDetailProvider(incidentId))`

### 2.1 — AppBar & TopBar

- [x] Widget `_IncidentDetailAppBar` — `SliverAppBar` atau `AppBar` biasa
  - [x] Leading: tombol back (IconButton) `context.pop()` atau `Navigator.of(context).pop()`
  - [x] Actions: IconButton telepon merah `Icons.call_rounded` → `_showEmergency112Dialog()`
  - [x] `_showEmergency112Dialog()` — replikasi persis dari `home_screen.dart` L125-176

### 2.2 — Chip Status & Jenis Bencana

- [x] Widget `_DisasterStatusHeader`
  - [x] Row berisi: chip jenis bencana (`disasterTypeLabel`) + `IncidentStatusChip`
  - [x] Chip jenis bencana: style sama dengan `IncidentStatusChip` tapi warna brand

### 2.3 — Summary Bencana

- [x] Widget `_IncidentSummarySection`
  - [x] Title insiden (`AppTypography.headlineLg`)
  - [x] Deskripsi singkat insiden (`AppTypography.bodyMd`)
  - [x] Statistik row: jumlah laporan, tanggal terverifikasi/dibuat

### 2.4 — Card Lokasi & Peta

- [x] Widget `_LocationCard`
  - [x] Alamat / koordinat (jika address null, tampilkan "Lat: X.XX, Lng: Y.YY")
  - [x] Tombol "Buka Peta" → `context.go(AppRoutes.map)` (pass lat/lng sebagai extras)
  - [x] `FlutterMap` non-interaktif:
    - [x] `MapOptions(interactionOptions: const InteractionOptions(flags: InteractiveFlag.none))`
    - [x] `TileLayer` dengan OpenStreetMap URL template
    - [x] `MarkerLayer` dengan pin di koordinat insiden
    - [x] Tinggi fixed: 160dp, `ClipRRect` dengan `AppRadius.roundedMd`

### 2.5 — Card Media / Galeri Foto

- [x] Widget `_MediaGalleryCard` (StatefulWidget lokal)
  - [x] State lokal: `int _selectedIndex = 0`
  - [x] Jika tidak ada media: tampilkan `Image.asset('assets/images/data-not-found.png')`
  - [x] Gambar utama (viewer):
    - [x] `Image.network(url, fit: BoxFit.cover)` dengan `errorBuilder` → `Image.asset(placeholder)`
    - [x] Judul gambar = deskripsi dari parent report/resolution
    - [x] Overlay judul di bawah gambar utama
  - [x] Grid thumbnail (5 kolom):
    - [x] `GridView` `crossAxisCount: 5`, spacing 4dp
    - [x] Tampilkan `min(visibleMediaCount, media.length)` thumbnails
    - [x] Thumbnail ter-select: border `AppColors.primary`, opacity normal
    - [x] Thumbnail lain: opacity 0.6
    - [x] Tombol "Tampilkan Lebih Banyak":
      - [x] Muncul jika `media.length > visibleMediaCount`
      - [x] Ditempatkan di slot index `visibleMediaCount - 1` (slot terakhir visible), **hanya jika** `visibleMediaCount % 5 == 0` (akhir baris ke-2)
      - [x] Atau ditempatkan sebagai item setelah grid
      - [x] Tap → `ref.read(incidentDetailProvider(incidentId).notifier).showMoreMedia()`

### 2.6 — Timeline Kronologi

- [x] Widget `_TimelineSection`
  - [x] Header row: Text "Kronologi Laporan" + Chip "(N laporan)" dengan ikon sort asc/desc
  - [x] Tap chip → `toggleSort()`
  - [x] `ConstrainedBox(maxHeight: 400)` → `ListView.separated` dengan timeline entries
  - [x] Setiap `_TimelineEntryTile`:
    - [x] Avatar: foto pertama dari media (thumbnail kecil 48x48, `ClipRRect`) atau icon placeholder
    - [x] Badge type: "Laporan" (biru) atau "Resolusi" (hijau)
    - [x] Nama pelapor / petugas
    - [x] Deskripsi singkat (max 2 baris, `overflow: TextOverflow.ellipsis`)
    - [x] Timestamp (`AppTypography.caption`)
    - [x] Connector line antara entries (vertical line dari avatar)

### 2.7 — Card Posko Terdekat

- [x] Widget `_NearestSafeZoneCard`
  - [x] Jika `nearestSafeZone == null`: tampilkan placeholder "Tidak ada posko terdekat"
  - [x] Nama posko (`AppTypography.headlineSm`)
  - [x] Tipe posko (chip kecil)
  - [x] Alamat / kapasitas
  - [x] Icon lokasi + jarak estimasi (berdasarkan Euclidean dari incident)

### 2.8 — Tombol Konfirmasi Kerumunan

- [x] Widget `_CrowdConfirmButton`
  - [x] Hanya tampil jika user authenticated (`authNotifierProvider` is `AuthAuthenticated`)
  - [x] `ElevatedButton` atau `PrimaryButton`, height 56dp (CTA standard)
  - [x] Loading state saat `isConfirmLoading == true`
  - [x] Tap → `ref.read(incidentDetailProvider(incidentId).notifier).toggleConfirm(incidentId)`

---

## Fase 3: Routing

- [x] Update `lib/core/routing/app_router.dart` L79-88
  - [x] Import `'../../features/incidents/incident_detail_screen.dart'`
  - [x] Ganti `_PlaceholderDetailScreen` → `IncidentDetailScreen(incidentId: id)`
  - [x] **JANGAN hapus** `_PlaceholderDetailScreen` (L143-179) dan `_PlaceholderTabScreen` (L117-141)

---

## Fase 4: Validasi & Quality

- [x] Jalankan `analyze_files` via MCP `flutter_dart-mcp-server`
- [x] Tidak ada error analisis (warning minor boleh)
- [x] Semua touch target ≥ 48dp
- [x] Tidak ada bang operator (`!`) di kode baru
- [x] Semua widget kelas terpisah (tidak ada method yang return Widget)
- [x] `const` digunakan di mana memungkinkan

---

## Checklist Progress Ringkas

| Fase | Status |
|------|--------|
| 0 — Persiapan | ✅ Selesai |
| 1 — State & Notifier | ✅ Selesai |
| 2 — Screen & Widgets | ✅ Selesai |
| 3 — Routing | ✅ Selesai |
| 4 — Validasi | ✅ Selesai (`flutter analyze` bersih) |

---

## Catatan Implementasi (update terakhir)

- **Riverpod 3.5**: `FamilyAsyncNotifier` sudah dihapus. Notifier memakai `AsyncNotifier<IncidentDetailData>` dengan argumen `incidentId` melalui konstruktor, didaftarkan dengan `AsyncNotifierProvider.family`.
- **Urutan UI** mengikuti `code.html` Stitch: galeri media → banner validasi → kartu informasi (chip + judul + lokasi + peta statis + agregasi) → kronologi → posko → action bar bawah.
- **Peta preview**: `InteractiveFlag.none`, tinggi 176dp (`h-44` di desain), koordinat ditampilkan sebagai chip overlay.
- **Buka peta**: mengoper `lat`/`lng` sebagai query parameter (`/map?lat=...&lng=...`).
- **Grid media**: 5 kolom; ketika `media.length > visibleCount`, tombol "+ Lainnya" mengisi slot ke-10 (baris 2, kolom 5) dan jumlah thumbnail yang ditampilkan `visibleCount - 1`.
- **Jarak posko** dihitung sekali di notifier (Euclidean ≈ 111 km/derajat) dan disimpan di state sebagai `nearestSafeZoneDistanceKm`.
- **Validasi**: `flutter analyze lib/features/incidents lib/core/routing/app_router.dart` → 0 error pada kode fitur (1 warning unused parameter `subtitle` pada placeholder routing sengaja dipertahankan sesuai instruksi "jangan hapus placeholder").
- `latlong2: ^0.10.1` ditambahkan ke `pubspec.yaml` sebagai dependency langsung karena dipakai `LatLng`.
