# TASK: Implementasi Halaman Lapor Kondisi Pulih

**Screen**: Lapor Kondisi Pulih — Pantaura Flutter  
**Stitch Project**: `projects/13707441510623217137`  
**Design lokal**: `.stitch_pantaura_flutter/lapor_kondisi_pulih_siagakita/code.html` + `screen.png`  
**Route**: nested dari detail insiden → `/incidents/:id/recovered` (`AppRoutes.incidentRecoveredPath`)  
**Kembali**: `context.pop()` ke detail insiden setelah manual close **atau** pengajuan berhasil  
**Target file**: `lib/features/incidents/recovered/`

---

## Fase 0: Persiapan & Desain

- [x] Baca `AGENT.md` dan internalisasi rules (Riverpod, go_router, WCAG AAA, touch target 48–56dp)
- [x] **Cek design Stitch lokal terlebih dahulu**: baca `code.html` lalu lihat `screen.png` pada folder design di atas. **Jangan akses MCP Stitch** kecuali user memerintahkan eksplisit
- [x] Baca `lib/features/incidents/incident_detail_screen.dart` — CTA "Konfirmasi Kejadian" / "Lapor Pulih" sebagai titik berangkat
- [x] Baca `lib/features/incidents/incident_detail_state.dart` + `incident_detail_notifier.dart` untuk pola `AsyncNotifier` Riverpod 3.5
- [x] Baca `lib/core/models/api_models.dart` — `IncidentDetailModel`, `ResolutionSubmissionModel`, `MediaModel`
- [x] Baca `lib/core/services/incident_service.dart` — `submitResolution(description, mediaFiles)` (POST `/incidents/{incident}/resolutions`, multipart `description`, `media[]`)
- [x] Baca `lib/core/routing/app_router.dart` + `app_routes.dart` (jangan hapus `_PlaceholderDetailScreen` / `_PlaceholderTabScreen`)
- [x] Baca `lib/core/theme/` — AppColors, AppTypography, AppSpacing, AppRadius, AppShadows
- [x] Baca `lib/features/home/home_screen.dart` untuk pola pengecekan permission saat masuk home

---

## Fase 1: Permission Handler (prasyarat, kerjakan lebih dulu)

- [x] Pakai ulang `lib/core/services/permission_service.dart` dari task tambah laporan:
  - [x] `requestLocationPermission()`, `requestCameraPermission()`, `requestGalleryPermission()`, `ensureAll()`
  - [x] `ensureAll()` dipanggil setiap kali masuk home screen; hasil di-cache di `permissionServiceProvider`
  - [x] `permanentlyDenied` → dialog + `openAppSettings()`
- [x] Pastikan pengecekan sudah berjalan di `home_screen.dart` sebelum user membuka screen ini
- [x] Cek ulang `android/app/src/main/AndroidManifest.xml` — pastikan ada:
  - [x] `android.permission.CAMERA`
  - [x] `android.permission.READ_MEDIA_IMAGES` (API 33+)
  - [x] `android.permission.READ_EXTERNAL_STORAGE android:maxSdkVersion="32"` (legacy)
  - [x] `INTERNET`, `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION`
  - [x] Evaluasi/hapus `ACCESS_FOREGROUND_LOCATION` (bukan permission standar) & `ACCESS_BACKGROUND_LOCATION` bila tidak dipakai
- [x] Jangan meminta permission di dalam `build()`; lakukan sebelum `Geolocator`/`ImagePicker` dipanggil

---

## Fase 2: State & Data Layer

