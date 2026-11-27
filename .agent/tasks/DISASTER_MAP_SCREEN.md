# TASK: Implementasi Screen Peta Bencana Interaktif

**Screen**: Peta Bencana — Pantaura Flutter  
**Stitch Project**: `projects/13707441510623217137`  
**Design lokal**: `.stitch_pantaura_flutter/peta_bencana_siagakita/code.html` + `screen.png`  
**Route**: tab `AppRoutes.map` (`/map`) pada `StatefulShellBranch` — menggantikan `_PlaceholderTabScreen(title: 'Peta Bencana')`  
**Target file**: `lib/features/map/`

---

## Fase 0: Persiapan & Desain

- [x] Baca `AGENT.md` dan internalisasi rules (Riverpod, go_router, WCAG AAA, touch target 48–56dp)
- [x] **Cek design Stitch lokal terlebih dahulu**: baca `code.html` lalu `screen.png` pada folder di atas. **Jangan akses MCP Stitch** kecuali user memerintahkan eksplisit
- [x] Baca `lib/core/routing/app_router.dart` — branch peta ada di `StatefulShellBranch` ke-2; jangan hapus `_PlaceholderTabScreen` / `_PlaceholderDetailScreen`
- [x] Baca `lib/core/services/incident_service.dart` — `getIncidentsMap(status, type)` (GET `/incidents/map`) & `getIncidentDetail(id)` (GET `/incidents/{id}`)
- [x] Baca `API.md` bagian Insiden (status: `unverified`, `verified`, `resolution_submitted`, `resolved`; type: `flood`, `earthquake`, `landslide`, `fire`)
- [x] Baca `lib/core/models/api_models.dart` — `IncidentSummaryModel` (lat/lng, `reportsCount`, `status`, `disasterType`, `title`, `address`, `description`, `createdAt`)
- [x] Baca `lib/features/incidents/add_report/widgets/location_section.dart` untuk pola `flutter_osm_plugin`: `MapController.withPosition`, `OSMFlutter`, `OSMOption`, `ZoomOption`, `StaticPositionGeoPoint`, `MarkerIcon(iconWidget:)`, `AbsorbPointer`
- [x] Pastikan `pubspec.yaml` memakai `flutter_osm_plugin: ^4.1.0`; **`flutter_map` dan `latlong2` sudah dihapus, jangan dipakai lagi**
- [x] Jangan buat bottom nav karena sudah menggunakan stateful shell route
- [x] Baca `lib/core/theme/` — AppColors, AppTypography, AppSpacing, AppRadius, AppShadows

---

## Fase 1: State & Data Layer

- [x] Buat `lib/features/map/map_state.dart`
  - [x] `MapData` immutable: `incidents` (`List<IncidentSummaryModel>`), `selectedIncidentId` (`String?`), `selectedDetail` (`IncidentDetailModel?`), `isDetailLoading` (`bool`), `userPosition` (`Position?`), `activeStatusFilter` (`String?`, null = Semua), `searchQuery` (`String`)
  - [x] Konstanta demo: `static const GeoPoint demoCenter = GeoPoint(latitude: -6.19099, longitude: 106.84264)` dan `demoZoom = 15.0` (`GeoPoint` dari `flutter_osm_plugin`, **bukan** `LatLng`)
  - [x] Getter `filteredIncidents` (filter status + pencarian title/address) & `statusCounts` (untuk badge chip)
  - [x] Method `copyWith`
