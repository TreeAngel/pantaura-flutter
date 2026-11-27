# TASK: Implementasi Halaman Riwayat Laporan Warga

**Screen**: Riwayat Laporan Warga — Pantaura Flutter  
**Stitch Project**: `projects/13707441510623217137`  
**Design lokal**: `.stitch_pantaura_flutter/riwayat_laporan_warga_siagakita/code.html` + `screen.png`  
**Route**: `AppRoutes.history` (`/history`) pada `StatefulShellBranch` — menggantikan `_PlaceholderTabScreen(title: 'Riwayat Laporan')`  
**Target file**: `lib/features/history/`

---

## Fase 0: Persiapan & Desain

- [x] Baca `AGENT.md` dan internalisasi rules (Riverpod 3.5, go_router, WCAG AAA, touch target 48–56dp)
- [x] **Cek design Stitch lokal terlebih dahulu**: `code.html` lalu `screen.png`. **Jangan akses MCP Stitch** kecuali diperintahkan
- [x] Baca `lib/core/routing/app_router.dart` — branch ke-3 `AppRoutes.history` masih placeholder; ganti, jangan hapus `_PlaceholderTabScreen` (dipakai tab profil)
- [x] Baca `API.md` — `GET /reports/my` (Bearer, `page`) dan struktur `ReportModel`
- [x] Baca `lib/core/services/report_service.dart` — `getMyReports(page:)`
- [x] Baca `lib/core/models/api_models.dart` — `ReportModel` (`id`, `incidentId`, `description`, `submittedAt`, `moderationStatus`, `rejectionReason`, `media`, `incident`)
- [x] Baca `lib/core/widgets/incident_status_chip.dart` — pola chip status
- [x] Baca `lib/features/home/home_screen.dart` — pola `ScrollController` pagination + `RefreshIndicator`
- [x] Baca `lib/core/theme/` — AppColors, AppTypography, AppSpacing, AppRadius, AppShadows

---

## Fase 1: State & Data Layer

- [x] Buat `lib/features/history/history_state.dart`
  - [x] `HistoryData` immutable: `reports` (`List<ReportModel>`), `currentPage`, `lastPage`, `isLoadingMore` (`bool`), `isRefreshing` (`bool`), `activeTab` (`HistoryTab.report | HistoryTab.recovery`), `statusFilter` (`String?`)
  - [x] Enum `HistoryTab { report, recovery }`
  - [x] Getter `filteredReports` — filter status: `all`, `unverified` (Menunggu), `verified` (Terkonfirmasi), `resolved` (Telah Pulih), `rejected` (Ditolak)
  - [x] Method `copyWith`
- [x] Buat `lib/features/history/history_notifier.dart`
  - [x] `HistoryNotifier extends AsyncNotifier<HistoryData>` + `AsyncNotifierProvider`
  - [x] `build()`: `getMyReports(page: 1)` → isi state
  - [x] `loadMore()`: bila `currentPage < lastPage`, fetch page berikutnya, append tanpa duplikat
  - [x] `refresh()`: reset ke page 1
  - [x] `setTab(HistoryTab)`, `setStatusFilter(String?)`

---

## Fase 2: Screen & Widget (urutan atas → bawah sesuai `code.html`)

- [x] Buat `lib/features/history/history_screen.dart` (`ConsumerStatefulWidget`)
  - [x] `ScrollController` + listener pagination seperti `home_screen.dart`
  - [x] `RefreshIndicator` untuk pull-to-refresh
  - [x] Semua widget turunan di `lib/features/history/widgets/`

### 2.1 — Header

- [x] Widget `HistoryHeader` — ikon `history_edu`, caption "Pantaura • Tanggap Warga", judul "Riwayat Laporan Warga", tombol filter kanan (min 48×48dp)

### 2.2 — Tab Segment

- [x] Widget `HistoryTabBar`
  - [x] Dua segmen: "Laporan Bencana (N)" dan "Pengajuan Pemulihan (N)" — tinggi ≥48dp
  - [x] Segmen digunakan untuk memfilter laporan berdasarkan status (lainnya dan `resolution_submitted`(pengajuan pemulihan))
  - [x] Tab aktif: `primaryContainer` + teks putih; tab lain transparan
  - [x] Tap → `setTab(...)`
  - [x] Jika belum ada endpoint riwayat resolusi, tab pemulihan menampilkan empty state yang rapi (tetap disiapkan untuk data resolusi di masa depan)

### 2.3 — Filter Chip

- [x] Widget `HistoryFilterChips` — horizontal scroll: "Semua", "Menunggu Verifikasi", "Terkonfirmasi", "Telah Pulih", "Ditolak"
  - [x] Chip aktif: `textHeader` + teks putih; min tinggi 38dp (area sentuh ≥48dp dengan padding)
  - [x] Tap → `setStatusFilter(...)`

