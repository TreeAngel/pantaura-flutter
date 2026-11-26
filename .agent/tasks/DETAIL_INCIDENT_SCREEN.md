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
- [ ] Download Stitch design screenshot untuk referensi visual

---

## Fase 1: State & Data Layer

- [ ] Buat `lib/features/incidents/incident_detail_state.dart`
  - [ ] Class `MediaItem` — gabungan media dari report/resolution dengan metadata (description, createdAt, source type)
  - [ ] Class `TimelineEntry` — unified entry dari `ReportModel` atau `ResolutionSubmissionModel` (id, description, createdAt, media, type, authorName)
  - [ ] Class `IncidentDetailData` — immutable state utama
    - [ ] `incident`: `IncidentDetailModel`
    - [ ] `timeline`: `List<TimelineEntry>` (sorted ascending default)
    - [ ] `allMedia`: `List<MediaItem>` (sorted by createdAt ascending)
    - [ ] `nearestSafeZone`: `SafeZoneModel?`
    - [ ] `isSortAscending`: `bool` (default `true`)
    - [ ] `visibleMediaCount`: `int` (default `10`)
    - [ ] `isConfirmLoading`: `bool` (default `false`)
    - [ ] Method `copyWith`

- [ ] Buat `lib/features/incidents/incident_detail_notifier.dart`
  - [ ] `IncidentDetailNotifier extends AsyncNotifier<IncidentDetailData>`
  - [ ] Provider: `AsyncNotifierProvider.family<IncidentDetailNotifier, IncidentDetailData, String>`
  - [ ] `build(String incidentId)`: fetch `getIncidentDetail` + `getSafeZones` secara concurrent
  - [ ] Compute nearest safe zone (Euclidean distance dari incident lat/lng)
  - [ ] Build `timeline` list (merge reports + resolutions, sort asc by date)
  - [ ] Build `allMedia` list (collect semua media dari reports + resolutions, sort by createdAt)
  - [ ] Method `toggleSort()`: reverse `timeline`, toggle `isSortAscending`
  - [ ] Method `showMoreMedia()`: increment `visibleMediaCount` by 10
  - [ ] Method `toggleConfirm(String incidentId)`: call `incidentService.toggleConfirm()`

---

## Fase 2: Screen Utama

- [ ] Buat `lib/features/incidents/incident_detail_screen.dart`
  - [ ] `IncidentDetailScreen extends ConsumerStatefulWidget` dengan `final String incidentId`
  - [ ] Gunakan `ref.watch(incidentDetailProvider(incidentId))`

### 2.1 — AppBar & TopBar

- [ ] Widget `_IncidentDetailAppBar` — `SliverAppBar` atau `AppBar` biasa
  - [ ] Leading: tombol back (IconButton) `context.pop()` atau `Navigator.of(context).pop()`
  - [ ] Actions: IconButton telepon merah `Icons.call_rounded` → `_showEmergency112Dialog()`
  - [ ] `_showEmergency112Dialog()` — replikasi persis dari `home_screen.dart` L125-176

### 2.2 — Chip Status & Jenis Bencana

- [ ] Widget `_DisasterStatusHeader`
  - [ ] Row berisi: chip jenis bencana (`disasterTypeLabel`) + `IncidentStatusChip`
  - [ ] Chip jenis bencana: style sama dengan `IncidentStatusChip` tapi warna brand

### 2.3 — Summary Bencana

- [ ] Widget `_IncidentSummarySection`
  - [ ] Title insiden (`AppTypography.headlineLg`)
  - [ ] Deskripsi singkat insiden (`AppTypography.bodyMd`)
  - [ ] Statistik row: jumlah laporan, tanggal terverifikasi/dibuat

### 2.4 — Card Lokasi & Peta

- [ ] Widget `_LocationCard`
  - [ ] Alamat / koordinat (jika address null, tampilkan "Lat: X.XX, Lng: Y.YY")
  - [ ] Tombol "Buka Peta" → `context.go(AppRoutes.map)` (pass lat/lng sebagai extras)
  - [ ] `FlutterMap` non-interaktif:
    - [ ] `MapOptions(interactionOptions: const InteractionOptions(flags: InteractiveFlag.none))`
    - [ ] `TileLayer` dengan OpenStreetMap URL template
    - [ ] `MarkerLayer` dengan pin di koordinat insiden
    - [ ] Tinggi fixed: 160dp, `ClipRRect` dengan `AppRadius.roundedMd`

### 2.5 — Card Media / Galeri Foto