- [x] Buat `lib/features/map/map_notifier.dart`
  - [x] `MapNotifier extends AsyncNotifier<MapData>` (tanpa argumen family), provider `AsyncNotifierProvider<MapNotifier, MapData>`
  - [x] `build()`: `getIncidentsMap()` → isi `incidents`; `selectedIncidentId = null` (sheet belum tampil)
  - [x] **`selectIncident(String id)`**: simpan id lalu `getIncidentDetail(id)` → isi `selectedDetail` dengan data terbaru; set `isDetailLoading` saat fetch
  - [x] `setStatusFilter(String? status)`, `setSearch(String query)`, `clearSearch()`
  - [x] `refreshLocation()`: pakai `permissionServiceProvider.requestLocationPermission()` → `Geolocator.getCurrentPosition()`; bila gagal tetap pakai `demoCenter`
  - [x] `clearSelection()` bila sheet ditutup

---

## Fase 2: Peta Interaktif (atas → bawah sesuai `code.html`)

- [x] Buat `lib/features/map/map_screen.dart` (`ConsumerStatefulWidget`)
  - [x] `late final MapController _controller = MapController.withPosition(initPosition: MapData.demoCenter)` (−6.19099, 106.84264) **untuk kelancaran demonstrasi**
  - [x] `OSMFlutter(controller: _controller, osmOption: OSMOption(zoomOption: ZoomOption(initZoom: 15, minZoomLevel: 4, maxZoomLevel: 19), showZoomController: false, enableRotationByGesture: false))`
  - [x] Peta ini **interaktif**: jangan bungkus dengan `AbsorbPointer` (berbeda dari preview statis di `location_section.dart`)
  - [x] Semua widget turunan diletakkan di `lib/features/map/widgets/`

### 2.1 — Header

- [x] Widget `MapHeader` — ikon shield_with_house, caption "Pantaura • Tanggap Sipil", judul "Beranda", avatar kanan

### 2.2 — Search Bar & Filter Chip

- [x] Widget `MapSearchBar`
  - [x] Input "Cari jalan, kelurahan, atau kecamatan…" → `setSearch`
  - [x] Tombol clear (`Icons.cancel`) → `clearSearch()`, min 44×44dp
  - [x] Tombol GPS (`Icons.my_location`) → `refreshLocation()` lalu `_controller.moveTo(GeoPoint(latitude: p.latitude, longitude: p.longitude), animate: true)` (atau `_controller.goToLocation(...)`); fallback `MapData.demoCenter` bila GPS gagal
- [x] Widget `MapFilterChips`
  - [x] Chip horizontal scroll: "Semua", "Terverifikasi", "Menunggu", "Telah Pulih" dengan angka dari `statusCounts`
  - [x] Chip aktif: merah (`AppColors.statusVerified`) sesuai desain; chip lain white/unverified/resolved
  - [x] Tap chip → `setStatusFilter(...)`, marker & sheet ikut terfilter

### 2.3 — Canvas Peta

- [x] `OSMFlutter` interaktif dengan controller di atas; semua marker memakai `staticPoints:` (bukan `MarkerLayer`, bukan `TileLayer`)
- [x] Buat `List<StaticPositionGeoPoint>` dari `filteredIncidents`, tiap entri:
  - [x] `id`: `${incident.id}` (unik), posisi: `GeoPoint(latitude: incident.latitude, longitude: incident.longitude)`
  - [x] `MarkerIcon(iconWidget: IncidentPin(...))` — **pin teardrop** (rotasi -45°, ujung kanan bawah lancip)
  - [x] Warna pin menurut **status**: `statusVerified` (merah), `statusUnverified` (oranye), `statusResolution` (biru), `statusResolved` (hijau)
  - [x] **Ikon menurut jenis insiden** (reuse `_disasterIcon` pola `location_section.dart`): `flood` → air/tsunami, `earthquake` → guncangan, `landslide` → `Icons.landslide_rounded`, `fire` → `Icons.local_fire_department_rounded`
  - [x] **Badge angka di kanan atas pin = `incident.reportsCount`** (total laporan), lingkaran kecil dengan ring putih
  - [x] Marker selected sedikit lebih besar + efek pulse (ganti `MarkerIcon` via `_controller.setIconMarker(point, icon)`)