- [x] Buat `lib/features/incidents/recovered/recovered_state.dart`
  - [x] `RecoveredData` immutable: `incident` (`IncidentDetailModel`), `userPosition` (`Position?`), `distanceMeters` (`double?`), `isLocationValid` (`bool`, default `false` = jarak ≤ 500 m), `mediaFiles` (`List<XFile>`), `description` (`String`), `isDeclarationChecked` (`bool`, default `false`), `isSubmitting` (`bool`), `errorMessage` (`String?`)
  - [x] Method `copyWith`
  - [x] Konstanta `quickRecoveryTexts` — maksimal **5** opsi umum untuk semua jenis bencana:
    - [x] "Air sudah surut total / area kering kembali"
    - [x] "Akses jalan sudah dapat dilalui"
    - [x] "Tidak ada korban tertinggal"
    - [x] "Tim lapangan sedang tahap pembersihan"
    - [x] "Kondisi kembali aman untuk warga"
- [x] Buat `lib/features/incidents/recovered/recovered_notifier.dart`
  - [x] `RecoveredNotifier extends AsyncNotifier<RecoveredData>` dengan argumen `incidentId` lewat konstruktor, `AsyncNotifierProvider.family`
  - [x] `build()`: ambil data insiden dari `incidentDetailProvider(incidentId)`
  - [x] `refreshLocation()`: permission lokasi → `getCurrentPosition()` → Haversine ke titik insiden → update jarak & `isLocationValid` (batas 500 m)
  - [x] `addMedia(List<XFile>)` / `removeMedia(int index)` — maksimal 5 foto
  - [x] `appendQuickText(String)` — sisipkan ke deskripsi, hindari duplikat, batas 500 karakter
  - [x] `setDeclaration(bool)` — checkbox pernyataan kebenaran lapangan
  - [x] `submit()`: hanya jalan bila `isLocationValid && isDeclarationChecked && mediaFiles.isNotEmpty && description.trim().isNotEmpty` → `incidentService.submitResolution(description, mediaFiles)` → invalidate `incidentDetailProvider(incidentId)`

---

## Fase 3: Screen & Widget (urutan atas → bawah sesuai `code.html`)

- [x] Buat `lib/features/incidents/recovered/recovered_screen.dart`
  - [x] `RecoveredScreen extends ConsumerStatefulWidget` dengan `final String incidentId`
  - [x] Cek posisi saat masuk: bila posisi sebelumnya tidak valid → tampilkan popup (lihat 3.3)
  - [x] Semua widget turunan di `lib/features/incidents/recovered/widgets/`

### 3.1 — AppBar & Banner Awal

- [x] Widget `RecoveredAppBar` — back arrow `context.pop()`, judul "Lapor Kondisi Pulih", subjudul "Pantaura Tanggap Bencana", avatar kanan
- [x] Widget `RecoveryReassuranceBanner` — chip "Ditinjau dalam estimasi ~15 menit", judul "Pengajuan Penutupan & Pemulihan Insiden", narasi validasi BPBD/relawan

### 3.2 — Card Ringkasan Insiden

- [x] Widget `IncidentSummaryCard`
  - [x] Judul & alamat insiden dari data detail (bukan hardcode)
  - [x] **Chip informasi hanya dua**: "N Laporan Warga Tergabung" (`incident.reportsCount`) dan "Verifikasi Posisi"
  - [x] Chip verifikasi: hijau bila ≤ 500 m → "Posisi Anda terverifikasi di area insiden (radius X meter)"; merah bila tidak valid → teks "Verifikasi hanya berlaku di area maksimal 500 meter dari titik insiden"
  - [x] **Jangan** tambahkan chip lain dari desain (mis. kedalaman genangan, status aktif)

### 3.3 — Popup Posisi Tidak Valid

- [x] Widget/dialog `InvalidLocationDialog`
  - [x] Muncul saat membuka screen dengan posisi tidak valid
  - [x] Isi: penjelasan radius maksimal 500 m + jarak saat ini
  - [x] Dua aksi: **"Tutup Halaman"** → `context.pop()` kembali ke detail; **"Segarkan Lokasi"** → `refreshLocation()`
  - [x] Setelah refresh: bila lokasi **valid** → tutup dialog otomatis + snackbar "Posisi berhasil diverifikasi"; bila **masih tidak valid** → dialog tetap terbuka dengan pesan "Posisi masih di luar area maksimal 500 meter"