- [ ] Widget `_MediaGalleryCard` (StatefulWidget lokal)
  - [ ] State lokal: `int _selectedIndex = 0`
  - [ ] Jika tidak ada media: tampilkan `Image.asset('assets/images/data-not-found.png')`
  - [ ] Gambar utama (viewer):
    - [ ] `Image.network(url, fit: BoxFit.cover)` dengan `errorBuilder` → `Image.asset(placeholder)`
    - [ ] Judul gambar = deskripsi dari parent report/resolution
    - [ ] Overlay judul di bawah gambar utama
  - [ ] Grid thumbnail (5 kolom):
    - [ ] `GridView` `crossAxisCount: 5`, spacing 4dp
    - [ ] Tampilkan `min(visibleMediaCount, media.length)` thumbnails
    - [ ] Thumbnail ter-select: border `AppColors.primary`, opacity normal
    - [ ] Thumbnail lain: opacity 0.6
    - [ ] Tombol "Tampilkan Lebih Banyak":
      - [ ] Muncul jika `media.length > visibleMediaCount`
      - [ ] Ditempatkan di slot index `visibleMediaCount - 1` (slot terakhir visible), **hanya jika** `visibleMediaCount % 5 == 0` (akhir baris ke-2)
      - [ ] Atau ditempatkan sebagai item setelah grid
      - [ ] Tap → `ref.read(incidentDetailProvider(incidentId).notifier).showMoreMedia()`

### 2.6 — Timeline Kronologi

- [ ] Widget `_TimelineSection`
  - [ ] Header row: Text "Kronologi Laporan" + Chip "(N laporan)" dengan ikon sort asc/desc
  - [ ] Tap chip → `toggleSort()`
  - [ ] `ConstrainedBox(maxHeight: 400)` → `ListView.separated` dengan timeline entries
  - [ ] Setiap `_TimelineEntryTile`:
    - [ ] Avatar: foto pertama dari media (thumbnail kecil 48x48, `ClipRRect`) atau icon placeholder
    - [ ] Badge type: "Laporan" (biru) atau "Resolusi" (hijau)
    - [ ] Nama pelapor / petugas
    - [ ] Deskripsi singkat (max 2 baris, `overflow: TextOverflow.ellipsis`)
    - [ ] Timestamp (`AppTypography.caption`)
    - [ ] Connector line antara entries (vertical line dari avatar)

### 2.7 — Card Posko Terdekat

- [ ] Widget `_NearestSafeZoneCard`
  - [ ] Jika `nearestSafeZone == null`: tampilkan placeholder "Tidak ada posko terdekat"
  - [ ] Nama posko (`AppTypography.headlineSm`)
  - [ ] Tipe posko (chip kecil)
  - [ ] Alamat / kapasitas
  - [ ] Icon lokasi + jarak estimasi (berdasarkan Euclidean dari incident)

### 2.8 — Tombol Konfirmasi Kerumunan

- [ ] Widget `_CrowdConfirmButton`
  - [ ] Hanya tampil jika user authenticated (`authNotifierProvider` is `AuthAuthenticated`)
  - [ ] `ElevatedButton` atau `PrimaryButton`, height 56dp (CTA standard)
  - [ ] Loading state saat `isConfirmLoading == true`
  - [ ] Tap → `ref.read(incidentDetailProvider(incidentId).notifier).toggleConfirm(incidentId)`

---

## Fase 3: Routing

- [ ] Update `lib/core/routing/app_router.dart` L79-88
  - [ ] Import `'../../features/incidents/incident_detail_screen.dart'`
  - [ ] Ganti `_PlaceholderDetailScreen` → `IncidentDetailScreen(incidentId: id)`
  - [ ] **JANGAN hapus** `_PlaceholderDetailScreen` (L143-179) dan `_PlaceholderTabScreen` (L117-141)

---

## Fase 4: Validasi & Quality

- [ ] Jalankan `analyze_files` via MCP `flutter_dart-mcp-server`
- [ ] Tidak ada error analisis (warning minor boleh)
- [ ] Semua touch target ≥ 48dp
- [ ] Tidak ada bang operator (`!`) di kode baru
- [ ] Semua widget kelas terpisah (tidak ada method yang return Widget)
- [ ] `const` digunakan di mana memungkinkan

---

## Checklist Progress Ringkas

| Fase | Status |
|------|--------|
| 0 — Persiapan | 🟡 Sebagian |
| 1 — State & Notifier | ⬜ Belum |
| 2 — Screen & Widgets | ⬜ Belum |
| 3 — Routing | ⬜ Belum |
| 4 — Validasi | ⬜ Belum |