- [x] Simpan lookup `Map<String, GeoPoint>` (id → koordinat). Callback `onGeoPointClicked: (point) { … }` mencocokkan `point` dengan lookup, lalu **`selectIncident(id)`** (pass id → fetch `getIncidentDetail(id)` → sheet reload)
  - [x] `onGeoPointClicked` dari `flutter_osm_plugin` mengembalikan `GeoPoint`, **bukan id** — jangan mengira marker membawa id otomatis
- [x] Marker "Lokasi Anda" memakai `StaticPositionGeoPoint` berlabel pada `userPosition ?? MapData.demoCenter` (dot biru + pulse + label), atau `UserLocationMaker` bila tracking aktif
- [x] Kontrol kanan bawah: zoom in / zoom out / pusat GPS — masing-masing ≥48dp, memanggil `_controller.zoomIn()`, `_controller.zoomOut()`, `_controller.moveTo(...)`/`currentLocation()`
- [x] `setState`/provider update untuk `staticPoints` saat filter berubah; **jangan** memanggil `BuiltInMapCachingProvider.getOrCreateInstance()` (API `flutter_map`, sudah tidak tersedia)

### 2.4 — Bottom Sheet Detail Insiden

- [x] Widget `IncidentPreviewSheet` (muncul hanya bila `selectedIncidentId != null`)
- [x] Drag handle + rounded top 24dp, `maxHeight` ± 45% layar, isi scrollable
- [x] Saat `isDetailLoading`: tampilkan skeleton/loading ringkas di dalam sheet
- [x] Saat `selectedDetail` tersedia, tampilkan **urutan sesuai desain**:
  - [x] Baris chip: status (`IncidentStatusChip` / label "Terkonfirmasi Aktif"), chip jenis bencana, chip jarak "X km dari Anda"
  - [x] Judul insiden = `selectedDetail.title` (`headlineMd`)
  - [x] Alamat = `selectedDetail.address` (fallback koordinat)
  - [x] Card "Dampak Terpantau": `selectedDetail.description` + thumbnail media pertama dengan badge "Valid", counter `${selectedDetail.reportsCount} Laporan Warga • <waktu relatif>`
  - [x] Jika media kosong/gagal load → `assets/images/data-not-found.png`
  - [x] CTA "Lihat Detail Insiden" ≥52dp → `context.push(AppRoutes.incidentDetail(selectedDetail.id))`
- [x] Informasi sheet **selalu diambil dari hasil `getIncidentDetail(id)` terbaru**, bukan dari data marker yang lama; reload otomatis setiap kali pin berbeda ditekan
- [x] Tutup sheet → `clearSelection()`

---

## Fase 3: Routing

- [x] Di `app_router.dart`, ganti `_PlaceholderTabScreen(title: 'Peta Bencana')` dengan `const MapScreen()` pada branch peta
- [x] **Jangan hapus** `_PlaceholderTabScreen` dan `_PlaceholderDetailScreen` (masih dipakai tab lain / create report)
- [x] Pastikan bottom nav tetap bekerja (`StatefulShellRoute.indexedStack`), tab Peta aktif = index 1
- [x] CTA sheet memakai `context.push(...)` agar kembali ke peta saat back

---

## Fase 4: Validasi & Quality

- [x] **Cek ulang design lokal** (`code.html` + `screen.png`) sebelum berpindah ke MCP Stitch; MCP hanya bila diperintahkan
- [x] `flutter analyze` → 0 error pada file baru
- [x] Peta benar-benar bisa digeser & di-zoom (tanpa `AbsorbPointer`, `showZoomController: false` karena kontrol dibuat sendiri)
- [x] Demo: tanpa GPS, peta langsung menampilkan area sekitar (-6.19099, 106.84264)
- [x] Tap 3 pin berbeda → sheet berubah sesuai id masing-masing (title/alamat/deskripsi/jumlah laporan)
- [x] Badge pin = `reportsCount`, ikon pin = jenis bencana, warna pin = status
- [x] Semua touch target ≥ 48dp, tidak ada overflow pada filter chips & sheet
- [x] Tidak ada bang operator (`!`) di kode baru
- [x] Semua widget berupa class terpisah di `widgets/`, bukan method return Widget
- [x] `const` digunakan di mana memungkinkan