### 3.4 — Section Foto Bukti

- [x] Widget `RecoveryEvidenceSection`
  - [x] Header bernomor "1" + "Bukti Visual Kondisi Terkini" + chip "Min. 1 Foto Wajib"
  - [x] Narasi: ambil foto di lokasi yang menunjukkan air sudah surut & akses aman
  - [x] Tombol "Ambil Foto" & "Pilih Galeri" tinggi 54dp (permission camera/gallery)
  - [x] Galeri thumbnail **scroll horizontal** di dalam card, `clipBehavior: Clip.antiAlias`, maksimal 5 foto, tombol hapus per foto
  - [x] **Jangan implementasikan banner/keterangan "Kompresi Cerdas Aktif"** yang ada di `code.html`

### 3.5 — Section Deskripsi

- [x] Widget `RecoveryDescriptionSection`
  - [x] Header bernomor "2" + "Deskripsi" + chip "Wajib"
  - [x] Maksimal **5** chip opsi cepat kondisi pulih umum (lihat daftar di Fase 2), gaya `surfaceContainerLow` rounded-lg
  - [x] Textarea 4 baris, placeholder "Deskripsikan kondisi lapangan saat ini…", counter "X / 500 karakter"

### 3.6 — Pernyataan & CTA

- [x] Widget `TruthDeclarationCard` — checkbox min 28×28dp dengan area sentuh ≥48dp, teks "Pernyataan Kebenaran Lapangan"
- [x] Widget `SubmitRecoveryBar` — tombol "Ajukan Status Pulih" tinggi 56dp
  - [x] **Nonaktif** bila checkbox belum dicentang **atau** posisi user tidak valid
  - [x] Loading saat `isSubmitting`
  - [x] Narasi: status akan berubah menjadi "Sedang Ditinjau"
  - [x] Sukses → invalidate `incidentDetailProvider(incidentId)` lalu `context.pop()` ke detail insiden

---

## Fase 4: Routing

- [x] Tambah `AppRoutes.incidentRecoveredPath = '/incidents/:id/recovered'` dan helper `incidentRecovered(String id)` di `app_routes.dart`
- [x] Daftarkan `GoRoute` di `app_router.dart` → `RecoveredScreen(incidentId: state.pathParameters['id'] ?? '')`
- [x] CTA di detail insiden → `context.push(AppRoutes.incidentRecovered(data.incident.id), extra: data.incident)` (nested)
- [x] Pastikan back / sukses kembali ke detail insiden; placeholder lama tidak dihapus

---

## Fase 5: Validasi & Quality

- [x] **Cek ulang design lokal** (`code.html` + `screen.png`) sebelum implementasi; tanpa akses MCP Stitch
- [x] `analyze_files` → `No errors` pada seluruh file baru dan yang diubah
- [x] Semua touch target ≥ 48dp (CTA 56dp, checkbox area sentuh ≥48dp)
- [x] Tidak ada bang operator (`!`) di kode baru
- [x] Semua widget berupa class terpisah di folder `widgets/`, bukan method yang return Widget
- [x] `const` digunakan di mana memungkinkan
- [x] Tidak ada overflow pada galeri horizontal & textarea saat keyboard muncul
- [x] Tombol ajukan benar-benar disabled pada kedua kondisi (checkbox kosong / posisi invalid)

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
- Validasi radius 500 m memakai perhitungan jarak yang sama dengan task tambah laporan (Haversine, meter) agar konsisten.
- Banner "Kompresi Cerdas Aktif" sengaja **tidak** diimplementasikan sesuai instruksi.
- Peta tidak dipakai di screen ini; verifikasi posisi cukup berupa chip + dialog, bukan peta interaktif.
- Permission dicek ulang setiap kali masuk home screen, bukan hanya saat form dibuka.