### 2.4 — Card Riwayat

- [x] Widget `HistoryReportCard` — satu widget untuk semua status, dengan variasi konten:
  - [x] Baris chip: label jenis/kategori + `IncidentStatusChip` (status `moderationStatus` dipetakan ke enum)
  - [x] Judul: `report.description` (atau `report.incident?.title` bila tersedia)
  - [x] Timestamp relatif dari `submittedAt` + alamat dari `report.incident?.address` (fallback koordinat)
  - [x] Thumbnail media pertama 80×80dp; `errorBuilder` → `assets/images/data-not-found.png`
  - [x] Badge agregasi: "Laporan Utama • Tergabung N laporan warga" bila `incident != null`
  - [x] CTA "Lihat Detail Insiden & Pemantauan" ≥48dp → `context.push(AppRoutes.incidentDetail(report.incidentId))` bila `incidentId` tidak kosong
  - [x] **Card khusus `rejected`**: kotak alasan merah/abu "Catatan Verifikator Administrator" dari `rejectionReason` + tombol "Pelajari Alasan" / "Ajukan Banding"
  - [x] Tombol pelajari alasan menampilkan pop up dialog berisi penjelasan general terkait kenapa laporan tersebut ditolak
  - [x] Tombol ajukan banding belum bisa digunakan, tampilkan dialog "Fitur sedang dalam pengembangan, silahkan hubungi admin atau pihak terkait untuk informasi lebih lanjut atau untuk mengajukan banding"
  - [x] Status "Menunggu": kotak info "Estimasi verifikasi ± 15 menit"
  - [x] Status "Telah Pulih": kotak hijau "Dikonfirmasi Selesai"
- [x] Widget `HistoryEmptyState` bila list kosong (termasuk filter "Ditolak")
- [x] Widget `HistoryLoadingMore` — indicator di bawah list saat `isLoadingMore`

---

## Fase 3: Routing

- [x] Di `app_router.dart`, ganti `_PlaceholderTabScreen(title: 'Riwayat Laporan')` dengan `const HistoryScreen()` pada branch history
- [x] Pastikan tab Riwayat aktif = index 2 di `PantauraBottomNav`
- [x] `_PlaceholderTabScreen` tetap ada untuk tab Profil

---

## Fase 4: Validasi & Quality

- [x] Cek ulang `code.html` + `screen.png` sebelum MCP Stitch (MCP hanya jika diperintahkan)
- [x] `flutter analyze` → 0 error pada file baru
- [x] Pagination & pull-to-refresh bekerja tanpa duplikat card
- [x] Filter "Ditolak" tetap tersedia meski API tidak mengembalikan data rejected
- [x] Semua touch target ≥ 48dp; thumbnail tidak overflow
- [x] Tidak ada bang operator (`!`) di kode baru; widget class terpisah; `const` digunakan

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

- Sumber data hanya `GET /reports/my`; untuk tab "Pengajuan Pemulihan" siapkan empty state bila endpoint resolusi belum ada.
- `ReportModel` tidak punya field judul tersendiri — gunakan `description` sebagai judul card, `incident?.title` bila tersedia.
- Status API `moderationStatus` (`pending`, `approved`, `rejected`, dll.) dipetakan ke `IncidentStatus` dengan switch, jangan diasumsikan persis.
- Card rejected sengaja dibuat walau API menyembunyikannya (permintaan eksplisit).
- `ref.listen` yang dipakai harus berada di dalam `build()` (Riverpod 3).

---

## Catatan Implementasi Aktual

- File dibuat: `lib/features/history/{history_state,history_notifier,history_screen}.dart` dan `widgets/{history_header,history_tab_bar,history_filter_chips,history_report_card,history_empty_state,history_loading_more}.dart`.
- `app_router.dart`: branch `/history` → `const HistoryScreen()`; `_PlaceholderTabScreen` tetap ada untuk tab Profil; `_PlaceholderDetailScreen` sengaja dipertahankan (warning `unused_element` di analyzer, bukan error).
- Tab **Pengajuan Pemulihan** memfilter laporan dengan `moderationStatus == 'resolution_submitted'`; tab Laporan Bencana menampilkan sisanya.
- Filter status memetakan `pending/unverified`, `approved/verified`, `resolved`, `rejected`; chip "Ditolak" tetap ada walau API biasanya tidak mengirim data rejected.
- Card rejected menampilkan kotak alasan + dialog "Pelajari Alasan" (penjelasan umum) dan "Ajukan Banding" (pesan fitur sedang dikembangkan, hubungi admin) sesuai permintaan.
- Pagination via `ScrollController` (threshold 240px) + `RefreshIndicator`, deduplikasi berdasarkan `report.id`.
- `flutter analyze lib/features/history lib/core/routing/app_router.dart` → 0 error; hanya 2 warning placeholder routing lama.