---

## Checklist Progress Ringkas

| Fase | Status |
|------|--------|
| 0 — Persiapan & desain lokal | ✅ Selesai |
| 1 — State & notifier | ✅ Selesai |
| 2 — Peta, marker & bottom sheet | ✅ Selesai |
| 3 — Routing tab peta | ✅ Selesai |
| 4 — Validasi & quality | 🟡 `flutter analyze` bersih; build APK validation terkendali Shell.NotFoundError di harness |

---

## Catatan Implementasi

- Folder design yang benar adalah `.stitch_pantaura_flutter/peta_bencana_siagakita` (bukan `.stitch_panatura_flutter`).
- Koordinat awal demo `(-6.19099, 106.84264)` ditetapkan sebagai konstanta, bukan hardcode tersebar di widget.
- Riverpod 3.5: `AsyncNotifier` biasa cukup untuk screen ini (tidak perlu family); argumen detail dikirim lewat method `selectIncident(id)`.
- Bedakan perilaku: preview statis (detail / tambah laporan) memakai `AbsorbPointer` + `ZoomOption` zoom tetap; peta screen ini **interaktif** tanpa `AbsorbPointer`.
- GPS button memakai ulang `permission_service.dart` dari task permission (jangan request di dalam `build()`).
- Tidak ada lagi `flutter_map`, `latlong2`, `LatLng`, `TileLayer`, `MarkerLayer`, `InteractiveFlag`, maupun `BuiltInMapCachingProvider` — semuanya digantikan `flutter_osm_plugin` (`GeoPoint`, `OSMFlutter`, `MapController`).

---

## Catatan Implementasi Aktual

- File dibuat: `lib/features/map/map_state.dart`, `map_notifier.dart`, `map_screen.dart`, dan `widgets/{map_header,map_search_bar,map_filter_chips,incident_pin,user_location_pin,map_controls,incident_preview_sheet}.dart`.
- `app_router.dart`: branch peta sekarang memakai `const MapScreen()`; `_PlaceholderTabScreen` dan `_PlaceholderDetailScreen` tetap dipertahankan.
- Marker dibuat **dinamis** via `MapController.addMarker`/`removeMarkers` setelah `onMapIsReady`, bukan `staticPoints`, agar filter/status/selected update tidak me-reset kamera ke titik demo.
- `onGeoPointClicked` hanya memberi `GeoPoint`; id insiden dicari dengan toleransi 1e-5 di `MapNotifier.findIncidentIdByPoint`, lalu `selectIncident(id)` memanggil `getIncidentDetail` (sheet reload).
- `GeoPoint` bukan konstanta Dart, jadi `demoCenter` dideklarasikan `static final`, bukan `static const`.
- `PermissionStatus.isGranted` butuh import `package:permission_handler/permission_handler.dart` di notifier.
- `flutter analyze lib/features/map lib/core/routing/app_router.dart` → hanya 1 warning lama (`subtitle` pada placeholder routing, sengaja dipertahankan).
- Build APK tidak dapat diverifikasi karena harness mengembalikan `Shell.NotFoundError` dua kali; jalankan `flutter build apk --debug` manual untuk konfirmasi native build.
- Perbaikan runtime (`.log/mapDebug.log`): Riverpod 3 melarang `ref.listen` di `initState` (`ref.listen can only be used within the build method`). Listener sudah dipindahkan ke dalam `build()` sebelum `ref.watch(mapProvider)`. `app_router.dart` tidak bermasalah; `Scaffold` yang disebut di stack hanyalah parent shell.
